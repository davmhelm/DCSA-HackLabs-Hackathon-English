
# 🚀 Deploy Landing Zone for Hackathon

This repository provides a **base Landing Zone** to prepare the hackathon environment quickly, consistently, and repeatably.

The goal is to let participants avoid spending time on basic infrastructure so they can focus on **development, innovation and data usage**.

---

## 🟦 What does the **Deploy to Azure** button do?

Clicking the **Deploy to Azure** button will automatically deploy a minimal **Landing Zone** to your Azure subscription, including:

- An **Azure Cosmos DB** for structured and semi-structured data storage.
- An **Azure Storage Account** for blobs, files and other hackathon artifacts.
- Resources organized under a dedicated **Resource Group**.

The deployment is performed using **Infrastructure as Code (IaC)**, ensuring all teams start from the same baseline.

---

## 🧱 Deployed resources

### 📌 Data sources
  - Suitable for scenarios involving:
    - Cosmos NoSQL
    - Storage Accounts


### 📦 Storage

  - Used for:
    - File uploads
    - Hackathon datasets
  

---

## 🎯 Why use this Landing Zone?

This Landing Zone is intended to:

- ✅ Prepare the hackathon base environment in minutes
- ✅ Avoid repetitive manual configuration
- ✅ Ensure consistency across teams
- ✅ Reduce configuration errors
- ✅ Make solution evaluation easier


## 🚀 How to use the button

1. Click the **Deploy to Azure** button.
2. Sign in with your Azure account.
3. Select the **subscription** and **Resource Group**.
4. Fill in the requested parameters (if applicable).
5. Confirm the deployment.

In a few minutes, the environment will be ready.

---


[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](
https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDCSA-HackLabs%2FHackathon-English%2Frefs%2Fheads%2Fmain%2F00-Preparation-Landing-Zone%2Fazuredeploy.json
)
