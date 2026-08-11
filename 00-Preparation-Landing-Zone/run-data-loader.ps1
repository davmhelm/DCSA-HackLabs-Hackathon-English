<#
.SYNOPSIS
    Loads JSON data into Cosmos DB and PDF files into the deployed storage account.

.DESCRIPTION
    This script:
    1. Loads transactions.json into Cosmos DB (Transactions container)
    2. Loads creditScore.json into Cosmos DB (CreditScores container)
    3. Loads product.json into Cosmos DB (Products container)
    4. Extracts and uploads PDF files from "Financial Data Zip" to the Storage Account (documents-pdf container)

.PARAMETER ResourceGroupName
    Name of the Resource Group where the resources were deployed.

.EXAMPLE
    .\run-data-loader.ps1 -ResourceGroupName "rg-fabric-challenge-test"

.EXAMPLE
    # Run directly from GitHub:
    # irm "https://raw.githubusercontent.com/DCSA-HackLabs/Hackathon-English/refs/heads/main/run-data-loader.ps1" -OutFile run-data-loader.ps1; .\run-data-loader.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, HelpMessage = "Name of the Resource Group")]
    [string]$ResourceGroupName
)

$ErrorActionPreference = "Stop"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Step { param([string]$Message) Write-Host "`n📌 $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param([string]$Message) Write-Host "ℹ️  $Message" -ForegroundColor Yellow }
function Write-ErrorMsg { param([string]$Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Function for inserting a document into Cosmos DB
function Add-CosmosDocument {
    param(
        [string]$Endpoint,
        [string]$Key,
        [string]$Database,
        [string]$Container,
        [hashtable]$Document,
        [string]$PartitionKeyField = "id",
        [ref]$LastError = $null
    )

    $resourceLink = "dbs/$Database/colls/$Container"
    $uri = "$Endpoint$resourceLink/docs"
    $date = [DateTime]::UtcNow.ToString("r")

    # Generate the authorization signature
    $keyBytes = [System.Convert]::FromBase64String($Key)
    $text = "post`ndocs`n$resourceLink`n$($date.ToLower())`n`n"
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $keyBytes
    $hash = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($text))
    $signature = [System.Convert]::ToBase64String($hash)
    $authToken = [System.Web.HttpUtility]::UrlEncode("type=master&ver=1.0&sig=$signature")

    # Get partition key value
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
            return $true  # Already exists
        }
        if ($LastError -ne $null) {
            $LastError.Value = $_.Exception.Message
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
║   FABRIC HACKATHON - DATA LOADER                                             ║
║                                                                              ║
║   This script will load:                                                     ║
║   • transactions.json into Cosmos DB (Transactions container)                ║
║   • creditScore.json into Cosmos DB (CreditScores container)                 ║
║   • product.json into Cosmos DB (Products container)                         ║
║   • Financial Data (PDFs) into the Storage Account                           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Magenta

# ============================================================================
# INITIAL CHECKS
# ============================================================================

# Verify that Azure az CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "Azure CLI is not installed. Please install it first:"
    Write-Host "   https://docs.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Verify login in Azure
$account = az account show --output json 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Info "Logging in to Azure..."
    az login
}

# Prompt for Resource Group if not provided
if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
    Write-Host ""
    $ResourceGroupName = Read-Host "📌 Enter the name of your Resource Group"
}

if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
    Write-ErrorMsg "You must provide a Resource Group name"
    exit 1
}

# Verify that the resource group exists
Write-Step "Verifying Resource Group: $ResourceGroupName"
$rgExists = az group exists --name $ResourceGroupName
if ($rgExists -ne "true") {
    Write-ErrorMsg "The Resource Group '$ResourceGroupName' does not exist"
    exit 1
}
Write-Success "Resource Group found"

# ============================================================================
# RETRIEVE RESOURCE INFORMATION
# ============================================================================
Write-Step "Retrieving information of deployed resources..."

# Cosmos DB
$cosmosAccount = az cosmosdb list --resource-group $ResourceGroupName --query "[0]" --output json | ConvertFrom-Json
if (-not $cosmosAccount) {
    Write-ErrorMsg "No Cosmos DB found in the Resource Group"
    exit 1
}
$cosmosAccountName = $cosmosAccount.name
$cosmosEndpoint = $cosmosAccount.documentEndpoint
Write-Success "Cosmos DB found: $cosmosAccountName"

# Retrieve the Azure Cosmos DB account key
$cosmosKeys = az cosmosdb keys list --name $cosmosAccountName --resource-group $ResourceGroupName --output json | ConvertFrom-Json
$cosmosKey = $cosmosKeys.primaryMasterKey

# Storage Account
$storageAccount = az storage account list --resource-group $ResourceGroupName --query "[0]" --output json | ConvertFrom-Json
if (-not $storageAccount) {
    Write-ErrorMsg "No Storage Account found in the Resource Group"
    exit 1
}
$storageAccountName = $storageAccount.name
Write-Success "Storage Account found: $storageAccountName"

# ============================================================================
# DETERMINE DATASETS PATH
# ============================================================================
$ScriptRoot = $PSScriptRoot
$DatasetPath = Join-Path $ScriptRoot "Datasets"

# If it doesn't exist, try the current path
if (-not (Test-Path $DatasetPath)) {
    $DatasetPath = Join-Path (Get-Location) "Datasets"
}

# If it still doesn't exist, use the current directory
if (-not (Test-Path $DatasetPath)) {
    $DatasetPath = Get-Location
}

Write-Info "Searching files in: $DatasetPath"

# ============================================================================
# LOAD JSON DATA TO COSMOS DB
# ============================================================================
Write-Step "Loading data to Cosmos DB..."

$DatabaseName = "FabricChallengeDB"
$ContainerName = "Transactions"

# Find the transactions.json file
$transactionsFile = Get-ChildItem -Path $DatasetPath -Filter "transactions.json" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($transactionsFile) {
    Write-Info "Processing: $($transactionsFile.Name) -> $ContainerName"
    
    # Read JSON
    $jsonContent = Get-Content -Path $transactionsFile.FullName -Raw -Encoding UTF8
    $transactions = $jsonContent | ConvertFrom-Json
    
    # If the JSON is an array, process it directly; if it's an object with a property, extract it
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
        # Assume it's a single document or an object with multiple properties
        $data = @($transactions)
    }
    
    $total = $data.Count
    $loaded = 0
    $failed = 0
    $lastErrorMsg = ""
    
    Write-Info "Found $total transactions to load..."
    
    # Test with the first document to verify connection
    Write-Info "Verifying connection to Cosmos DB..."
    $testItem = $data[0]
    $testDoc = @{}
    foreach ($prop in $testItem.PSObject.Properties) {
        $testDoc[$prop.Name] = $prop.Value
    }
    if (-not $testDoc.ContainsKey("id")) {
        $testDoc["id"] = [guid]::NewGuid().ToString()
    }
    
    $testError = [ref]""
    $testPartitionKey = if ($testDoc.ContainsKey("transactionId")) { "transactionId" } 
                        elseif ($testDoc.ContainsKey("transaction_id")) { "transaction_id" }
                        else { "id" }
    
    $testSuccess = Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey `
        -Database $DatabaseName -Container $ContainerName -Document $testDoc `
        -PartitionKeyField $testPartitionKey -LastError $testError
    
    if (-not $testSuccess) {
        Write-ErrorMsg "Error connecting to Cosmos DB: $($testError.Value)"
        Write-Info "Checking if the database and container exist..."
        
        # Verify that the database exists
        $dbExists = az cosmosdb sql database show --account-name $cosmosAccountName --resource-group $ResourceGroupName --name $DatabaseName --output json 2>$null
        if (-not $dbExists) {
            Write-ErrorMsg "The database '$DatabaseName' does not exist. Creating it..."
            az cosmosdb sql database create --account-name $cosmosAccountName --resource-group $ResourceGroupName --name $DatabaseName --output none
        }
        
        # Verify that the container exists
        $containerExists = az cosmosdb sql container show --account-name $cosmosAccountName --resource-group $ResourceGroupName --database-name $DatabaseName --name $ContainerName --output json 2>$null
        if (-not $containerExists) {
            Write-ErrorMsg "The container '$ContainerName' does not exist. Creating it..."
            az cosmosdb sql container create --account-name $cosmosAccountName --resource-group $ResourceGroupName --database-name $DatabaseName --name $ContainerName --partition-key-path "/id" --output none
        }
        
        Write-Success "Database and container verified/created"
    }
    else {
        Write-Success "Connection to Cosmos DB verified"
        $loaded = 1  # First document already inserted
    }
    
    # Continue processing the remaining documents
    $startIndex = if ($loaded -eq 1) { 1 } else { 0 }
    
    for ($i = $startIndex; $i -lt $data.Count; $i++) {
        $item = $data[$i]
        
        # Convert PSObject to hashtable
        $document = @{}
        foreach ($prop in $item.PSObject.Properties) {
            $document[$prop.Name] = $prop.Value
        }
        
        # Ensure that the id property exists (required by Cosmos DB)
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
        
        # Determine partition key field
        $partitionKeyField = if ($document.ContainsKey("transactionId")) { "transactionId" } 
                            elseif ($document.ContainsKey("transaction_id")) { "transaction_id" }
                            else { "id" }
        
        $errorRef = [ref]""
        # Insert into Cosmos DB
        $success = Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey `
            -Database $DatabaseName -Container $ContainerName -Document $document `
            -PartitionKeyField $partitionKeyField -LastError $errorRef
        
        if ($success) { 
            $loaded++ 
        } else { 
            $failed++
            if ($failed -eq 1) {
                $lastErrorMsg = $errorRef.Value
            }
        }
        
        # Show progress every 10 records or every record if there are few
        $progressInterval = if ($total -lt 50) { 1 } elseif ($total -lt 200) { 10 } else { 50 }
        if ((($loaded + $failed) % $progressInterval -eq 0) -or (($loaded + $failed) -eq $total)) {
            $percent = [math]::Round((($loaded + $failed) / $total) * 100)
            Write-Host "`r  ⏳ Progress: $($loaded + $failed) / $total ($percent%) - ✅$loaded ❌$failed" -ForegroundColor Gray -NoNewline
        }
    }
    Write-Host ""  # Start a new line after the progress output
    
    if ($failed -gt 0 -and $lastErrorMsg) {
        Write-Info "Last error: $lastErrorMsg"
    }
    
    Write-Success "$ContainerName : $loaded loaded / $failed failed / $total total"
}
else {
    Write-Info "transactions.json not found in: $DatasetPath"
    Write-Info "Make sure the file is in the Datasets folder"
}


# ============================================================================
# LOAD creditScore.json INTO COSMOS DB
# ============================================================================
Write-Step "Loading creditScore.json into Cosmos DB..."

$CreditScoreContainerName = "CreditScores"

$creditScoreFile = Get-ChildItem -Path $DatasetPath -Filter "creditScore.json" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($creditScoreFile) {
    Write-Info "Processing: $($creditScoreFile.Name) -> $CreditScoreContainerName"

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
    $csLastErrorMsg = ""

    Write-Info "Found $csTotal credit score records to load..."

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

        $errorRef = [ref]""
        $success = Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey `
            -Database $DatabaseName -Container $CreditScoreContainerName -Document $document `
            -PartitionKeyField $partitionKeyField -LastError $errorRef

        if ($success) { $csLoaded++ } else {
            $csFailed++
            if ($csFailed -eq 1) { $csLastErrorMsg = $errorRef.Value }
        }

        $progressInterval = if ($csTotal -lt 50) { 1 } elseif ($csTotal -lt 200) { 10 } else { 50 }
        if ((($csLoaded + $csFailed) % $progressInterval -eq 0) -or (($csLoaded + $csFailed) -eq $csTotal)) {
            $percent = [math]::Round((($csLoaded + $csFailed) / $csTotal) * 100)
            Write-Host "`r  ⏳ Progress: $($csLoaded + $csFailed) / $csTotal ($percent%) - ✅$csLoaded ❌$csFailed" -ForegroundColor Gray -NoNewline
        }
    }
    Write-Host ""

    if ($csFailed -gt 0 -and $csLastErrorMsg) {
        Write-Info "Last error: $csLastErrorMsg"
    }

    Write-Success "$CreditScoreContainerName : $csLoaded loaded / $csFailed failed / $csTotal total"
}
else {
    Write-Info "creditScore.json not found in: $DatasetPath"
}

# ============================================================================
# LOAD product.json INTO COSMOS DB
# ============================================================================
Write-Step "Loading product.json into Cosmos DB..."

$ProductContainerName = "Products"

$productFile = Get-ChildItem -Path $DatasetPath -Filter "product.json" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($productFile) {
    Write-Info "Processing: $($productFile.Name) -> $ProductContainerName"

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
    $prodLastErrorMsg = ""

    Write-Info "Found $prodTotal products to load..."

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

        $errorRef = [ref]""
        $success = Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey `
            -Database $DatabaseName -Container $ProductContainerName -Document $document `
            -PartitionKeyField $partitionKeyField -LastError $errorRef

        if ($success) { $prodLoaded++ } else {
            $prodFailed++
            if ($prodFailed -eq 1) { $prodLastErrorMsg = $errorRef.Value }
        }

        $progressInterval = if ($prodTotal -lt 50) { 1 } elseif ($prodTotal -lt 200) { 10 } else { 50 }
        if ((($prodLoaded + $prodFailed) % $progressInterval -eq 0) -or (($prodLoaded + $prodFailed) -eq $prodTotal)) {
            $percent = [math]::Round((($prodLoaded + $prodFailed) / $prodTotal) * 100)
            Write-Host "`r  ⏳ Progress: $($prodLoaded + $prodFailed) / $prodTotal ($percent%) - ✅$prodLoaded ❌$prodFailed" -ForegroundColor Gray -NoNewline
        }
    }
    Write-Host ""

    if ($prodFailed -gt 0 -and $prodLastErrorMsg) {
        Write-Info "Last error: $prodLastErrorMsg"
    }

    Write-Success "$ProductContainerName : $prodLoaded loaded / $prodFailed failed / $prodTotal total"
}
else {
    Write-Info "product.json not found in: $DatasetPath"
}

# ============================================================================
# UPLOAD PDF FILES (FINANCIAL DATA ZIP) TO THE STORAGE ACCOUNT
# ============================================================================
Write-Step "Processing Financial Data (PDFs) for Storage Account..."

# Find the ZIP archive containing the Financial Data files
$pdfZipFile = Get-ChildItem -Path $DatasetPath -Filter "*Financial*Data*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1

# If not found with that pattern, look for any ZIP
if (-not $pdfZipFile) {
    $pdfZipFile = Get-ChildItem -Path $DatasetPath -Filter "*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1
}

if ($pdfZipFile) {
    Write-Info "ZIP found: $($pdfZipFile.Name)"
    
    # Create temporary folder
    $tempFolder = Join-Path $env:TEMP "pdf-extract-$(Get-Random)"
    New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null
    
    try {
        # Extract ZIP
        Write-Info "Extracting files from ZIP..."
        Expand-Archive -Path $pdfZipFile.FullName -DestinationPath $tempFolder -Force
        
        # Find PDFs (including subfolders)
        $pdfFiles = Get-ChildItem -Path $tempFolder -Filter "*.pdf" -Recurse
        
        if ($pdfFiles.Count -gt 0) {
            Write-Info "Found $($pdfFiles.Count) PDF files"
            
            $uploadedCount = 0
            foreach ($pdf in $pdfFiles) {
                Write-Info "Uploading $($pdf.Name)..."
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
            Write-Success "$uploadedCount PDF files uploaded to the 'documents-pdf' container"
        }
        else {
            Write-Info "No PDF files found in the ZIP"
        }
    }
    finally {
        # Clean up temporary folder
        if (Test-Path $tempFolder) {
            Remove-Item -Path $tempFolder -Recurse -Force
        }
    }
}
else {
    Write-Info "No ZIP file with Financial Data found in: $DatasetPath"
    Write-Info "The script looks for files matching '*Financial*Data*.zip' or any .zip file"
}

# ============================================================================
# FINAL SUMMARY
# ============================================================================
Write-Host @"

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   🎉  DATA LOAD COMPLETED!                                                   ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Green

Write-Host "📋 SUMMARY:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host ""
Write-Host "🗄️  COSMOS DB: $cosmosAccountName" -ForegroundColor Yellow
Write-Host "   Database:   FabricChallengeDB"
Write-Host "   Container: Transactions (data from transactions.json)"
Write-Host "   Container: CreditScores (data from creditScore.json)"
Write-Host "   Container: Products (data from product.json)"
Write-Host ""
Write-Host "📦 STORAGE ACCOUNT: $storageAccountName" -ForegroundColor Yellow
Write-Host "   Data container:"
Write-Host "   • documents-pdf  - Financial Data (PDFs)"
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Gray

Write-Host "`n🔗 CONNECT FROM FABRIC:" -ForegroundColor Cyan
Write-Host "   Cosmos DB Endpoint: $cosmosEndpoint"
Write-Host "   Storage Account:    https://$storageAccountName.dfs.core.windows.net/"
Write-Host ""
