
# 🏆 Challenge 4: Create a Conversational Agent in AI Foundry with Microsoft Fabric Integration 🤖

📖 Scenario
Contoso wants its **analysts to interact with data using natural language**, without requiring technical knowledge of T-SQL or data modeling.
The goal is to create an **agent in Azure AI Foundry** that consumes the **semantic model connected to Fabric via a Data Agent**, enabling clear, understandable responses based on trusted data.

Fabric data agents can be exposed to other Microsoft AI tools such as Copilot Studio or AI Foundry. This allows us to orchestrate multi-agent flows where specialist agents take control of tasks and other agents coordinate the process. In this challenge we will expose our Fabric Data Agent inside another agent in Foundry powered by an OpenAI LLM. This LLM will act as a router to the Fabric Data Agent to retrieve data information and return it to the user.

The image below shows the workflow for this scenario.

![Foundry-Fabric](/img/foundry-data-agent.png)

---

Make sure you have completed the Semantic Model, Data Agent and Value Dashboard (Gold) challenge (see `03-Solution.md`). Also verify the following [prerequisites](https://learn.microsoft.com/en-us/fabric/data-science/data-agent-foundry#prerequisites).

### 🎯 Mission
After completing this challenge you will be able to:

✅ Design a **conversational agent in AI Foundry** integrated with Microsoft Fabric.
✅ Connect the agent to a **Data Agent** associated with the Gold semantic model.
✅ Configure intents and prompts aimed at real business questions.
✅ Validate that the agent responds in **natural language**, without showing code or technical syntax.
✅ Publish the agent for analysts to use in **Copilot, Power BI or AI Foundry**.

---

## 🚀 Step 1: Create the Agent in AI Foundry
💡 *Why?* The agent is the conversational interface that allows analysts to interact directly with semantic model data. From AI Foundry we can also orchestrate multi-agent flows where Fabric agents are exposed and combined with other agents for different tasks, enabling complex, multidisciplinary scenarios.

1️⃣ Open your **Azure AI Foundry** resource from your Azure subscription or sign in with your authorized user at [AI Foundry](https://ai.azure.com/). Preferably enable the new Foundry experience.

![New Foundry](/img/new_foundry.png)

2️⃣ Select your project → from the welcome menu → **Start building** → **Create agent** → in **Agent Name** enter a descriptive unique name, for example: `Contoso-Virtual-Analyst`.

![Foundry](/img/foundry-start.png)

3️⃣ In the agent menu → **Playground** → select the model you created as a prerequisite (**gpt-4o**).

![Foundry](/img/foundry-agent.png)

✅ **Expected result:** The agent is created and configured for conversational interaction.

---

## 🚀 Step 2: Connect the Agent to the Fabric Data Agent
💡 *Why?* The Data Agent is the link between AI Foundry and the governed data in Microsoft Fabric.

1️⃣ In the agent **Tools** or **Knowledge** section, configure the **Data Agent** created in the previous Fabric challenge.
2️⃣ Verify that the Data Agent is linked to the **Gold semantic model** or the tables needed for its work, such as:
   - `gold.business_operations`
   - `gold.credit_score`

3️⃣ Save the connection settings.

✅ **Expected result:** The agent can access the semantic model and query data in a controlled way.

---

## 🚀 Step 3: Configure Agent Behavior
💡 *Why?* Controlling tone and response style ensures a clear experience without technical language.

1️⃣ In the **Instructions** section, select:
   - “Natural language responses.”
   - “Hide code and technical syntax.”
   - “Do not show code or technical syntax (such as T-SQL).”
2️⃣ Enable explanatory responses so the agent justifies its answers with phrases like:
> “Based on model data, the average score in the high segment is 87 points.”

✅ **Expected result:** The agent communicates findings in natural language, without showing code or queries.

---

## 🚀 Step 4: Define Intents and Guidance Prompts
💡 *Why?* Intents help train the agent to understand the business questions it will receive.

1️⃣ Create intents that reflect Contoso’s analytical needs.
2️⃣ Suggested examples (adapt to your data context):

| **Intent / Theme** | **Guidance prompt (analyst question)** |
|--------------------|----------------------------------------|
| score_by_segment | “What is the average score by segment?” |
| returns_by_product | “Which products have the highest return rate?” |
| valuable_products_by_category | “Which category has the most valuable products?” |
| total_sales_by_brand | “What is the total commercial value by brand?” |

✅ **Expected result:** The agent understands business questions and responds contextually.

---

## 🚀 Step 5: Validate the Agent with Real Questions
💡 *Why?* Validation confirms the agent understands queries and correlations between tables.

1️⃣ Test directly in **AI Foundry** with questions like these (or based on your data model scenario):
   - “Which brand has the most available products?”
   - “What is the monthly risk trend?”
   - “Which product profile generates the most revenue?”

2️⃣ Verify that responses:
   - Are **clear and without code**.
   - Understand correlations between entities (for example, *credit score*, *transactions*, and *products*).
   - Come from metrics in the **connected semantic model**.

✅ **Expected result:** The agent answers complex questions coherently and based on model data.

---

## 🚀 Step 6: Publish and Enable the Agent
💡 *Why?* Publishing the agent makes it accessible to analysts and business teams within the Fabric environment.

1️⃣ Publish the agent from **AI Foundry**.
2️⃣ (Optional) If you have admin permissions in your M365 tenant, enable it for use in **Microsoft 365 Copilot or Microsoft Teams**.
3️⃣ Confirm the agent is published. You can test it in preview mode to see how it would appear in an application.

✅ **Expected result:** The agent is active and available for natural-language queries.

---

## 🏁 Final Checkpoints

✅ Was the agent created and configured correctly in AI Foundry?
✅ Is it connected to the Data Agent and Gold semantic model/tables?
✅ Were intents and prompts defined to align with business needs?
✅ Does the agent respond in natural language without showing code?
✅ Is it published and available?

---

## 📝 Documentation

- [AI Foundry Agent Setup](https://learn.microsoft.com/es-es/azure/ai-foundry/agents/environment-setup)
- [Connect to Fabric Data Agent](https://learn.microsoft.com/es-es/azure/ai-foundry/agents/how-to/tools/fabric?pivots=portal)
- [Official Reference - Create Fabric Data Agents](https://learn.microsoft.com/en-us/fabric/data-science/how-to-create-data-agent)
  

