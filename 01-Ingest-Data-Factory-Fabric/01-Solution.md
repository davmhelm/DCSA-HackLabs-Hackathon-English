
# Solution - Challenge 01: Ingest from Cosmos DB to Microsoft Fabric (Bronze Layer) + Basic Cleaning

Step-by-step guide to ingest data from Azure Cosmos DB into the Lakehouse Bronze layer in Microsoft Fabric, apply initial cleaning and validate results.

Objective
- Ingest data from Cosmos DB using Dataflow Gen2 or pipeline and apply basic transformations (nulls, columns, formats).

Prerequisites
- Cosmos DB connection from Fabric (see `00-Solution.md`).

## Steps

### 1 - Create Dataflow Gen2

1. In Fabric: Data → New → Dataflow Gen2.
2. Select **Azure Cosmos DB** as the source.
3. Fill in endpoint and key (or select an existing connection).
4. Choose the collection/container that contains `products`, `creditScore`, `transactions`.

### 2 - Design basic transformations

Within the Dataflow designer:
- Remove unnecessary columns.
- Normalize formats: convert dates, trim and lowercase strings, normalize decimals, adjust data types.
- Replace or flag null values (e.g., use `unknown` or default values).
- Filter out corrupt or incomplete records (if applicable).

![DF](/img/dfgen2.png)

Tip: add intermediate validation steps and use small samples to test transformations.

### 3 - Destination: Lakehouse Bronze

1. Configure the sink target as the Lakehouse `Contoso_Lakehouse` → select schema → create table (e.g., `[bronze].[sales]`). Remember to enable the advanced option `Navigate using full hierarchy` to access schema/table hierarchy. Repeat for other datasets.
2. Run the Dataflow in validation mode and then in production.

 ![DF](/img/dfgen22.png)
 ![DF](/img/dfgen23.png)
 ![DF](/img/dfgen24.png)
 ![DF](/img/dfgen25.png)
 ![DF](/img/dfgen26.png)
 
### 4 - Verify and document

1. Open the Lakehouse and review each table (for example `[bronze].[sales]`).
2. Verify record counts, expected columns, and column formats (dates, numeric types).
3. Save execution logs and screenshots for evidence.

 ![Bronze tables](/img/tablas_bronze.png)

---

## Key validations
- Source vs. target validation
- Ensure no required columns were accidentally removed
- Nulls and errors handled and formats normalized

## Suggested next steps (optional)
- Automate using a pipeline (schedule) for periodic ingestions.
- Implement data quality checks before moving to Silver.

