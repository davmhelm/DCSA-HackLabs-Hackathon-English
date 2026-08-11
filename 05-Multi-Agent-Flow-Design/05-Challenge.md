# 🏆 Challenge 5: Agent Orchestration - Multi-Agent Flow Design

📖 Scenario

In the context of AI applied to business process automation, agent orchestration enables scalable decision-making through collaboration among role-specialized agents. Contoso, a retail and financial company, needs to combine multiple information sources to make informed strategic decisions.

In this challenge you will design and build a multi-agent flow that coordinates internal **sales** data, **customer** credit profiles, and external **market intelligence** to automate complex business analysis and deliver data-driven strategic recommendations.

In production scenarios these flows may involve not only analysis but also actions and executions; for this challenge the goal is to conceptualize role segmentation in agentic flows so more advanced solutions can be implemented later.

---

### 🎯 Your Mission
Upon completion you will be able to:

✅ Define **four specialized agents** with clear responsibilities (Sales, Credit, Market Research, Synthesizer) plus an **orchestrator (Router)** agent that directs the flow intelligently.
✅ Design a collaborative **orchestrated flow** using Foundry Workflows with conditional branches and error handling.
✅ Integrate internal data sources **(Microsoft Fabric)** with external tools (e.g., **Bing Search**).
✅ Validate complex business scenarios that require synthesis across multiple domains.
✅ Document the design for **replicability and scalability**.

---

### 🔗 Context
This challenge builds on previous work:

**Challenges 1-3:** You implemented the data pipeline

*Bronze*: Ingest from Cosmos DB
*Silver*: Transformations for products, credit and transactions
*Gold*: Curated or unified tables, e.g., business_operations and ML segmentations

**Challenge 4:** You configured specialized agents

**Sales Operations Analyst (Contoso-Virtual/Sales-Analyst)** connected to **business_operations** (or your own tables)

**This Challenge (5)**: Design agent orchestration with external intelligence
How do they collaborate to answer complex questions such as:

```
"How do our premium product sales compare to market trends?"
"Which products should we recommend to High-profile customers given current industry trends?"
"Are our prices in the Electronics category competitive according to the market?"
```

These questions require:

**Sales Agent** → Internal transaction and product data
**Credit Agent** → Customer profiles and purchasing capacity
**Research Agent** → Trends, competition, external benchmarks
**Orchestration** → Coordinate and synthesize all sources

---

### 📊 Available Data and Tools

**Specialized Agents**

0. Router Agent (to create)

- *Source*: None (analyzes the query text)
- *Expertise*: Classify user intent and perform intelligent routing
- *Behavior*: Runs silently, emits **one tag** — `[SALES]`, `[MARKET]`, `[CREDIT]` for single-domain queries, or `[CROSS]` when the question spans multiple domains
- *Typical queries*: Any user query — the router decides who responds

1. Sales Operations Agent (existing, from previous challenge)

- *Source*: **gold.business_operations** (Microsoft Fabric) or your Data Agent table
- Expertise: Revenue, channels, products, MSI, ticket segmentation
- Typical queries: "What is revenue by channel?", "Top selling products?"

2. Credit Risk Agent (to create)

- *Source*: **gold.credit_scores** (Microsoft Fabric)
- *Expertise*: Credit profiles (Low, Medium, High, Premium), scores, payment capacity
- *Typical queries*: "How many Premium customers?", "Average score by profile?"

3. Market Research Agent (to create)

- *Source*: **Bing Search API**
- *Expertise*: Industry trends, competitive analysis, market benchmarks
- *Typical queries*: "Trends for premium products?", "Competitor pricing?"

4. Strategy Advisor Agent (to create)

- Synthesizes and consolidates information from other agents to present to the user

**Orchestration Tools**

Foundry Workflows

- Visual designer for flow construction
- Invoke Agent nodes to call specialized agents
- Set Variable nodes to pass context between agents
- If/Else nodes for conditional branching
- YAML and Code views for advanced control


## 🚀 Step 1: Define Agent Roles and Responsibilities
💡 *Why?* Clear separation reduces coupling and improves scalability.

**Internal Sales Agent (Sales Operations Analyst)**
  - Analyze historical transaction data
  - Compute revenue, volume and channel metrics
  - Identify purchase patterns and top products
  - Segment by ticket (Low, Medium, High)

*Inputs*: Queries about sales, products, channels, MSI
*Outputs*: Quantitative metrics, rankings, distributions

**Credit Risk Agent**
  - Evaluate customer credit profiles
  - Identify segments by payment capacity
  - Analyze score distributions and financial ratios
  - Recommend financing strategies

**Market Research Agent**
  - Find current industry trends
  - Gather competitor information
  - Locate benchmarks and market standards
  - Provide external context for internal decisions

*Inputs*: Keywords about products, categories, markets
*Outputs*: Trend insights, competitor data, market context

**Synthesizer (Strategy Advisor)**
  - Receive outputs from specialized agents
  - Identify correlations between internal and external data
  - Synthesize information into actionable recommendations
  - Present insights in a structured format

*Inputs*: Outputs from the 3 specialized agents + original user query
*Outputs*: Integrated analysis with strategic recommendations

✅ **Expected result:** Clear definition of the 4 roles with inputs, outputs and success criteria.

---

### 🚀 Step 2: Design Orchestration and the Collaborative Flow
💡 *Why?* Orchestration defines who, when and how among agents and ensures traceability.

**Flow Architecture**

1️⃣ Trigger: User query via Playground
2️⃣ **Router Agent**: analyze the query and emit **one tag** — `[SALES]`, `[MARKET]`, `[CREDIT]`, or `[CROSS]`
3️⃣ Conditional routing:

![Multi](/img/multi-flujo.png)

4️⃣ Conditions and branches:
- If router emits `[SALES]` → only Sales Agent responds
- If router emits `[MARKET]` → only Market Research Agent responds
- If router emits `[CREDIT]` → only Credit Risk Agent responds
- If router emits `[CROSS]` → the 3 specialized agents run in sequence and the Strategy Advisor synthesizes

4️⃣ Feedback:
- Variables passed between nodes maintain context
- Strategy Advisor receives all prior insights
- Logs and traces enable flow debugging

5️⃣ Traceability:
- Each node logs its execution
- Variables stored at each step
- Workflow execution ID for full trace

✅ **Expected result:** Visual diagram of the flow in Foundry Workflows with connected nodes and clear conditions.

---

### 🚀 Step 3: Define Message Contracts and Data Schemas
💡 *Why?* Clear configurations ensure each agent performs its role effectively.

**Agent configuration**

**Router Agent (Orchestrator):**

- *Model*: **gpt-4o**
- *Tools*: **None** (analyzes query text)
- *Instructions*: [Classify user intent and emit internal routing tags]

**Sales Operations Analyst:**

- *Model*: **gpt-4o**
- *Tools*: **Fabric Data Agent [Contoso-Agent Sales] (business_operations)**
- *Instructions*: [Focus on internal sales metrics]

**Credit Risk Analyst:**

- *Model*: **gpt-4o**
- *Tools*: **Fabric Data Agent [Contoso-Agent Credit Risk] (credit_score)**
- *Instructions*: [Focus on profiles and credit capacity]

**Market Research Analyst:**

- *Model*: **gpt-4o**
- *Tools*: **Bing Search**
- *Instructions*: [Focus on trends and public information]

**Strategy Advisor:**

- *Model*: **gpt-4o**
- *Tools*: **None** (receives variables from other agents)
- *Instructions*: [Synthesize and generate strategic recommendations]

✅ **Expected result:** Configuration specification for each agent with model, tools and instructions.

---

## Step 4: Build the Workflow in Foundry
💡 Why? Visual implementation simplifies debugging and understanding the flow.

**Workflow components**

**Start Node:**
* Capture the user message in two variables: `Local.UserQuestion` (plain text) and `Local.LatestMessage` (formatted)

**Router Agent Node:**
* Invoke the Router Agent with the user query
* Emit a single routing tag silently (`Local.LatestMessage`)
* Do not send a user-facing response (`autoSend: false`)

**ConditionGroup Node:**
* Evaluate the tag emitted by the Router Agent
* If tag is `[SALES]`, `[MARKET]` or `[CREDIT]` → invoke that agent and finish
* If no single condition is true (`[CROSS]`) → go to `elseActions`

**elseActions (cross-domain case):**
* Restore `Local.LatestMessage` from `Local.UserQuestion`
* Invoke Sales, Market Research and Credit Risk in sequence
* Each agent appends its response to `Local.LatestMessage`
* The Strategy Advisor receives the full history and synthesizes

**End Node:**
* Return final response to the user
* Close the workflow

✅ Expected result: Functional workflow in Foundry with all nodes connected and configured.

---

## 🚀 Step 5: Validate Business Scenarios
💡 *Why?* Validation confirms the design solves real cases.

**Test Scenarios**

**Scenario 1: Market Comparison Analysis**
- **Query**: "How do our iPhone sales compare to market trends?"

Expected flow:
Sales Analyst → Internal iPhone sales
Market Research → Market trends for iPhone (Bing Search)
Strategy Advisor → Comparison and gap analysis

✅ Expected result: Insight on market position with recommendations

**Scenario 2: Segmented Recommendation**

- **Query**: "Which premium products should we recommend to High-profile customers given current trends?"

Expected flow:

Credit Risk → Identify High-profile customers
Sales Analyst → Premium products purchased
Market Research → Trends for premium products
Strategy Advisor → Recommendations based on all 3 sources

Expected result: List of recommended products with justification

**Scenario 3: Competitive Pricing**

- **Query**: "Are our laptop prices competitive according to the market?"

Expected flow:

Sales Analyst → Current laptop prices
Market Research → Competitor prices (Bing Search)
Strategy Advisor → Gap analysis and recommendations

Expected result: Competitiveness analysis with adjustment suggestions

✅ Expected result: Successful execution of the 3 scenarios with screenshots and analysis.

---

## 🚀 Step 6: Documentation and Continuous Improvement
💡 *Why?* What is not measured cannot be improved.

Documentation items

**Architecture:**

- Complete workflow diagram
- Description of each agent and its role
- Design decisions (why this flow)

**Configurations:**

- System prompts for each agent
- Configured tools
- Variables and their purpose

**Results:**

- Screenshots of successful runs
- Test scenario analysis
- Performance metrics (response time)

**Learnings:**

- What worked well
- What to improve
- Next steps for production

✅ Expected result: Complete document with architecture, configurations, results and learnings.

### 🏁 Final Checkpoints

✅ Are the 5 agents defined (Router + 3 specialized + Advisor) with clear roles and responsibilities?
✅ Does the Router Agent emit correct tags for different query types?
✅ Does the flow activate only the agents needed per query type?
✅ Is the Strategy Advisor invoked only when 2 or more agents participated?
✅ Are the 3 specialized agents configured in Foundry with appropriate tools?
✅ Is the workflow built visually in Foundry Workflows?
✅ Were the 3 business scenarios tested successfully?
✅ Does the documentation include diagrams, configurations and results?

---

### 💡 Tips and Recommendations

**Design:**
- Start simple (2 agents) and expand gradually
- Use descriptive variables (sales_insights, market_data)
- Document decisions while designing

**Implementation:**
- Test each agent individually before integration
- Use the Playground to validate prompts
- Review traces for debugging

**Validation:**
- Choose realistic queries that require multiple agents
- Analyze whether responses integrate sources well
- Identify gaps or improvements

## 📝 Documentation

-  [Build a Workflow in Microsoft AI Foundry](https://learn.microsoft.com/azure/ai-foundry/agents/overview)
-  [Tools in Foundry Agent Service](https://learn.microsoft.com/azure/ai-foundry/agents/concepts/workflow)
-  [Grounding with Bing Search](https://learn.microsoft.com/azure/ai-foundry/agents/how-to/tools-classic/bing-grounding?view=foundry-classic)
-  [Orchestrating Multi-Agent Conversations with Microsoft Foundry Workflows](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/orchestrating-multi-agent-conversations-with-microsoft-foundry-workflows/4472329)
-  [Multi-Agent Orchestration Patterns](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/building-a-digital-workforce-with-multi-agents-in-azure-ai-foundry-agent-service/4414671)
-  [Agent Framework Examples](https://github.com/microsoft/agent-framework)
-  [Building No-Code Agentic Workflows with Microsoft Foundry](https://medium.com/data-science-collective/building-no-code-agentic-workflows-with-microsoft-foundry-52ad377ad644)
  

