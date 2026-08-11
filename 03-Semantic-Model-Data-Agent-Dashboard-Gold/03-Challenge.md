# 🏆 Challenge 3: Semantic Model, Data Agent and Value Dashboard in Microsoft Fabric (Gold Layer)

📖 Scenario
Contoso aims to **enable business analysis on trusted data**.
The data team should build a **semantic model**, create a **Data Agent connected to the model**, and design a **value dashboard** in Power BI to answer key business questions.

**Before starting, complete Challenges 0–2. Ensure Silver and Gold tables are prepared.**

---

### 🎯 Mission
After completing this challenge you will be able to:

✅ Design a **semantic model** linked to the **Gold** layer with measures, relationships and dimensions as needed.
✅ Create a **Data Agent** in Microsoft Fabric connected to that model.
✅ Build an **interactive Power BI dashboard** with value-driven visualizations.
✅ Validate that the model answers business questions correctly via Copilot or Power BI.

---

## 🚀 Step 1: Design the Semantic Model
💡 *Why?* The semantic model represents business measures, dimensions and relationships so users can query and analyze data easily.

1️⃣ In **Power BI or Microsoft Fabric**, design the **Gold semantic model** including:
   - 🔹 **Dimensions:** `Brand`, `Category`, `product_profile` (derived: e.g., Price > 100 => 'Premium'), `Availability`. You may use denormalized Gold tables instead of separate dimension tables if preferred.
   - 📏 **Key measures:** Examples (create your own measures as needed)
     - `total_price = SUM([Price])` (convert `Price` to numeric if necessary)
     - `available_products = COUNTIF([Availability] = "backorder")` (adjust based on actual JSON values)
       
2️⃣ Validate that measures and relationships are correctly configured.
3️⃣ If you have multiple tables (products, credit_score, transactions), create relationships using appropriate keys.

✅ **Expected result:** The Gold semantic model is complete and reflects Contoso's business logic.

---

## 🚀 Step 2: Validate the Model with Business Questions
💡 *Why?* Validating the model ensures natural-language queries in Copilot or Power BI return accurate results.

1️⃣ From the semantic model, create a new report and enable Copilot. Ask natural-language questions in **Copilot for Power BI**, for example:
   - 💬 “Which category has the highest average price?”
   - 💬 “What is the total price by brand?”
   - 💬 “How many products are on backorder?”
   - 💬 “Which product profile generates the most revenue?” (based on a derived measure)
     
2️⃣ If any answer is incorrect, adjust the model measures or relationships.

✅ **Expected result:** The model returns accurate and consistent answers to business questions.

---

## 🚀 Step 3: Design a Power BI Report/Dashboard
💡 *Why?* A dashboard visualizes key metrics and communicates business insights effectively.

1️⃣ In **Power BI (inside Fabric or Power BI Desktop)** create a new report connected to your Gold model.
2️⃣ Include visualizations such as:
   - 📊 **Average price by category (from products.json).**
   - 💰 **Products by brand and available stock.**
   - 📈 **Price trends by category.**
     
3️⃣ Customize colors, titles, and formatting for presentation.
4️⃣ Publish the dashboard to the appropriate workspace.

Optionally use *Power BI Copilot* to help generate report content.

✅ **Expected result:** The report/dashboard is published and ready to answer business questions.

---

## 🚀 Step 4: Create a Data Agent Connected to the Model
💡 *Why?* A **Data Agent** in Fabric lets users query data in natural language, enabling Copilot-driven exploration.

1️⃣ In Microsoft Fabric, create a new **Data Agent** item and connect it to your **Gold semantic model**.
2️⃣ Link it to tables such as `gold.products`, `gold.business_operations`, and `gold.credit_score` (created in Step 1).
3️⃣ Configure agent instructions to guide LLM reasoning. Provide guidance on how to respond and context about columns, metrics and aggregations.
4️⃣ Test natural language queries to validate agent responses.
   Optional: Create multiple Data Agents for different areas (Products Agent, Credit Score Agent, etc.).
   

✅ **Expected result:** The Data Agent is connected to the model and supports interactive, strategic queries about the business context.

---

## 🏁 Final Checkpoints

✅ Was the semantic model designed with appropriate measures, relationships, and dimensions?
✅ Does the model respond correctly to business questions in Copilot or Power BI?
✅ Was a Data Agent connected and tested against the model?
✅ Is the dashboard published and operational?

**Validate measures by importing a sample of the JSON files into Fabric or generating a synthetic dataset.**

---

## 📝 Documentation

- [Gold Semantic Model (Power BI)](https://learn.microsoft.com/fabric/data-warehouse/semantic-models)  
- [Update Semantic Model](https://learn.microsoft.com/power-bi/connect-data/data-pipeline-templates)
- [Create Data Agent](https://learn.microsoft.com/fabric/data-science/how-to-create-data-agent)
- [How to join tables in Fabric](https://learn.microsoft.com/fabric/data-engineering/tutorial-build-lakehouse)

💡 *Tip:* Document relationships, measures and data sources used. This model will serve as a foundation for building enterprise copilots and advanced predictive analytics. 🚀  

