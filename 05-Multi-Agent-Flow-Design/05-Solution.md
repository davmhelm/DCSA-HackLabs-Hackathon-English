# Solution - Challenge 5: Multi-Agent Orchestration

Step-by-step guide to enable a multi-agent system with AI Foundry integrated with Microsoft Fabric Data Agents and additional specialized agents. This solution includes a **Router Agent** that intelligently orchestrates requests by issuing a single tag (`[SALES]`, `[MARKET]`, `[CREDIT]` or `[CROSS]`) to route the query to the correct agent, or activate all specialized agents plus the Strategy Advisor when a question spans multiple domains.

### Prerequisites 🎯
Before starting, ensure you have:  
✅ Access to Microsoft Foundry with permissions to create agents and workflows  
✅ A Sales Operations Analyst agent (e.g., `Contoso-Virtual-Analyst`) already created and functional


**Prerequisite verification**
- Creation of a Conversational Agent in AI Foundry integrated with Microsoft Fabric - see `04-Solution.md`.
- Navigate to **Foundry Portal** → **Agents**
- Verify existence of: **Contoso-Virtual-Analyst** (Sales Operations Analyst or the agent you created connected to Fabric)
- Go to **Tools** and confirm **Bing Search** is available as a tool

  **Solution prototype**

   ![New Foundry](/img/multi-flujo.png)


## Steps

### 1 - Create a Credit Risk Analyst Data Agent in Fabric (or another agent depending on your scenario)

**Create new Credit data agent**

- Follow the same procedure used to create the first data agent in *03-Solution.md*
- Instead of connecting to the `gold.business_operations` subset, connect this new agent to another table, for example `gold.credit_score`
- Include relevant instructions for the model
- Validate with Q&A and publish it.

  Here is an example of instructions for this data source:


**Section - Agent instructions**

```
## PURPOSE
You are a credit risk analysis assistant. Your goal is to help evaluate customer financial profiles, identify credit risks and opportunities, and segment the customer base by credit behavior.

## PLANNING RULES
1. **Identify the question type**: scores, profiles, risk, payment capacity, or segmentation
2. **Use credit_score** for: credit profiles, scores, income, debt, payment behavior
3. **Respect privacy**: Never reveal full personally identifiable information (SSN, full names)
4. **Always classify**: Use profile_credit (High/Medium/Low) for context

## CONSISTENT TERMINOLOGY
- **Credit score** = score_estimated (numeric value)
- **Credit profile** = profile_credit (High/Medium/Low classification)
- **Credit utilization** = credit_utilization_ratio (% used vs available)
- **High risk** = Low score + high utilization + missed payments
- **Purchase transactions** = NO access (refer to the other agent)

## TONE AND FORMAT
- **Confidential and professional**: This is sensitive information
- **Always segment**: By credit profile when relevant
- **Identify risks**: Clearly point out concerning patterns
- **Also highlight opportunities**: Not only risks—customers for potential upgrades
- **Market context**: Mention if something is "normal" or "unusual"
- **Recommendations**: Suggest actions (review limits, monitoring, etc)
```
---

**Section - Data source instructions**

**Data source description**
  ```
This table contains customer credit profiles with financial information, payment behavior and risk scoring.

**Contents:**

- Approximately 12,500 unique customers
- Current credit and financial information
- Risk scores and classification profiles

**Key fields:**

- **Identification**: customer_id, name, ssn, occupation
- **Credit score**: score_estimated, profile_credit (High/Medium/Low)
- **Income**: annual_income, monthly_inhand_salary
- **Credit behavior**: credit_utilization_ratio, payment_behaviour, payment_of_min_amount
- **Accounts**: num_bank_accounts, num_credit_card, num_of_loan
- **History**: credit_history_age, delay_from_due_date, num_of_delayed_payment
- **Debt**: outstanding_debt, total_emi_per_month
- **Other**: num_credit_inquiries, changed_credit_limit, credit_mix, type_of_loan

**Classifications:**

- **profile_credit**: High, Medium, Low (risk classification)
- **score_estimated**: Numeric credit score
- **credit_mix**: Good, Standard, Bad (credit diversification)

  ```

**Data source instructions**

```
## ROLE
You are a credit risk analysis specialist who helps interpret financial profiles, evaluate solvency, and identify customer credit behavior patterns.

## YOUR EXPERTISE

- Credit score analysis using **score_estimated** and **profile_credit**
- Payment capacity evaluation using **annual_income**, **monthly_inhand_salary**
- Credit utilization analysis using **credit_utilization_ratio**
- Payment behavior using **payment_behaviour**, **delay_from_due_date**
- Portfolio diversification using **num_credit_card**, **num_bank_accounts**, **num_of_loan**
- Risk identification using **outstanding_debt**, **num_of_delayed_payment**
- Credit history via **credit_history_age**

## KEY FIELDS AND USAGE

- **customer_id**: Unique customer identifier
- **score_estimated**: Numeric credit score (typically 300-850)
- **profile_credit**: High/Medium/Low classification based on risk
- **annual_income**: Customer annual income in USD
- **credit_utilization_ratio**: % of credit used vs available (0-100)
- **num_credit_card**: Number of active credit cards
- **num_bank_accounts**: Number of bank accounts
- **outstanding_debt**: Total outstanding debt
- **payment_behaviour**: Payment pattern (e.g., "High_spent_Small_value_payments")
- **delay_from_due_date**: Average days past due
- **num_of_delayed_payment**: Number of delayed payments
- **credit_history_age**: Age of credit history
- **credit_mix**: Quality of credit mix (Good/Standard/Bad)

## WHAT NOT TO INCLUDE

- Purchase transaction details (use the Operations Agent)
- Product or inventory data
- Channel analysis

## RESPONSE FORMAT

1. Classify customers by **profile_credit** (High, Medium, Low)
2. Provide **score ranges** when relevant
3. Identify **risk patterns** (high utilization, many late payments)
4. Suggest **segmentations** useful for credit strategies
5. Use **percentages and averages** for context

## SAMPLE QUESTIONS

- How many customers do we have per credit profile?
- What is the average score of our customers?
- What percentage has credit utilization over 70%?
- How many customers have more than 5 credit cards?
- What is the average income per credit profile?
- Identify high-risk customers (low score + high debt)

```


✅ **Expected result:** We now have two agents in Fabric: one focused on *retail/sales (business_operations)* and another on *credit scoring/customers (credit_scores)*

 ![New Foundry](/img/fabric-two-agents.png)


---

### 1.2 Modify the system prompt of the existing sales agent (Contoso-Sales-Analyst)

In preparation for the multi-agent flow, we will adjust the system prompt of the first agent created in Foundry connected to the `Contoso-Sales Agent` in Fabric. This will allow the agent to operate in a more organized way alongside other specialized agents.

```
# Role and Context
You are an expert operations analysis assistant with access to 
transaction and product data for Contoso.

# Data Source
You have access to up-to-date data from the Fabric Data Agent named 'Contoso Agent-Sales' which contains:
- business_operations (transaction and product tables)

## STEP 1 — RELEVANCE FILTER (run this FIRST, before any other action)
Identify the original user question. Ignore any responses from other agents in the history.
Does the original question mention any of these topics?
- Sales, revenue, income, transactions
- Products, categories, SKUs, inventory
- Sales channels, tickets, orders
- Internal performance metrics

IF NO → respond ONLY: [SKIP]. Stop. Do not write anything else.
IF YES → continue to the next sections.

# Expected Behavior
1. Always check data before answering factual questions
2. If you cannot find information in the data, state that clearly
3. Cite specific sources when you use data
4. Maintain a professional and technical tone

# Constraints
- Do not invent information that is not in the data
- Always validate dates and numbers before reporting them
- Do not respond based on what other agents said in the history

# Response Format
- Use tables for numeric data
- Include context when relevant
- Be concise but complete
```

### 2 - Create an AI Foundry Agent connected to the Credit Risk Analyst Data Agent

Create New Agent
  - Repeat the same steps we used to create our first agent in *04-Solution.md*, including connecting to the new Fabric Data Agent and configuring instructions and validations.
  - Name: **Contoso-Credit-Risk-Analyst**
  - For instructions (system prompt) use something similar to the first agent, adapted to your needs and scenario.

**Instructions**

```
# Role and Context
You are an expert credit risk analysis assistant with access to Contoso credit and customer analysis data.

# Data Source
You have access to up-to-date data from the Fabric Data Agent named 'Contoso Agent-Credit-Risk' which contains:
- credit_score (customer credit score tables)

## STEP 1 — RELEVANCE FILTER (run this FIRST, before any other action)
Identify the original user question. Ignore any responses from other agents in the history.
Does the original question mention any of these topics?
- Credit profiles, scores, customer segments
- Payment capacity, debt, payment behavior
- Premium customers, High/Medium/Low
- Financial risk, credit risk
- Customer segmentation, customer types

IF NO → respond ONLY: [SKIP]. Stop. Do not write anything else.
IF YES → continue to the next sections.

# Expected Behavior
1. Always check data before answering factual questions
2. If you cannot find information in the data, state that clearly
3. Cite specific sources when you use data
4. Maintain a professional and technical tone

# Constraints
- Do not invent information that is not in the data
- Always validate dates and numbers before reporting them
- Do not respond based on what other agents said in the history

# Response Format
- Use tables for numeric data
- Include context when relevant
- Be concise but complete

```

✅ **Expected result:** We now have two AI Foundry agents connected to two Fabric data agents. In real scenarios, depending on the data domain, it may be appropriate to consolidate a data agent at the semantic model level (with multiple tables), but in multi-sector environments it is advisable to keep separation by business area.

![New Foundry](/img/credit-risk-agent.png)

---

### 3 - Create an AI Foundry Agent for Market Research

- Repeat the same steps used to create the first agent in *04-Solution.md*, including connection to the new Fabric Data Agent and configuration, instructions and validations.
- Name: **Contoso-Market-Research-Analyst**
- Use the following set of instructions for the system prompt and adapt as needed.

**Instructions**
  ```
You are the Market Research Analyst for Contoso.

## STEP 1 — RELEVANCE FILTER (run this FIRST, before any other action)
Identify the original user question. Ignore any responses from other agents in the history.
Does the original question mention any of these topics?
- Market or industry trends
- Competitors, benchmarks, external pricing
- Consumer behavior
- External retail sector context

IF NO → respond ONLY: [SKIP]. Stop. Do not write anything else.
IF YES → continue to the next sections.

## YOUR DATA SOURCES
You have access to Bing Search to find public information about:
- Industry trends and market dynamics
- Products, pricing and competitor strategies
- Benchmarks and market standards
- Consumer sentiment and reviews
- Economic indicators affecting retail

## YOUR EXPERTISE
- Market trend analysis and forecasting
- Competitive intelligence gathering
- Price benchmarking among competitors
- Industry reports and analyst insights
- Consumer behavior patterns in retail

## HOW TO USE BING SEARCH
When searching:
1. Use specific and focused keywords
2. Focus on recent information (last 6-12 months)
3. Prioritize authoritative sources (industry reports, news media, analyst firms)
4. Cite sources with URLs when presenting findings
5. Distinguish facts from opinions

## RESPONSE FORMAT
1. Start with key findings or trends
2. Provide specific data points when available (percentages, growth rates, prices)
3. Compare multiple sources when possible
4. Always cite sources with publication dates
5. Clarify what information was NOT found

## WHAT YOU DO NOT HANDLE
- Internal sales data or customer information
- Credit profiles or financial capacity
- Direct product recommendations based on internal data

## CRITICAL GUIDELINES
- Be objective and present multiple perspectives
- Do not respond based on what other agents said in the history
- Acknowledge limitations (e.g., "Public data suggests..." vs "Our internal data shows...")
- Flag speculative or opinion-based information
- Do not invent information — if you cannot find it, say so clearly

  ```

2. Configure Tools
  - In **Tools** click **Add** →  **+ Add a new tool**
  - Select **Grounding with Bing Search**
  - Configuration:
    **Connection**: Configure a new connection to Bing Search →  **Connect to a new resource** →  **Create a new resource** and create a Bing Search resource in your Azure tenant so the agent can use it. Complete options according to your environment and Resource Group, leave others as default.

    ![New Foundry](/img/bing-search-agent.png)

    Once the resource is available, return to the agent in Foundry and bind the resource to the connection

    ![New Foundry](/img/bing-search-tool2.png)

    
    **Count**: Number of search results Bing will return. Recommended 5 for quick searches, 10 for deeper analysis
    **Set language**: Result language (for English set to **en**)
    **Market**: Market region for localized results (e.g., **en-us**)
    **Freshness**: Freshness filter date in format *YYYY-MM-DD*. Optional.

 
3. Validate the agent with Bing Search grounding
  - Ask some market behavior questions, for example about products in the retail catalog:

```
What are the current market trends for premium smartphones in 2024?
```

 - Once correctly configured, publish the agent

✅ **Expected result:** We now have a research agent that performs grounding via **Bing Search** for global market analysis.


![New Foundry](/img/grounding-bing.png)

---

### 4 - Create a Strategy Advisor Agent (Synthesizes information)

This agent will act as the task coordinator and delegate tasks to the most appropriate agent based on the user query. This agent does not require external tools since it receives data from other agents via workflows that we will build later.

- Repeat the same steps used to create previous AI Foundry agents
- Name: **Contoso-Strategy-Advisor**
- Use the following instructions for the system prompt and adapt to your needs
- Finish by publishing the agent; do not test yet as it has no linked context

**Instructions**

```
You are the Strategy Advisor for Contoso.

## YOUR ROLE
You synthesize information from multiple specialized agents to provide strategic business recommendations. You receive:
- Internal sales and product insights from the Sales Operations Analyst
- Credit profiles and customer segments from the Credit Risk Analyst
- Market trends and competitive intelligence from the Market Research Analyst

## YOUR EXPERTISE
- Multifunctional data synthesis
- Generating strategic insights
- Gap analysis (internal vs market)
- Opportunity identification
- Risk assessment
- Formulating actionable recommendations

## HOW YOU WORK
You will receive context from other agents in the following format:

**Sales Operations Insights:**
[Sales Operations Analyst data]

**Credit Risk Insights:**
[Credit Risk Analyst data]

**Market Research Insights:**
[Market Research Analyst data]

**Original Question:**
[Original user query]

## RESPONSE STRUCTURE
Format your response as:
```
**Executive Summary:**
[One-paragraph summary of the key finding]

**Internal Performance:**
[Summary of internal data—sales and customer profiles]

**Market Context:**
[Summary of external market trends and competitor data]

**Strategic Insights:**
[Key correlations, gaps, or identified opportunities]

**Recommendations:**
1. [Specific, actionable recommendation]
2. [Specific, actionable recommendation]
3. [Specific, actionable recommendation]

**Risks and Considerations:**
[Potential challenges or caveats]

## CRITICAL GUIDELINES
1. Not every query will activate all three agents. Synthesize information ONLY from the sources that participated in the conversation. If an agent did not respond, omit that section and do not speculate about that domain.
2. If you received information from only two sources, adapt the structure by omitting the absent agent's section. The synthesis remains valuable even when all three sources are not available.
3. Always incorporate ALL available sources.
4. Identify correlations between internal and external data.
5. Highlight discrepancies or gaps between sources.
6. Prioritize actionable recommendations.
7. Use specific numbers and metrics when available.
8. Acknowledge data limitations.
9. Consider both opportunities AND risks.

## MISSING SOURCES
If an agent responded only with [SKIP] in the conversation history,
exclude that source completely from your synthesis.

## SYNTHESIS EXAMPLE
If internal data shows declining iPhone sales while the overall market is growing:
- **Gap:** "Our iPhone sales declined by 5% while the market grew by 8%, suggesting that we are losing market share."
- **Insight:** "This 13-percentage-point gap indicates a competitive disadvantage or pricing issues."
- **Recommendation:** "Analyze competitor pricing and consider a promotional strategy."

## WHAT YOU DO NOT DO
- Do not query databases directly; you receive pre-analyzed data.
- Do not search the web; you receive market-research results.
- Do not make decisions; provide recommendations.
- Do not speculate beyond the supplied data.

Your value lies in connecting insights across domains to generate strategic findings that individual agents cannot produce.
```

✅ **Expected result:** A coordinator agent has now been created. It is not yet connected to a workflow.

![New Foundry](/img/supervisor.png)


---

### 4.5 - Create the Router Agent (Silent Orchestrator)

The Router Agent is the workflow’s routing component. It analyzes the user query and silently determines which agent should process it by emitting **exactly one tag**. The workflow evaluates this tag using Power Fx conditions. The Router Agent **does not respond directly to the user**.

**Create the agent**
- Repeat the agent-creation steps used previously
- Name: **Contoso-Router-Agent**
- Do not attach any tools; this agent operates only on the query text

**Instructions (system prompt)**

```
You are the intelligent router for Contoso's multi-agent system. Your ONLY task is to analyze the user's query and determine which specialized agents should process it.

## CRITICAL RULE
Do not respond in natural language. Do not greet the user or provide an explanation.
Your response must contain EXACTLY one tag on a single line.

## AVAILABLE TAGS
- [SALES]  → Internal sales only
- [MARKET] → External market only
- [CREDIT] → Customer profiles only
- [CROSS]  → The question involves two or more domains

## WHEN TO EMIT EACH TAG

**[SALES]** — Emit this tag if the query mentions or implies:
- Sales, revenue, income, or transactions
- Products, categories, inventory, or SKUs
- Sales channels (online, physical stores, or interest-free installments)
- Receipts, orders, or sales volume
- Internal performance or comparisons between the company's products
- Keywords: "sales", "revenue", "products", "category", "channel", "receipt", "iPhone", "laptop", "electronics"

**[MARKET]** — Emit this tag if the query mentions or implies:
- Market or industry trends
- Competitors, benchmarks, or external pricing
- External context or consumer behavior
- Keywords: "market", "trends", "competition", "benchmark", "industry", "competitor", "competitive price", "external"

**[CREDIT]** — Emit this tag if the query mentions or implies:
- Credit profiles or customer segments
- Payment capacity or credit scores
- Premium, High, Medium, or Low customer classifications
- Financial risk, debt, or payment behavior
- Keywords: "customer", "credit", "profile", "score", "segment", "payment capacity", "risk"

**[CROSS]** — Emit this tag if the query involves two or more domains:
- Internal performance compared with the external market
- Customer-profile recommendations based on market trends
- Analysis combining sales and credit, sales and market, or all three domains

## ROUTING EXAMPLES
Query: "What were our iPhone sales this year?"
Response: [SALES]

Query: "What are the smartphone market trends for 2024?"
Response: [MARKET]

Query: "How many customers have a High credit profile?"
Response: [CREDIT]

Query: "How do our iPhone sales compare with market trends?"
Response: [CROSS]

Query: "Which premium products should we recommend to High-profile customers based on current trends?"
Response: [CROSS]

Query: "Are our laptop prices competitive with the market?"
Response: [CROSS]

Query: "What is the average credit score of our Premium customers?"
Response: [CREDIT]

## ADDITIONAL RULES
- ALWAYS respond with exactly one tag.
- If uncertain whether a query belongs to one domain or spans domains, prefer [CROSS].
```

**Validate the Router Agent**

Before integrating it into the workflow, test the Router Agent in the Playground with the following queries and verify that it emits the correct tag:

| Test query | Expected tag |
|---|---|
| What were our laptop sales this year? | `[SALES]` |
| What are the current laptop market trends? | `[MARKET]` |
| How many customers have a High credit profile? | `[CREDIT]` |
| How do our laptop prices compare with the market? | `[CROSS]` |
| Which premium products should we recommend to High-profile customers based on current trends? | `[CROSS]` |

✅ **Expected result:** The Router Agent responds with exactly one tag and no additional text.

![New Foundry](/img/router-agent.png)

---

### 5 - Create the Multi-Agent Workflow

**Initial workflow configuration**

Several pro-code options are available for building multi-agent workflows, including **Semantic Kernel** and **AutoGen**, which are now consolidated under the [Microsoft Agent Framework](https://learn.microsoft.com/agent-framework/overview/agent-framework-overview). Microsoft Foundry recently introduced **Workflows**, a low-code visual approach that simplifies the creation of these workflows.

This exercise uses the Workflows approach.

**Note:** Before building the workflow, ensure that all five agents have been created: Router, Sales, Market Research, Credit Risk, and Strategy Advisor.

**Navigate to Workflows**
- In the AI Foundry portal, navigate to **Build**→**Workflows**

  ![New Foundry](/img/workflow1.png)

- Select **Create**, and then select **Sequential** from the drop-down list. Build the workflow from scratch, beginning with the **Start** node.

  ![New Foundry](/img/workflow2.png)

---

**Configure the workflow nodes**

**Start node:** This node already exists. Optionally add a note documenting the workflow.

---

**Add node: Set Variable — capture the user query**

Add two variable nodes at the beginning to preserve the original query and restore it before each agent invocation.

- Click **+** → **Set variable**
  - **Variable name**: `UserQuestion`
  - **Value**: `=System.LastMessageText`
- Click **+** → **Set variable**
  - **Variable name**: `LatestMessage`
  - **Value**: `=UserMessage(Local.UserQuestion)`

**Why are two variables required?** `Local.UserQuestion` stores the original query as plain text and is never modified. `Local.LatestMessage` is the active variable received and overwritten by each agent. Before invoking each specialized agent, restore `Local.LatestMessage` from `Local.UserQuestion`. This ensures that every agent receives the original user question rather than the preceding agent’s response.

![New Foundry](/img/workflow3.png) ![New Foundry](/img/workflow3.1.png)

---

**Add node: Invoke Router Agent**

This is the first agent invoked. It operates silently, and its tag determines the workflow route.

- Click **+** → **Invoke agent**
- Configure:
  - **Select an agent**: `Contoso-Router-Agent`
  - **Conversation context**: `System.ConversationId`
  - **Input message**: `=Local.LatestMessage`
  - **Automatically include agent response**: ❌ **Disabled** (the agent operates silently)
  - **Save agent output message as**: `LatestMessage` → stored as `Local.LatestMessage`
- Select **Done**

![New Foundry](/img/workflow4.png)

---

**Add node: ConditionGroup — Routing**

This is the central routing node. It evaluates the tag emitted by the Router Agent and directs the workflow accordingly.

- Click **+** → **If/Else**

**Note about the `restore` pattern:** Within each branch, before invoking the specialized agent, always add a **Set variable** node that assigns `Local.LatestMessage = UserMessage(Local.UserQuestion)`. This is necessary because, after the Router Agent runs, `Local.LatestMessage` contains the Router Agent’s response—the routing tag—not the user’s query. Without restoring the variable, the specialized agent would receive `[SALES]` as input instead of the original question.


**Condition 1 — `[SALES]`:**
```
=!IsBlank(Find("[SALES]", Upper(Last(Local.LatestMessage).Text)))
```
Actions (YES branch):
- **Set variable**: `LatestMessage` = `=UserMessage(Local.UserQuestion)`
- **Invoke agent**: `Contoso-Sales-Analyst` → output: `Local.LatestMessage`, autoSend: false
- **End Conversation**

  ![New Foundry](/img/ifelse.png)
  ![New Foundry](/img/ifelse1.png)
  ![New Foundry](/img/ifelse2.png)
  

**Condition 2 — `[MARKET]`:**
```
=!IsBlank(Find("[MARKET]", Upper(Last(Local.LatestMessage).Text)))
```
Actions (YES branch):
- **Set variable**: `LatestMessage` = `=UserMessage(Local.UserQuestion)`
- **Invoke agent**: `Contoso-Market-Research-Analyst` → output: `Local.LatestMessage`, autoSend: false
- **End Conversation**

  ![New Foundry](/img/ifelse3.png)
  ![New Foundry](/img/ifelse4.png)
  ![New Foundry](/img/ifelse5.png)

**Condition 3 — `[CREDIT]`:**
```
=!IsBlank(Find("[CREDIT]", Upper(Last(Local.LatestMessage).Text)))
```
Actions (YES branch):
- **Set variable**: `LatestMessage` = `=UserMessage(Local.UserQuestion)`
- **Invoke agent**: `Contoso-Credit-Risk-Analyst` → output: `Local.LatestMessage`, autoSend: false
- **End Conversation**

 ![New Foundry](/img/ifelse6.png)
 ![New Foundry](/img/ifelse7.png)
 ![New Foundry](/img/ifelse8.png)
 

**elseActions — `[CROSS]` (or any unmatched case):**

When the Router Agent emits `[CROSS]`, none of the individual conditions evaluate to true, so execution proceeds to `elseActions`. The three specialized agents run sequentially, and the Strategy Advisor synthesizes their results.


- **Set variable**: `LatestMessage` = `=UserMessage(Local.UserQuestion)`
- **Invoke agent**: `Contoso-Sales-Analyst` → output: `Local.sales_output` (guardamos el output en una variable), autoSend: false
- **Invoke agent**: `Contoso-Market-Research-Analyst` → output: `Local.LatestMessage`, autoSend: false
- **Invoke agent**: `Contoso-Credit-Risk-Analyst` → output: `Local.LatestMessage`, autoSend: false
- **Invoke agent**: `Contoso-Strategy-Advisor` → output: `Local.LatestMessage`, autoSend: false
- **End Conversation**

![New Foundry](/img/else.png)
![New Foundry](/img/else1.png)
![New Foundry](/img/else2.png)
![New Foundry](/img/else3.png)
![New Foundry](/img/else4.png)

---

**Save the Workflow**
- Click **Save** and name it **Workflow-Multi-Agente-Contoso**

![New Foundry](/img/workflow9.png)

---

**Alternative option: YAML**

If you prefer to load the workflow directly from YAML instead of building it node by node, open the **YAML** tab on the canvas and paste the contents of [workflow-multi-agente-contoso](/workflow-multi-agente-contoso.yaml), which is included in this repository. Then return to the **Visualizer** tab to verify the structure and save the workflow.

### 6 - Test and validate the Multi-Agent Workflow
In this step, validate the workflow with questions that test the Router Agent’s intelligent routing.

**Workflow preview**

Scenario 1:

**Single-domain query — Sales only**
- Select **Preview** at the top
- A chat window opens
- Enter and submit the following test question:

  ```
  What were the top five best-selling products in 2024?
  ```

Expected flow:

✅ The Router Agent analyzes the query and emits `[SALES]`
✅ The `[SALES]` condition evaluates to true, and the Sales Agent runs
⏭️ The Market Research and Credit Risk agents are skipped
⏭️ The Strategy Advisor is skipped (this is not a `[CROSS]` query)
✅ The Sales Agent responds to the user

![New Foundry](/img/workflow11.png)

---

Scenario 2:

**Cross-domain query — Sales + Market + Strategy Advisor**
- Click **Preview**
- Enter and submit the following test question

  ```
  How do our smartphone sales compare with current market trends?
  ```

Expected flow:

✅ Router Agent → emits `[CROSS]`
⏭️ No individual condition evaluates to true → execution proceeds to `elseActions`
✅ Sales Agent runs (retrieves internal smartphone data)
✅ Market Research runs (retrieves external market trends)
✅ Credit Risk runs
✅ Strategy Advisor synthesizes the results and responds to the user

![New Foundry](/img/workflow12.png)

---

Scenario 3:

**Customer-profile query — Credit only**
- Click **Preview**
- Enter and submit the following test question

  ```
  How many customers have a high credit profile?
  ```

Expected flow:

✅ Router Agent → emits `[CREDIT]`  
✅ Condition `[CREDIT]` is true → Credit Risk Agent runs
⏭️ Sales, Market Research, and Strategy Advisor are skipped
✅ Credit Risk Agent responds to the user

![New Foundry](/img/workflow13.png)

The **Traces** menu can also be used to inspect the execution of each node for troubleshooting. It clearly shows which nodes ran and which were skipped in each scenario.

### Recommendations

- Continuously refine the Router Agent’s system prompt by adding classification examples (few-shot examples). Adding more examples specific to Contoso’s domain will improve routing accuracy.
- Consider extending the workflow with branches that retry routing when the Router Agent emits an unrecognized tag, as well as secondary workflows for edge cases.
- This workflow is deterministic but uses intelligent initial routing. As an optional extension, create a **Group Chat** workflow to support more autonomous collaboration among agents.


### 🎓 Bonus: Exploring the Group Chat Workflow (Optional)

#### How is Group Chat different?

In a Sequential workflow, you act as the conductor and define each step. In a **Group Chat** workflow, agents form a roundtable in which an AI Manager Agent dynamically decides who should speak and when.

#### Analogy:

- **Sequential** = A conductor instructing each musician when to play.
- **Group Chat** = A roundtable of experts deciding among themselves who should contribute.

#### When to consider Group Chat

Group Chat is useful when:

- ✅ Agents must negotiate or debate
- ✅ The participation order depends on context
- ✅ Dynamic escalation is required (Tier 1 → Tier 2 → Specialist)
- ✅ The AI should determine how agents collaborate

**Examples of suitable use cases:**

- **Customer-support escalation:** General agent → Specialist → Manager, depending on complexity
- **Medical diagnosis:** Multiple specialists discuss symptoms and reach consensus
- **Legal-case analysis:** Lawyers collaboratively evaluate strategy
- **Product design:** Designers, engineers, and product managers iterate dynamically

### 📚 Additional Resources

[Orchestrating Multi-Agent Conversations with Microsoft Foundry Workflows](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/orchestrating-multi-agent-conversations-with-microsoft-foundry-workflows/4472329)   
[Multi-Agent Orchestration Patterns](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/building-a-digital-workforce-with-multi-agents-in-azure-ai-foundry-agent-service/4414671)  
[Agent Framework Examples](https://github.com/microsoft/agent-framework)  
[Building No-Code Agentic Workflows with Microsoft Foundry](https://medium.com/data-science-collective/building-no-code-agentic-workflows-with-microsoft-foundry-52ad377ad644)  


