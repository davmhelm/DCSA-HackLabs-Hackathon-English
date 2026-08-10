# 📊 Datasets - Hackathon México

Esta carpeta contiene los datos necesarios para el Hackathon de IA y Fabric.

---

# 📊 Datasets - Hackathon Mexico

This folder contains the data needed for the AI & Fabric Hackathon.

---

## 🚀 UPLOAD DATA TO AZURE

### 1️⃣ Open Azure Cloud Shell (click the button)

[![Open Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/media/embed-cloud-shell/launch-cloud-shell-1.png)](https://shell.azure.com/powershell)

---

### 2️⃣ Copy and paste this command into Cloud Shell

```powershell
git clone https://github.com/DCSA-HackLabs/Hackathon-Mexico.git; cd Hackathon-Mexico; ./run-data-loader.ps1
```

<details>
<summary>📋 Click here to copy the command</summary>

```
git clone https://github.com/DCSA-HackLabs/Hackathon-Mexico.git; cd Hackathon-Mexico; ./run-data-loader.ps1
```

</details>

---

### 3️⃣ Enter your Resource Group when prompted

```
📌 Enter your Resource Group name: rg-fabric-challenge-YOURTEAM
```

---

## ✅ Done!

The script will automatically upload:

| File | Destination |
|------|-------------|
| 📄 `transactions.json` | **Cosmos DB** → FabricChallengeDB → Transactions |
| 📁 `Financial Data.zip` (PDFs) | **Storage Account** → documents-pdf |

---

## 🔄 Process Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   📂 Datasets/                                                  │
│   ├── transactions.json  ──────►  🗄️ Cosmos DB                 │
│   │                               └── FabricChallengeDB         │
│   │                                   └── Transactions          │
│   │                                                             │
│   └── Financial Data.zip ──────►  📦 Storage Account           │
│       └── *.pdf                   └── documents-pdf/            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## ❓ Common Issues

| Error | Solution |
|------|----------|
| "Cosmos DB not found" | Verify the Resource Group name |
| "Resource Group does not exist" | Deploy the resources first using the ARM template |
| Authentication error | Run `az login` |

---

## 📞 Support

Having issues? Contact the Microsoft team during the event.
