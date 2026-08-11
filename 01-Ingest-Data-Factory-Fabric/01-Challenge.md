
# 🏆 Challenge 1: Data Ingestion from Cosmos DB to Microsoft Fabric (Bronze Layer) + Basic Cleaning

📖 Scenario
Contoso needs to consolidate its **operational and financial data** in **Microsoft Fabric**.
The data team must perform **ingestion from Azure Cosmos DB** into the **Bronze** layer and apply a minimal initial **cleaning** to prepare data before advancing to subsequent transformation phases.

---

### 🎯 Mission
After completing this challenge you will be able to:

✅ Ingest data from **Azure Cosmos DB** into **Microsoft Fabric** using **Dataflows Gen2**.
✅ Apply **basic cleaning** including, for example:
- Handling null or empty values.
- Removing unnecessary columns.
- Normalizing basic formats (dates, text, etc.).

✅ Produce a semi/raw layer within the Lakehouse **Bronze** schema.

---

## 🚀 Step 1: Create a Dataflow Gen2 for ingestion from Cosmos DB (other ingestion methods may be used)
💡 *Why?* **Dataflows Gen2** enable initial ingestion and transformations without code, easily connecting external sources like Cosmos DB to your Lakehouse. Optionally, ingestion can also be implemented using a **Pipeline** with copy activities, **Notebooks**, or **Cosmos DB Mirroring** to expose containers in Fabric.

1️⃣ In **Microsoft Fabric**, create a new **Dataflow Gen2** inside your workspace.
2️⃣ Select **Azure Cosmos DB** as the data source.
3️⃣ Enter the connection credentials (endpoint and access key).
4️⃣ Connect to the container that holds the **products**, **credit score**, and **transactions** data.
5️⃣ Set your **Lakehouse** schema target to `bronze` to store the ingested data (enable the `navigate full hierarchy` flag in advanced Lakehouse connection options to allow schema navigation).

✅ **Expected result:** The Cosmos DB JSON data is available in Dataflow Gen2 queries.

## 🚀 Step 2: Apply Basic Cleaning in the Dataflow Gen2
💡 *Why?* This step improves data quality and ensures consistency for downstream analysis. Some organizations clean in Bronze while others ingest raw data and prepare it later.
1️⃣ Edit your **Dataflow Gen2** to add transformation steps:
   - 🧹 **Remove unnecessary columns** that do not provide analytical value.
   - 🩹 **Replace or remove null or empty values.**
   - 🕒 **Normalize basic formats** (e.g., date fields or lowercase text).
      
2️⃣ Save and run the Dataflow to apply the transformations.
3️⃣ Publish results to the **Bronze** layer of your Lakehouse.

✅ **Expected result:** Bronze tables contain cleaned data ready for transformation into Silver.

---

## 🚀 Step 3: Validate Load and Data Structure
💡 *Why?* Validating ingestion ensures the data is complete and consistent before cleaning.

1️⃣ Access your **Lakehouse** from the Fabric panel.
🔹 Verify Delta tables include expected fields.
🔹 Check for format errors or incomplete records.

✅ **Expected result:** The base data structure has been validated successfully.

---


## 🏁 Final Checkpoints

✅ Was ingestion from Cosmos DB completed using Dataflows Gen2?
✅ Were basic cleaning steps applied correctly?
✅ Are the resulting tables stored and accessible in the Bronze layer?
✅ Were the performed steps and visual evidence documented?

---

## 📝 Documentation


- [Create Dataflow Gen2](https://learn.microsoft.com/fabric/data-factory/create-first-dataflow-gen2)




