<#
.SYNOPSIS
    Carga datos JSON a Cosmos DB y archivos PDF al Storage Account desplegado.

.DESCRIPTION
    Este script:
    1. Carga transactions.json a Cosmos DB (contenedor Transactions)
    2. Carga creditScore.json a Cosmos DB (contenedor CreditScores)
    3. Carga product.json a Cosmos DB (contenedor Products)
    4. Extrae y sube archivos PDF de "Financial Data Zip" al Storage Account (contenedor documents-pdf)

.PARAMETER ResourceGroupName
    Nombre del Resource Group donde se desplegaron los recursos.

.EXAMPLE
    .\run-data-loader.ps1 -ResourceGroupName "rg-fabric-challenge-test"

.EXAMPLE
    # Ejecutar directamente desde GitHub:
    # irm https://raw.githubusercontent.com/<OWNER>/<REPO>/main/Hackathon-Mexico/run-data-loader.ps1 -OutFile run-data-loader.ps1; .\run-data-loader.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, HelpMessage = "Nombre del Resource Group")]
    [string]$ResourceGroupName
)

$ErrorActionPreference = "Stop"

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

function Write-Step { param([string]$Message) Write-Host "`n📌 $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param([string]$Message) Write-Host "ℹ️  $Message" -ForegroundColor Yellow }
function Write-ErrorMsg { param([string]$Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Función para insertar documento en Cosmos DB
function Add-CosmosDocument {
    param(
        [string]$Endpoint,
        [string]$Key,
        [string]$Database,
        [string]$Container,
        [hashtable]$Document,
        [string]$PartitionKeyField = "id"
    )

    $resourceLink = "dbs/$Database/colls/$Container"
    $uri = "$Endpoint$resourceLink/docs"
    $date = [DateTime]::UtcNow.ToString("r")

    # Generar firma
    $keyBytes = [System.Convert]::FromBase64String($Key)
    $text = "post`ndocs`n$resourceLink`n$($date.ToLower())`n`n"
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $keyBytes
    $hash = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($text))
    $signature = [System.Convert]::ToBase64String($hash)
    $authToken = [System.Web.HttpUtility]::UrlEncode("type=master&ver=1.0&sig=$signature")

    # Obtener partition key value
    $partitionKeyValue = $Document[$PartitionKeyField]
    if (-not $partitionKeyValue) {
        $partitionKeyValue = $Document.id
    }

    $headers = @{
        "Authorization"                    = $authToken
        "x-ms-date"                        = $date
        "x-ms-version"                     = "2018-12-31"
        "Content-Type"                     = "application/json"
        "x-ms-documentdb-partitionkey"     = "[`"$partitionKeyValue`"]"
        "x-ms-documentdb-is-upsert"        = "true"
    }

    try {
        $body = $Document | ConvertTo-Json -Depth 10 -Compress
        $response = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body -ContentType "application/json"
        return $true
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 409) {
            return $true  # Ya existe
        }
        return $false
    }
}

# ============================================================================
# BANNER
# ============================================================================
Write-Host @"

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   🇲🇽  HACKATHON MÉXICO - DATA LOADER                                        ║
║                                                                              ║
║   Este script cargará:                                                       ║
║   • transactions.json a Cosmos DB (contenedor Transactions)                 ║
║   • creditScore.json a Cosmos DB (contenedor CreditScores)                  ║
║   • product.json a Cosmos DB (contenedor Products)                          ║
║   • Financial Data (PDFs) al Storage Account                                ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Magenta

# ============================================================================
# VERIFICACIONES INICIALES
# ============================================================================

# Verificar Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "Azure CLI no está instalado. Por favor instálalo primero:"
    Write-Host "   https://docs.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Verificar login en Azure
$account = az account show --output json 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Info "Iniciando sesión en Azure..."
    az login
}

# Solicitar Resource Group si no se proporciona
if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
    Write-Host ""
    $ResourceGroupName = Read-Host "📌 Ingresa el nombre de tu Resource Group"
}

if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
    Write-ErrorMsg "Debes proporcionar un nombre de Resource Group"
    exit 1
}

# Verificar que el Resource Group existe
Write-Step "Verificando Resource Group: $ResourceGroupName"
$rgExists = az group exists --name $ResourceGroupName
if ($rgExists -ne "true") {
    Write-ErrorMsg "El Resource Group '$ResourceGroupName' no existe"
    exit 1
}
Write-Success "Resource Group encontrado"

# ============================================================================
# OBTENER INFORMACIÓN DE LOS RECURSOS
# ============================================================================
Write-Step "Obteniendo información de los recursos desplegados..."

# Cosmos DB
$cosmosAccount = az cosmosdb list --resource-group $ResourceGroupName --query "[0]" --output json | ConvertFrom-Json
if (-not $cosmosAccount) {
    Write-ErrorMsg "No se encontró Cosmos DB en el Resource Group"
    exit 1
}
$cosmosAccountName = $cosmosAccount.name
$cosmosEndpoint = $cosmosAccount.documentEndpoint
Write-Success "Cosmos DB encontrado: $cosmosAccountName"

# Obtener key de Cosmos DB
$cosmosKeys = az cosmosdb keys list --name $cosmosAccountName --resource-group $ResourceGroupName --output json | ConvertFrom-Json
$cosmosKey = $cosmosKeys.primaryMasterKey

# Storage Account
$storageAccount = az storage account list --resource-group $ResourceGroupName --query "[0]" --output json | ConvertFrom-Json
if (-not $storageAccount) {
    Write-ErrorMsg "No se encontró Storage Account en el Resource Group"
    exit 1
}
$storageAccountName = $storageAccount.name
Write-Success "Storage Account encontrado: $storageAccountName"

# ============================================================================
# DETERMINAR RUTA DE DATASETS
# ============================================================================
$ScriptRoot = $PSScriptRoot
$DatasetPath = Join-Path $ScriptRoot "Datasets"

# Si no existe, intentar ruta actual
if (-not (Test-Path $DatasetPath)) {
    $DatasetPath = Join-Path (Get-Location) "Datasets"
}

# Si aún no existe, usar directorio actual
if (-not (Test-Path $DatasetPath)) {
    $DatasetPath = Get-Location
}

Write-Info "Buscando archivos en: $DatasetPath"

# ============================================================================
# CARGAR DATOS JSON A COSMOS DB
# ============================================================================
Write-Step "Cargando datos a Cosmos DB..."

$DatabaseName = "FabricChallengeDB"
$ContainerName = "Transactions"

# Buscar archivo transactions.json
$transactionsFile = Get-ChildItem -Path $DatasetPath -Filter "transactions.json" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($transactionsFile) {
    Write-Info "Procesando: $($transactionsFile.Name) -> $ContainerName"
    
    # Leer JSON
    $jsonContent = Get-Content -Path $transactionsFile.FullName -Raw -Encoding UTF8
    $transactions = $jsonContent | ConvertFrom-Json
    
    # Si el JSON es un array, procesarlo directamente; si es un objeto con una propiedad, extraerla
    if ($transactions -is [Array]) {
        $data = $transactions
    }
    elseif ($transactions.transactions) {
        $data = $transactions.transactions
    }
    elseif ($transactions.data) {
        $data = $transactions.data
    }
    else {
        # Asumir que es un solo documento o un objeto con múltiples propiedades
        $data = @($transactions)
    }
    
    $total = $data.Count
    $loaded = 0
    $failed = 0
    
    Write-Info "Encontradas $total transacciones para cargar..."
    
    foreach ($item in $data) {
        # Convertir PSObject a hashtable
        $document = @{}
        foreach ($prop in $item.PSObject.Properties) {
            $document[$prop.Name] = $prop.Value
        }
        
        # Asegurar campo id (requerido por Cosmos DB)
        if (-not $document.ContainsKey("id")) {
            if ($document.ContainsKey("transactionId")) {
                $document["id"] = $document["transactionId"]
            }
            elseif ($document.ContainsKey("transaction_id")) {
                $document["id"] = $document["transaction_id"]
            }
            else {
                $document["id"] = [guid]::NewGuid().ToString()
            }
        }
        
        # Determinar partition key field
        $partitionKeyField = if ($document.ContainsKey("transactionId")) { "transactionId" } 
                            elseif ($document.ContainsKey("transaction_id")) { "transaction_id" }
                            else { "id" }
        
        # Insertar en Cosmos DB
        $success = Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey `
            -Database $DatabaseName -Container $ContainerName -Document $document `
            -PartitionKeyField $partitionKeyField
        
        if ($success) { $loaded++ } else { $failed++ }
        
        # Mostrar progreso cada 100 registros
        if ($loaded % 100 -eq 0 -and $loaded -gt 0) {
            Write-Host "  Progreso: $loaded / $total" -ForegroundColor Gray
        }
    }
    
    Write-Success "$ContainerName : $loaded cargados / $failed fallidos / $total total"
}
else {
    Write-Info "No se encontró transactions.json en: $DatasetPath"
    Write-Info "Asegúrate de tener el archivo en la carpeta Datasets"
}


# ============================================================================
# CARGAR creditScore.json A COSMOS DB
# ============================================================================
Write-Step "Cargando creditScore.json a Cosmos DB..."

$CreditScoreContainerName = "CreditScores"

$creditScoreFile = Get-ChildItem -Path $DatasetPath -Filter "creditScore.json" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($creditScoreFile) {
    Write-Info "Procesando: $($creditScoreFile.Name) -> $CreditScoreContainerName"

    $jsonContent = Get-Content -Path $creditScoreFile.FullName -Raw -Encoding UTF8
    $creditScores = $jsonContent | ConvertFrom-Json

    if ($creditScores -is [Array]) {
        $csData = $creditScores
    }
    elseif ($creditScores.creditScores) {
        $csData = $creditScores.creditScores
    }
    elseif ($creditScores.data) {
        $csData = $creditScores.data
    }
    else {
        $csData = @($creditScores)
    }

    $csTotal = $csData.Count
    $csLoaded = 0
    $csFailed = 0

    Write-Info "Encontrados $csTotal registros de credit score para cargar..."

    foreach ($item in $csData) {
        $document = @{}
        foreach ($prop in $item.PSObject.Properties) {
            $document[$prop.Name] = $prop.Value
        }

        if (-not $document.ContainsKey("id")) {
            if ($document.ContainsKey("creditScoreId")) {
                $document["id"] = $document["creditScoreId"]
            }
            elseif ($document.ContainsKey("credit_score_id")) {
                $document["id"] = $document["credit_score_id"]
            }
            elseif ($document.ContainsKey("customerId")) {
                $document["id"] = $document["customerId"]
            }
            else {
                $document["id"] = [guid]::NewGuid().ToString()
            }
        }

        $partitionKeyField = if ($document.ContainsKey("creditScoreId")) { "creditScoreId" }
                            elseif ($document.ContainsKey("credit_score_id")) { "credit_score_id" }
                            else { "id" }

        $success = Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey `
            -Database $DatabaseName -Container $CreditScoreContainerName -Document $document `
            -PartitionKeyField $partitionKeyField

        if ($success) { $csLoaded++ } else { $csFailed++ }

        if ($csLoaded % 100 -eq 0 -and $csLoaded -gt 0) {
            Write-Host "  Progreso: $csLoaded / $csTotal" -ForegroundColor Gray
        }
    }

    Write-Success "$CreditScoreContainerName : $csLoaded cargados / $csFailed fallidos / $csTotal total"
}
else {
    Write-Info "No se encontró creditScore.json en: $DatasetPath"
}

# ============================================================================
# CARGAR product.json A COSMOS DB
# ============================================================================
Write-Step "Cargando product.json a Cosmos DB..."

$ProductContainerName = "Products"

$productFile = Get-ChildItem -Path $DatasetPath -Filter "product.json" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($productFile) {
    Write-Info "Procesando: $($productFile.Name) -> $ProductContainerName"

    $jsonContent = Get-Content -Path $productFile.FullName -Raw -Encoding UTF8
    $products = $jsonContent | ConvertFrom-Json

    if ($products -is [Array]) {
        $prodData = $products
    }
    elseif ($products.products) {
        $prodData = $products.products
    }
    elseif ($products.data) {
        $prodData = $products.data
    }
    else {
        $prodData = @($products)
    }

    $prodTotal = $prodData.Count
    $prodLoaded = 0
    $prodFailed = 0

    Write-Info "Encontrados $prodTotal productos para cargar..."

    foreach ($item in $prodData) {
        $document = @{}
        foreach ($prop in $item.PSObject.Properties) {
            $document[$prop.Name] = $prop.Value
        }

        if (-not $document.ContainsKey("id")) {
            if ($document.ContainsKey("productId")) {
                $document["id"] = $document["productId"]
            }
            elseif ($document.ContainsKey("product_id")) {
                $document["id"] = $document["product_id"]
            }
            else {
                $document["id"] = [guid]::NewGuid().ToString()
            }
        }

        $partitionKeyField = if ($document.ContainsKey("productId")) { "productId" }
                            elseif ($document.ContainsKey("product_id")) { "product_id" }
                            else { "id" }

        $success = Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey `
            -Database $DatabaseName -Container $ProductContainerName -Document $document `
            -PartitionKeyField $partitionKeyField

        if ($success) { $prodLoaded++ } else { $prodFailed++ }

        if ($prodLoaded % 100 -eq 0 -and $prodLoaded -gt 0) {
            Write-Host "  Progreso: $prodLoaded / $prodTotal" -ForegroundColor Gray
        }
    }

    Write-Success "$ProductContainerName : $prodLoaded cargados / $prodFailed fallidos / $prodTotal total"
}
else {
    Write-Info "No se encontró product.json en: $DatasetPath"
}

# ============================================================================
# SUBIR ARCHIVOS PDF (FINANCIAL DATA ZIP) AL STORAGE ACCOUNT
# ============================================================================
Write-Step "Procesando Financial Data (PDFs) para Storage Account..."

# Buscar el archivo ZIP con Financial Data
$pdfZipFile = Get-ChildItem -Path $DatasetPath -Filter "*Financial*Data*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1

# Si no se encuentra con ese patrón, buscar cualquier ZIP
if (-not $pdfZipFile) {
    $pdfZipFile = Get-ChildItem -Path $DatasetPath -Filter "*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1
}

if ($pdfZipFile) {
    Write-Info "ZIP encontrado: $($pdfZipFile.Name)"
    
    # Crear carpeta temporal
    $tempFolder = Join-Path $env:TEMP "pdf-extract-$(Get-Random)"
    New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null
    
    try {
        # Extraer ZIP
        Write-Info "Extrayendo archivos del ZIP..."
        Expand-Archive -Path $pdfZipFile.FullName -DestinationPath $tempFolder -Force
        
        # Buscar PDFs (incluyendo subcarpetas)
        $pdfFiles = Get-ChildItem -Path $tempFolder -Filter "*.pdf" -Recurse
        
        if ($pdfFiles.Count -gt 0) {
            Write-Info "Encontrados $($pdfFiles.Count) archivos PDF"
            
            $uploadedCount = 0
            foreach ($pdf in $pdfFiles) {
                Write-Info "Subiendo $($pdf.Name)..."
                az storage blob upload `
                    --account-name $storageAccountName `
                    --container-name "documents-pdf" `
                    --file $pdf.FullName `
                    --name $pdf.Name `
                    --auth-mode login `
                    --overwrite `
                    --output none 2>$null
                $uploadedCount++
            }
            Write-Success "$uploadedCount archivos PDF subidos al contenedor 'documents-pdf'"
        }
        else {
            Write-Info "No se encontraron archivos PDF en el ZIP"
        }
    }
    finally {
        # Limpiar carpeta temporal
        if (Test-Path $tempFolder) {
            Remove-Item -Path $tempFolder -Recurse -Force
        }
    }
}
else {
    Write-Info "No se encontró archivo ZIP con Financial Data en: $DatasetPath"
    Write-Info "El script busca archivos con patrón '*Financial*Data*.zip' o cualquier archivo .zip"
}

# ============================================================================
# RESUMEN FINAL
# ============================================================================
Write-Host @"

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   🎉  ¡CARGA DE DATOS COMPLETADA!                                           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Green

Write-Host "📋 RESUMEN:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host ""
Write-Host "🗄️  COSMOS DB: $cosmosAccountName" -ForegroundColor Yellow
Write-Host "   Database:   FabricChallengeDB"
Write-Host "   Contenedor: Transactions (datos de transactions.json)"
Write-Host "   Contenedor: CreditScores (datos de creditScore.json)"
Write-Host "   Contenedor: Products (datos de product.json)"
Write-Host ""
Write-Host "📦 STORAGE ACCOUNT: $storageAccountName" -ForegroundColor Yellow
Write-Host "   Contenedor con datos:"
Write-Host "   • documents-pdf  - Financial Data (PDFs)"
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Gray

Write-Host "`n🔗 CONEXIÓN DESDE FABRIC:" -ForegroundColor Cyan
Write-Host "   Cosmos DB Endpoint: $cosmosEndpoint"
Write-Host "   Storage Account:    https://$storageAccountName.dfs.core.windows.net/"
Write-Host ""
