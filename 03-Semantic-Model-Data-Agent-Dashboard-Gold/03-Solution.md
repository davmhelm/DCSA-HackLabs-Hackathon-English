# Solution Challenge 03 - Semantic Model, Data Agent and Value Dashboard

Step-by-step guide to ingest data from Azure Cosmos DB into the Bronze layer of the Lakehouse in Microsoft Fabric, apply initial cleaning and validate the results.

### Objective 🎯
- Design a semantic model in `Direct Lake` mode using Gold-layer tables that support the business scenario, creating useful measures and relationships.
- Build a `Data Agent` in Microsoft Fabric by connecting it to your semantic model and providing the LLM with instructions to respond appropriately and with semantic precision in natural language.
- Develop an `interactive Power BI Dashboard` manually or with the help of Power BI Copilot, including value-driven visualizations.
- Validate natural-language answers from `Power BI Copilot` and the `Data Agent`.

---

## Prerequisites

- Intermediate transformation, exploratory analysis (Silver) and Gold preparation (see `02-Solution.md`).


## Steps

### 1 - Design semantic model in Microsoft Fabric
From our `Lakehouse`, with all layers and fresh data ready, create a new semantic model in [Direct Lake](https://learn.microsoft.com/fabric/fundamentals/direct-lake-overview) mode:

1. In the Lakehouse main panel select `New semantic model`
2. In the new model panel, add a name for the model, e.g.: `Contoso-semantic-model` (note that Direct Lake is enabled by default).
3. Select the `Workspace` where the `Lakehouse` is located and proceed to select the Delta tables from the `Gold` layer to use in the model.

**Note**: In this solution we designed the Gold layer by joining *silver.transactions* + *silver.products* to create **gold.business_operations**, which enables purchase analysis by product and allows linking with *credit_score* to correlate customer segmentation by score with buying patterns. To avoid redundancy we did not include **gold.products** in the semantic model; if you prefer a different modeling strategy it is valid to include it.

The result is a new semantic model from which we can proceed to design our DAX measures and relationships (if we develop dimensional tables here, those would also be valid).

![Semantic](/img/semantic.png)

4. Once inside the semantic model, establish relationships between the relevant tables. In the toolbar select `Manage relationships` → `+ New relationship`.
5. In the new relationship menu select a table, for example: `business_operations` (join of transactions + products) and verify the key field `customer_id`.
6. Select the other table to join, in this case `credit_score`, and verify the key field `customer_id`. Configure cardinality according to your Gold-layer modeling; other options can remain default.
7. Click `Save` → `Close`.

Your tables are now related in the model.

![Semantic](/img/relationship.png)

The next step is to build some DAX measures to enable dashboard and report development and to be used by `Data Agents`.

8. Select the `business_operations` table in the model and choose `New measure` from the toolbar.
9. Enter the DAX expression in the formula bar and press `Enter`. The measure will be added to the model.
10. Repeat the process for each measure you want to include. Here are some example measures for this particular solution:

**Total Revenue**
```
Total Revenue = SUM(business_operations[amount])
```
**Ticket Promedio**
```
Avg Ticket = AVERAGE(business_operations[amount])
```
**Total Transacciones**
```
Total Transactions = COUNTROWS(business_operations)
```
**Clientes Activos**
```
Active Customers = DISTINCTCOUNT(business_operations[customer_id])
```
**Revenue por perfil crediticio**
```
Revenue by Credit Profile = 
CALCULATE(
    [Total Revenue],
    USERELATIONSHIP(business_operations[customer_id], credit_score[customer_id])
)
```
**% MSI (Meses sin Intereses)**
```
% MSI = 
DIVIDE(
    COUNTROWS(FILTER(business_operations, business_operations[is_msi] = TRUE)),
    COUNTROWS(business_operations),
    0
)
```
```
Revenue by Credit Profile = 
CALCULATE(
    [Total Revenue],
    USERELATIONSHIP(business_operations[customer_id], credit_score[customer_id])
)
```

**Revenue YTD (Year-to-Date)**
```
Revenue YTD = 
TOTALYTD(
    [Total Revenue],
    business_operations[transaction_date]
)
```

The result is a model with relationships and measures ready to be used.

![Model-ready](/img/model-ready.png)


### 2 - Validate the Model with Business Questions
Before building dashboards and reports, validate with Power BI Copilot that the model can provide business-context information in natural language about the data:

1. From the Fabric main menu on the semantic model item, choose `Create report` and in edit mode enable the Copilot icon, then ask questions in Copilot for Power BI. **Note:** Ensure the semantic model has the `Q&A - Turn on Q&A to ask natural language questions about your data` feature enabled so Copilot can work with the model. That option is in the model `settings`.

![QA](/img/qa_settings.png)

2. Once enabled, ask questions in the chat pane. Here are some examples:

💬 “Which category has the highest average price?”
💬 “What is the total number of transactions?”
💬 “Which product profile generates the most revenue?” (based on the derived measure)

3. If any answer is incorrect, adjust the model measures or relationships.

✅ Expected result: The model returns accurate and consistent answers to business questions. You can also start building visuals from these outputs.

![PBI Copilot](/img/pbi-copilot.png)



### 3 - Design a Value Dashboard
Dashboard design depends on organizational context and requirements. Power BI offers many options to customize and build corporate dashboards that answer business questions and support decision-making. For this particular dashboard we planned a multi-report layout; here is the UX reference diagram:


![Executive Summary](/img/executive_dash.png)


With this in mind, build the dashboard manually by configuring each report as needed.


![Executive Summary](/img/pbi-executive.png)


For this exercise you can also use Copilot to suggest content based on the data and automatically create visuals. From the report main menu try the following:

- Create a new report on the semantic model.
- From the report menu enable `Copilot` and click `Suggest content for a new report page`.
- Let the LLM analyze the semantic model context and propose the options it deems appropriate.
- When suggestions appear, choose one and click `+ Create` to generate a report using generative AI.

✅ Expected result: You have a new report created by Copilot; validate it and repeat with new suggestions to complete your dashboard.

![Cop](/img/copilot_pbi2.png)
![Cop2](/img/copilot_pbi3.png)

### 4 - Create a Data Agent
Now we will create our Data Agent.
1. In your **Fabric Workspace** create a new item: `→ New item → Data agent`.
2. Give your agent a name, e.g.: `Contoso-Business Operations Agent`. In this example we want an agent focused on transactions and products (retail).
3. In the new Data Agent panel configure:
   - **Data Source**: Click `+ Data source` or `Add data source` → find your Lakehouse → `Add` and select the `[gold.business_operations]` table. You can also connect semantic models or other native Fabric data sources.
  
![Cop](/img/data_agent_ops.png)

   - **Setup**: The goal here is to provide clear, concise instructions to the LLM so it can interpret business concepts using the semantic model and avoid ambiguities that lead to incorrect answers. Below is an example for *agent instructions* (system prompt) and *Data source instructions*:


**Section - Agent instructions**

```
## PURPOSE
You are a retail operations analytics assistant. Your goal is to help business users understand sales performance, products, channels, and purchase behavior.

## PLANNING RULES
1. **Identify the type of question**: sales, products, channels, temporal, or a combination
2. **Use business_operations** for: revenue, transactions, products, channels, MSI, temporal
3. **Do not speculate**: If you do not have the data, say so clearly
4. **Prioritize accuracy** over speed

## CONSISTENT TERMINOLOGY
- **Revenue** = sum of amount (not "ingresos" or "ganancias")
- **MSI** = Months Without Interest (interest-free financing)
- **Avg Ticket** = average amount per transaction
- **Channel** = channel (Online, Store, Mobile App, Call Center)
- **Credit profile** = NO access (refer to the other agent)

## TONE AND FORMAT
- **Professional but accessible**: Avoid unnecessary technical jargon
- **Numbers first**: Always include concrete figures
- **Context second**: Explain what the numbers mean
- **Bullets for lists**: Use bullet points for multiple items
- **Comparisons**: Whenever possible ("40% more than...")
- **Actionable insights**: End with "what to do with this"
```
---

**Section - Data source descriptions**

**Data source descriptions**
```
This table contains all sales transactions for 2024, including detailed information about products, sales channels, payment methods, and time dimensions.
**Contents:**
- Approved transactions
- Period: January through December 2024
- Total revenue
**Key fields:**
- **IDs**: transaction_id, customer_id, product_id
- **Product**: product_name, brand, category, price
- **Transaction**: transaction_date, amount, quantity
- **Payment**: payment_method, installments, is_msi, is_credit
- **Channel**: channel, store_location
- **Time**: year, month, quarter, year_month
- **Segments**: ticket_segment (High)
```

**Data Source Instructions**

```
## ROLE
You are a retail operations analyst who helps answer questions about sales, products, channels, and purchase behavior.

## YOUR EXPERTISE
- Analyzing revenue using the amount field
- Performance by channel (Online, Store, Mobile App, Call Center)
- Top products using product_name, brand, category
- MSI adoption using is_msi and installments
- Temporal trends with transaction_date, year, month, quarter
- Payment methods with payment_method and is_credit
- Segmentation with ticket_segment

## KEY FIELDS AND HOW TO USE THEM
- **amount**: To calculate total revenue, averages, sums
- **quantity**: To count units sold
- **channel**: To compare Online vs Store vs Mobile App vs Call Center
- **payment_method**: Credit, Debit, Cash
- **is_msi**: true = uses Months Without Interest, false = single payment
- **installments**: number of installments (1 = single payment, >1 = financed)
- **ticket_segment**: Low (<$500), Medium ($500-$1000), High (>$1000)
- **category**: Electronics, Kitchen Appliances, Fitness Equipment, etc.

## WHAT NOT TO INCLUDE
- Customer credit profile information
- Catalog products that were not sold
- Scores or risk analysis

## RESPONSE FORMAT
1. Always include **concrete numbers** (revenue, units, %)
2. **Compare** when relevant ("Online generates 40% more than Store")
3. Identify **top performers** (top 5-10)
4. Use exact field names in your explanations

## USEFUL QUERY EXAMPLES
- Total revenue: `SUM(amount)`
- Avg ticket: `AVG(amount)`
- Transactions by channel: `GROUP BY channel`
- MSI adoption: `WHERE is_msi = true`
- Top products: `GROUP BY product_name ORDER BY SUM(amount) DESC`
```

![Cop](/img/data_agent_ops2.png)


Optionally, provide example queries as part of the agent's `Example queries` instructions. Once configured, proceed to test the agent.


### 5 - Validation with natural-language questions
Now test an interaction with the agent by asking questions about this subset of the data:

💬 How much revenue did we generate in 2024?  
💬 Which channel generates the most sales?  
💬 Which are our top products?  
💬 Which categories are most profitable?  
💬 How do customers prefer to pay?  

![Cop](/img/data_agent_ops3.png)

✅ Expected result: You have a new Data Agent in Microsoft Fabric ready to answer questions and perform analyses on your organization's data.
