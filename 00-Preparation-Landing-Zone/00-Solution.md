# Solution - Challenge 00: Landing Zone Preparation and Data Connection (Microsoft Fabric)

This document provides a step-by-step guide to complete *Challenge 0*: create a landing zone in Microsoft Fabric, provision Azure Cosmos DB with the provided JSON files, and connect both platforms.

Objectives
- Provision Azure Cosmos DB (NoSQL) and upload the JSON datasets.
- Create a workspace and a Lakehouse in Microsoft Fabric with Bronze / Silver / Gold layers.
- Connect Fabric to Cosmos DB and verify initial ingestion.

Prerequisites
- Permissions to create resources in Azure.
- JSON files (for example `creditScore.json`, `products.json`, `transactions.json`).

Expected result
- Cosmos DB with containers holding the JSON files.
- Fabric workspace connected to a Capacity.
- Lakehouse `Contoso_Lakehouse` with schemas: `bronze`, `silver`, `gold`.

---

## 1 - Create Azure Cosmos DB (NoSQL)

**NOTE**

For convenience you may use the Azure deployment template referenced in [DeployToAzure](./DeployToAzure.md) which automates creation of the Cosmos DB (NoSQL) account and other Azure artifacts. If you use the template you can skip the manual steps below.

1. Sign in to the Azure portal.
2. Search for **Azure Cosmos DB** → +Create → select the API **Azure Cosmos DB for NoSQL** → Create.
3. Fill in the required fields:
   - Workload Type: `Development/Testing`
   - Subscription: `your Azure subscription`
   - Resource Group: `your resource group`
   - Account name: `name for the account`
   - Location: `your default region`
   - Availability Zones: `Disable`
   - Capacity mode: `Serverless`
   - Global Distribution: `Disable`
   - Networking: `All networks`
   - Backup Policy: `Leave default`
   - Key-based authentication: `Enable`
   - Encryption: `Service-managed key`
   - Tags: `Empty`

Review + create
   
![New Foundry](/img/cosmos1.png)

4. After the account is created, open *Data Explorer* and create a database: +New → New Database → Database id → `<name>` (for example `DB-Hackathon`).

![New Foundry](/img/cosmos2.png)

5. Create a container for each dataset (for example `products`, `credit`, `transactions`). Click +New → New container and configure:
- Database id: `Use existing` and select the database you just created
- Container id: `products`
- Partition key: `/id`
- OK

**Repeat this process for the other datasets `credit` and `transactions`.**

![New Foundry](/img/cosmos3.png)

6. Upload the JSON files (manually via Data Explorer or using Azure Data Factory for repeatable loads). In Data Explorer, for each container select `Item` → `Upload Item` → choose the corresponding JSON file → `Upload`.

![New Foundry](/img/cosmos4.png)

7. Verification
- In *Data Explorer* you should see JSON documents in each container.

![New Foundry](/img/cosmos5.png)

---

## 2 - Create a Workspace in Microsoft Fabric

1. Open Microsoft Fabric → in the left sidebar select `Workspaces` → `+New workspace` and create a workspace named `ContosoData-Fabric` (or a suitable name).
2. After creation, go to `Workspace settings` → `Workspace type` → `Edit` and associate the workspace with a Fabric Capacity (skip this step if your organization already has an assigned capacity you can use).
3. Add your user account as Admin/Contributor on the workspace.

Verification
- The workspace appears in the workspace listing and you have appropriate permissions.

![Fabric](/img/wscreate.png)

---

## 3 - Create Lakehouse and define layers

1. In the workspace, create a Lakehouse named `Contoso_Lakehouse` and enable schema support.
2. Create schemas using the following convention:
    - `bronze*` for raw data
    - `silver*` for cleaned data
    - `gold*` for curated/consumption-ready data

Verification
- The schemas are visible in the Lakehouse browser.

![Schemas](/img/schemas.png)

---

## 4 - Connect Fabric to Azure Cosmos DB

1. Inside the workspace select `+New item` → Dataflow Gen2.
2. In the Dataflow Gen2 designer → Get data → More → search for Azure Cosmos DBv2.

![Cosmos](/img/cosmoscon.png)

3. In the connection configuration add:
   - Cosmos DB Endpoint: the account endpoint (found under the Cosmos DB resource `Settings` → `Keys`)
   - Connection name: a friendly connection name
   - Authentication kind: Account key
   - Account key: the PRIMARY KEY of the Cosmos DB account (found under `Settings` → `Keys` → `PRIMARY KEY`)

![Cosmos](/img/cosmoscon1.png)

4. Test and save the connection.

Verification
- The connection tests successfully and you can see available containers/collections.

---







