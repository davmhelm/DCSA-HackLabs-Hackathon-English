<p align="center">
 
  <img src="/img/fabric.png" alt="Microsoft Fabric" width="90"/>
  &nbsp;&nbsp;&nbsp;
  <img src="/img/ai-foundry.png" alt="Foundry" width="90"/>
</p>


# 🧠 AI Fabric Hackathon

## 🎯 Hackathon Objectives

By the end of this hackathon, participants will be able to:

- Prepare, transform, and enrich financial, retail, and transactional data using **Microsoft Fabric**, applying the **medallion** pattern to structure analytic value layers.
- Ingest data from core systems, external sources, and APIs using **pipelines, notebooks and Fabric native connectors**.
- Design robust **semantic models** that enable consumption by analysts, auditors, and intelligence systems.
- Monitor and optimize capacity consumption in **Fabric**, applying key metrics for operational governance and resource efficiency.
- Build **AI agents** with **AI Foundry** for predictive analysis, fraud detection and generation of financial insights.
- Orchestrate multi-agent flows and data processes, enabling intelligent automation in banking and insurance scenarios.
- Visualize **strategic insights** with **Power BI in Microsoft Fabric**, enabling interactive dashboards for data-driven decisions.

**Bonus**
- Apply **security and governance controls** for sensitive data by configuring roles, permissions and policies in Fabric workspaces.
- Integrate **Microsoft Purview** for traceability, classification and regulatory compliance, strengthening data governance in regulated environments.




# Agenda


| Day  | Activity                                                                  | Type   |
|------|---------------------------------------------------------------------------|--------|
| Day 1 | Data preparation (structuring, cleansing, and profiling)                 | Challenge   |
| Day 1 | Data ingestion from internal and external sources                        | Challenge   |
| Day 1 | Data transformation using notebooks and pipelines                        | Challenge   |
| Day 1 | Data enrichment and semantic model creation                              | Challenge   |
| Day 1 | Round Table: Q&A with experts and participants                           | Challenge   |
| Day 1 | Day wrap-up and summary                                                  | Wrap-up |
| Day 2 | Building an AI Foundry agent for predictive analytics                    | Challenge   |
| Day 2 | Multi-agent orchestration using pipelines and triggers                   | Challenge   |
| Day 2 | Fabric security: roles, objects, and workspaces (optional)               | Challenge   |
| Day 2 | Value session: Q&A on adoption, impact, and next steps                   | Wrap-up |
| Day 2 | Closing session and awards presentation                                  | Wrap-up |


# Architecture
![Architecture](img/architecture.png)


# 📖 Use Case Story
 
## "Contoso and Cross-Industry Data Intelligence in Action"
 
**Contoso**, an organization operating in the **financial and retail sectors**, faces the challenge of consolidating information from multiple sources to enable reliable analytics, intelligent automation, and data-driven conversational experiences. During this hackathon, participants assume the role of a **technical team** responsible for building a modern solution on **Microsoft Fabric**, testing their skills in a realistic, cross-industry environment.
 
### 🗃️ Data Sources
The scenario begins with three **JSON** datasets ingested from an **Azure Cosmos DB for NoSQL** database:
 
- **Credit score dataset:** Customer information, payment behavior, and financial profiles
- **Retail product dataset:** Product availability, retail value, category, and brand information
- **Transaction dataset:** Customer purchases, purchase channels, interest rates, and locations


![Data Model](img/container_schemas.png)

 
### 🎯 Primary Objective
Transform, cleanse, and structure the datasets into an **enriched data model** that provides the foundation for creating **AI agents**. Participants will apply the **medallion architecture** (Bronze → Silver → Gold), ensuring data quality, traceability, and analytical value. The exercise is objective-driven: there is no single correct solution, and participants are encouraged to use different approaches.


### 📊 Semantic Model and Key Metrics
After the data has been structured in the **Gold layer**, participants will design a **Power BI semantic model** that supports analysis across key metrics such as:
 
- Average credit score by segment
- Retail value by category
- Product return rate by brand
- Monthly risk or sales trends
- Performance by channel
- Interest-free installment plan analysis
- Payment methods


### 🤖 Conversational Agents
Using **AI Foundry**, participants will create **agents** capable of interacting with data through **natural language** without exposing technical code. These agents will address automation challenges and orchestrate multi-agent workflows using **large language models (LLMs)**. They will connect to semantic models through **Fabric Data Agents**, supporting conversational queries such as:
 
- *"Which segment has the highest average credit score?"*
- *"Which products have the highest return rate?"*
- *"Is there a relationship between credit score and purchase amount?"*
- *"How do customers purchase products based on their credit profiles?"*
- *"Which product categories does each credit profile prefer?"*
 

### 📈 Visualization and Insights
Finally, the generated **insights** will be presented through **interactive Power BI dashboards**, enabling data-driven decision-making for both **financial and retail analysts**. This use case demonstrates a realistic and scalable adoption of **Microsoft Fabric** in hybrid environments, where **data intelligence** becomes a competitive advantage for Contoso by driving innovation, operational efficiency, and broader access to analytics (democratization of analytics).


---
 
# 🎯 Challenge Summary – From Insight to Decision
 
## 🏆 Challenge 00: Landing Zone Configuration and Data Preparation
 
**📖 Scenario:** Contoso must prepare its Microsoft Fabric environment, connect data stored in Azure Cosmos DB, and establish a landing zone organized into data layers.

 
### 🎯 Key Goals:
- ✅ Create an Azure Cosmos DB for NoSQL account and load the JSON datasets (financial, retail, and transaction data)
- ✅ Configure a Microsoft Fabric workspace with a layered structure
- ✅ Establish a connection between Azure Cosmos DB and Fabric
- ✅ Create a Lakehouse using the medallion architecture (Bronze, Silver, and Gold)
- ✅ Explore and validate the JSON data structures


### 🚀 Deliverables:
- Azure Cosmos DB configured with data containers
- Fabric workspace with a Lakehouse structured into layers
- Documentation of the planned data flow

---
 
## 🏆 Challenge 01: Data Ingestion from Cosmos DB into Microsoft Fabric (Bronze Layer)
 
**📖 Scenario:** Consolidate Contoso's operational data in Microsoft Fabric by ingesting it from Azure Cosmos DB into the Bronze layer and applying basic data cleansing.
 
### 🎯 Key Goals:

- ✅ Implement ingestion from Azure Cosmos DB using Dataflow Gen2
- ✅ Apply basic data cleansing, including handling null values, removing unnecessary columns, and normalizing data
- ✅ Validate the data load and schema in the Bronze layer
- ✅ Prepare the data for advanced transformations
 
### 🚀 Deliverables:

- Functional Dataflow Gen2 with basic transformations
- Bronze tables containing cleansed and structured data
- Validation of ingested-data integrity
 
---
 
## 🏆 Challenge 02: Intermediate Transformation and Exploratory Analysis (Silver Layer)
 
**📖 Scenario:** Assess data quality and create an optimized intermediate representation in the Silver layer by applying advanced transformations and exploratory analysis with machine learning.
 
### 🎯 Key Goals:

- ✅ Create Silver tables with intermediate transformations
- ✅ Apply aggregations and analytical metrics, such as customer credit scores, product profiles, and transactions by channel
- ✅ Perform exploratory analysis using K-means clustering or another preference-modeling technique; non-predictive analysis may be used if machine-learning experience is limited
- ✅ Prepare data for semantic modeling in the Gold layer
 
### 🚀 Deliverables:

- Silver tables containing transformations, predictions, and business metrics
- Clustering analysis with segmentation insights, or an equivalent analysis
- Optimized data ready for the Gold layer
 
---
 
## 🏆 Challenge 03: Semantic Model, Data Agent, and Business-Value Dashboard (Gold Layer)
 
**📖 Scenario:** Enable business analytics through a robust semantic model, a conversational Data Agent, and an interactive dashboard that answers key business questions.
 
### 🎯 Key Goals:

- ✅ Design a Gold semantic model with relevant measures and relationships; normalized or denormalized models may be used
- ✅ Create a Data Agent connected to either the semantic model or the Lakehouse Gold tables
- ✅ Develop a Power BI dashboard with business-value visualizations
- ✅ Validate answers to business questions using Copilot
 
### 🚀 Deliverables:

- Semantic model with key measures, such as `total_retail_value` and `available_products`
- Functional Data Agent for natural-language queries
- Published Power BI dashboard with strategic metrics
 
---
 
## 🏆 Challenge 04: Creating a Conversational Agent in AI Foundry
 
**📖 Scenario:** Enable analysts to interact with data through natural language by creating an Azure AI Foundry agent integrated with the Fabric semantic model.
 
### 🎯 Key Goals:

- ✅ Design a conversational AI Foundry agent integrated with Fabric
- ✅ Connect the agent to the Data Agent associated with the Gold semantic model
- ✅ Configure intents and prompts for realistic business questions
- ✅ Validate natural-language answers that do not expose technical code
- ✅ Publish the agent for analyst use
 
### 🚀 Deliverables:

- Functional AI Foundry conversational agent connected to the Fabric Data Agent
- Intent configuration for frequently asked business questions
- Complete integration with the Fabric semantic model
- Validation of natural-language answers
 
---
 
## 🏆 Challenge 05: Multi-Agent Orchestration and Collaborative Workflows
 
**📖 Scenario:** Design and document a multi-agent workflow that coordinates ingestion, analysis, and execution to automate complex tasks and adapt dynamically to changing scenarios.
 
### 🎯 Key Goals:

- ✅ Define three specialized agents [Sales Analyst, Credit Analyst, and Research Analyst] and one synthesizer agent [Strategy Advisor]; these roles may be adapted to the selected scenario
- ✅ Design an orchestrated workflow
- ✅ Simulate business scenarios and validate agent behavior
- ✅ Document the design to support reproducibility and scalability
 
### 🚀 Deliverables:

- Architecture containing three specialized agents with defined roles and one synthesizer agent
- Orchestrated workflow
- Business-scenario simulations
- Complete documentation of the multi-agent design
 
---
 
## 📚 Resources and Documentation
 
### 🔗 Reference Links:
- [Microsoft Fabric](https://learn.microsoft.com/fabric/)
- [Azure AI Foundry](https://learn.microsoft.com/azure/ai-foundry/)
- [Power BI Embedded](https://learn.microsoft.com/power-bi/)
- [Azure Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/)
 
### 🎯 Next Steps:
After completing these challenges, you will have built a complete solution that moves **from insight to decision** by implementing:

- ✅ An end-to-end data pipeline using the medallion architecture
- ✅ A robust semantic model for business analytics
- ✅ Conversational agents that broaden access to data
- ✅ Intelligent, dynamic orchestration for process automation

