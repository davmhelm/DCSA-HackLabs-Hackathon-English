
# 🏆 Challenge 2: Intermediate Transformation and Exploratory Analysis in Microsoft Fabric (Silver Layer)

📖 Scenario
Contoso aims to **assess data quality** before building predictive and analytical models.
The data team must **transform and analyze data** coming from the **Bronze** layer to produce a refined intermediate version in the **Silver** layer.

---

### 🎯 Mission
To complete this challenge you should:

✅ Create a **Silver** table from cleaned data in **Bronze**.
✅ Apply **intermediate transformations** that improve structure and consistency.
✅ Perform **exploratory analysis** using grouping and machine learning (ML) techniques (for example: customer segmentation by score).
✅ Prepare data for the **semantic modeling (Gold)** stage.

---

## 🚀 Step 1: Build Silver tables from Bronze
💡 *Why?* The Silver layer is the foundation for intermediate transformations and analysis, preparing data for downstream analytical modeling.

1️⃣ Access the **Lakehouse** in your Microsoft Fabric workspace.
2️⃣ Use a **notebook** (preferred) with Spark dataframes for Silver or a **Dataflow Gen2** if you prefer, to read Bronze data.
3️⃣ Apply additional cleans (for example: format corrections, standardize column names, derive new columns).
4️⃣ Store these more curated versions as **Silver** tables.

✅ **Expected result:** Bronze data is refined and available in Silver for more advanced Gold-layer transformations/aggregations.

---

## 🚀 Step 2: Apply intermediate transformations
💡 *Why?* These transformations create analytical views and facilitate modeling and segmentation.

1️⃣ Create a **Fabric notebook** targeting the Gold layer.
2️⃣ Apply transformations that add analytical value, for example:
   - 📊 **Aggregations:** Identify the **highest credit score per customer**.
   - 🏷️ **Product profiles:** Classify products by category or sales level.
3️⃣ Create new columns or metrics for downstream analysis (e.g., average purchase amount, risk levels).

✅ **Expected result:** Silver tables contain useful transformations ready for exploratory analysis, modeling or segmentation.

---

## 🚀 Step 3: Perform exploratory ML analysis (Credit Score dataset)
💡 *Why?* **Machine Learning (ML)** techniques help evaluate distributions and similarities in the data, revealing patterns. **Note:** If you prefer not to use ML, replace this step with another exploratory analysis in Silver.

For Credit Score and Products:

1️⃣ Use built-in ML functions or PySpark MLlib / scikit-learn libraries in a notebook.
2️⃣ Implement a **K-Means** algorithm (or another clustering approach):
   - 🎯 Cluster customers or products by similar numeric features.
   - 🔍 Analyze variable relationships within each cluster.
3️⃣ Persist the final table versions to the **Lakehouse [Silver]**.

✅ **Expected result:** A segmentation of your customer data and deeper understanding of behavior. If you skip ML, develop an alternate analysis that reveals new insights.

Apply the same preparations for `products` and `transactions` tables so they are ready for Gold-layer analytics.

---

## 🚀 Step 4: Prepare tables for semantic modeling (Gold)
💡 *Why?* Final Gold-table preparation is the last step before building analytical models or business dashboards.

1️⃣ Adjust column names, data types and primary keys required for modeling; remove unnecessary columns.
2️⃣ Save final table versions in the **Lakehouse [Gold]** or publish them as sources for the Gold layer.

✅ **Expected result:** Data is ready for consumption in Gold by BI tools or advanced analysis models.

---

## 🏁 Final Checkpoints

✅ Were Silver tables created from Bronze?
✅ Were intermediate transformations applied (aggregations, calculations, profiles)?
✅ Was a segmentation model (KMeans) implemented and analyzed, or was data prepared for segmentation?
✅ Are the data ready for Gold-layer usage?
✅ Were transformations and exploratory analysis results documented?

---

## 📝 Documentation

- [Notebook Transformations and ML](https://learn.microsoft.com/es-es/fabric/data-engineering/how-to-use-notebook)


💡 *Tip:* Keep a record of model parameters and results, as they will be important for the next challenge: **semantic modeling**. 🚀


