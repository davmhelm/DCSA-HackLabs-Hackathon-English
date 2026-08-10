# 🏆 Challenge 0: Landing Zone Setup and Data Preparation in Microsoft Fabric
📖 Scenario

Contoso Retail has uploaded three datasets in **JSON** format:
- One **financial** dataset containing customer **credit score** information.
- Two **retail** datasets with **transactions and products** data.

Your mission is to **prepare the working environment in Microsoft Fabric**, connect the data stored in **Azure Cosmos DB**, and establish a layered **landing zone** to start the data transformation process.

---

### 🎯 Mission
After completing this challenge you will be able to:

✅ Create a Cosmos DB NoSQL account and upload the JSON files to containers.
✅ Configure a **workspace** in Microsoft Fabric for data management.
✅ Connect **Azure Cosmos DB** as a data source.
✅ Explore and understand the structure of the financial and retail JSON files.
✅ Create a **Lakehouse** with layered structure (**Bronze**, **Silver**, **Gold**).
✅ Define and document the data flow between layers.

---
## 🚀 Step 1: Create an Azure Cosmos DB (NoSQL)
💡 *Why?* Cosmos DB will be the data source that Fabric will ingest from.

1️⃣ Sign in to the **Microsoft Azure** portal and create a Cosmos DB (NoSQL) account. For convenience, we recommend using the deployment template referenced in [DeployToAzure](./DeployToAzure.md) to speed up artifact creation.
🔹 Choose a descriptive name (for example, `ContosoData-Source`).
🔹 Create a container and give it a clear identifier.
🔹 Upload the JSON dataset files to the container.

✅ **Expected result:** You have a Cosmos DB account with a container containing the data ready to be ingested by Fabric.

## 🚀 Step 2: Create a Workspace in Microsoft Fabric
💡 *Why?* The workspace is the centralized environment where datasets, dataflows, pipelines and notebooks are managed.

1️⃣ In **Microsoft Fabric**, create a new workspace for the Contoso project.
🔹 Use a descriptive name (for example, `ContosoData-Fabric`).
🔹 Ensure the workspace is associated with a **Fabric Capacity** if required.

✅ **Expected result:** You have a dedicated workspace for all Fabric resources.

---

## 🚀 Step 3: Connect to Azure Cosmos DB
💡 *Why?* Establishing this connection allows Fabric to access and ingest the JSON data directly from Cosmos DB.

1️⃣ In your Fabric workspace, create a new **data connection** to **Azure Cosmos DB**.
🔹 Provide the correct **endpoint** and **access key**.
🔹 Verify that the necessary permissions are configured.

✅ **Expected result:** Your workspace is connected to Cosmos DB and ready for ingestion.

---

## 🚀 Step 4: Create a Lakehouse and Define Layered Structure
💡 *Why?* The Lakehouse is the foundation of the data architecture and separates processing stages.

1️⃣ In Fabric, create a **Lakehouse** (enable schema support) named `Contoso_Lakehouse`.
2️⃣ Within the Lakehouse, define the following schema/layer structure:
   - 🥉 **Bronze:** Raw, unprocessed data ingested directly from Cosmos DB.
   - 🥈 **Silver:** Cleaned, normalized, and consistent data.
   - 🥇 **Gold:** Curated datasets ready for analysis and visualization.

✅ **Best practice:** Keep clear naming conventions for schemas and tables to make data lineage and flow easier to follow.

✅ **Expected result:** Your Lakehouse has a structured foundation to support transformations and analysis.

---

## 🏁 Final Checkpoints

✅ Was Cosmos DB and its containers created correctly?
✅ Was the Microsoft Fabric workspace created and connected to Cosmos DB?
✅ Was the JSON dataset structure validated in Cosmos DB?
✅ Is the Lakehouse organized into Bronze, Silver, and Gold layers?
✅ Was the data flow strategy between layers documented?

---

💡 **Next steps:**
With the **landing zone** configured, you are ready to proceed to the next challenge, where you will perform **ingestion, cleansing and data transformation** inside Fabric. 🚀

---

**📄 Documentation**
- [Create Cosmos DB (NoSQL)](https://learn.microsoft.com/es-es/azure/cosmos-db/nosql/quickstart-portal)
- [Allow public IP in Firewall](https://learn.microsoft.com/en-us/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4)
- [Create Fabric workspace](https://learn.microsoft.com/es-es/fabric/data-warehouse/tutorial-create-workspace)
- [Create Fabric lakehouse](https://learn.microsoft.com/es-es/fabric/data-engineering/tutorial-build-lakehouse)
- [Create Pipeline](https://learn.microsoft.com/es-mx/fabric/data-factory/create-first-pipeline-with-sample-data)





