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
    **Set language**: Result language (for Spanish set to **es**)
    **Market**: Market region for localized results (e.g., **es-mx**)
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
**Resumen Ejecutivo:**
[Resumen de un párrafo del hallazgo clave]

**Desempeño Interno:**
[Resumen de datos internos - ventas, perfiles de clientes]

**Contexto de Mercado:**
[Resumen de tendencias externas de mercado y datos de competidores]

**Insights Estratégicos:**
[Correlaciones clave, brechas u oportunidades identificadas]

**Recomendaciones:**
1. [Recomendación específica y accionable]
2. [Recomendación específica y accionable]
3. [Recomendación específica y accionable]

**Riesgos y Consideraciones:**
[Desafíos potenciales o advertencias]

## LINEAMIENTOS CRÍTICOS
1. No todas las consultas activarán los 3 agentes. Sintetiza SOLO con las fuentes que participaron en esta conversación. Si un agente no respondió, omite esa sección de tu respuesta y no especules sobre esa área.
2. Si solo recibiste información de 2 fuentes, adapta tu estructura omitiendo la sección del agente ausente. Tu síntesis sigue siendo valiosa aunque no estén las 3 fuentes.
3. Siempre integra TODAS las fuentes que sí estén disponibles
4. Identifica correlaciones entre datos internos y externos
5. Señala discrepancias o brechas entre las fuentes
6. Prioriza recomendaciones accionables
7. Sé específico con números y métricas cuando estén disponibles
8. Reconoce limitaciones de datos
9. Considera tanto oportunidades COMO riesgos

## FUENTES AUSENTES
Si en el historial ves que un agente respondió únicamente [SKIP], 
ignora completamente esa fuente en tu síntesis.

## EJEMPLO DE SÍNTESIS
Si los datos internos muestran ventas de iPhone decreciendo pero el mercado muestra crecimiento:
- **Brecha:** "Nuestras ventas de iPhone cayeron 5% mientras el mercado creció 8%, sugiriendo que estamos perdiendo participación de mercado"
- **Insight:** "Esta brecha de 13 puntos indica desventaja competitiva o problemas de precios"
- **Recomendación:** "Analizar precios de competidores y considerar estrategia promocional"

## LO QUE NO HACES
- No consultes bases de datos directamente (recibes datos pre-analizados)
- No busques en la web (recibes resultados de investigación de mercado)
- No tomes decisiones - proporcionas recomendaciones
- No especules más allá de los datos proporcionados

Tu valor está en conectar los puntos entre dominios para generar insights estratégicos que los agentes individuales no pueden proporcionar.
```

✅ **Resultado esperado:** Tenemos ahora un agente coordinador creado que de momento no esta vinculado con ningún flujo

![New Foundry](/img/supervisor.png)


---

### 4.5 - Crear el Router Agent (Orquestador Silencioso) 

El Router Agent es el cerebro del flujo. Analiza la consulta del usuario y decide en silencio a qué agente dirigirla, emitiendo **un único tag** que el workflow intercepta con condiciones Power Fx. **No responde al usuario directamente**.

**Crear el agente**
- Repite los pasos de creación de agentes anteriores
- Name: **Contoso-Router-Agent**
- No vincules ningún tool — este agente trabaja solo con el texto del query

**Instructions (system prompt)**

```
Eres el enrutador inteligente del sistema multi-agente de Contoso. Tu ÚNICA tarea es analizar la consulta del usuario y decidir qué agentes especializados deben responderla.

## REGLA CRÍTICA
No respondas en lenguaje natural. No saludes. No expliques nada.
Tu respuesta debe contener ÚNICAMENTE un tag, en una sola línea.

## LOS TAGS DISPONIBLES
- [SALES]  → Solo ventas internas
- [MARKET] → Solo mercado externo
- [CREDIT] → Solo perfiles de clientes
- [CROSS]  → Pregunta involucra 2 o más dominios

## CUÁNDO EMITIR CADA TAG

**[SALES]** — Emite este tag si la consulta menciona o implica:
- Ventas, revenue, ingresos, transacciones
- Productos, categorías, inventario, SKUs
- Canales de venta (online, tienda física, MSI)
- Tickets, órdenes, volumen de ventas
- Performance interno, comparativas de productos propios
- Palabras clave: "ventas", "revenue", "productos", "categoría", "canal", "ticket", "iPhone", "laptop", "electronics", "sales"

**[MARKET]** — Emite este tag si la consulta menciona o implica:
- Tendencias del mercado o la industria
- Competidores, benchmarks, precios externos
- Contexto externo, comportamiento del consumidor
- Palabras clave: "mercado", "tendencias", "competencia", "benchmark", "industria", "market", "trend", "competidor", "precio competitivo", "externo"

**[CREDIT]** — Emite este tag si la consulta menciona o implica:
- Perfiles crediticios o segmentos de clientes
- Capacidad de pago, scores crediticios
- Clientes Premium, Alto, Medio, Bajo
- Riesgo financiero, deuda, comportamiento de pago
- Palabras clave: "cliente", "customer", "crédito", "credit", "perfil", "profile", "score", "segmento", "capacidad de pago", "riesgo"

**[CROSS]** — Emite este tag si la consulta involucra 2 o más dominios:
- Comparación interna vs mercado externo
- Recomendaciones por perfil de cliente considerando tendencias
- Análisis que cruza ventas + crédito, ventas + mercado, o los tres

## EJEMPLOS DE RUTEO
Consulta: "¿Cuáles son nuestras ventas de iPhone este año?"
Respuesta: [SALES]

Consulta: "¿Cuáles son las tendencias del mercado para smartphones en 2024?"
Respuesta: [MARKET]

Consulta: "¿Cuántos clientes de perfil Alto tenemos?"
Respuesta: [CREDIT]

Consulta: "¿Cómo se comparan nuestras ventas de iPhone vs las tendencias del mercado?"
Respuesta: [CROSS]

Consulta: "¿Qué productos premium deberíamos recomendar a clientes de perfil Alto según las tendencias actuales?"
Respuesta: [CROSS]

Consulta: "¿Nuestros precios en laptops son competitivos según el mercado?"
Respuesta: [CROSS]

Consulta: "¿Cuál es el score promedio de nuestros clientes Premium?"
Respuesta: [CREDIT]

## REGLAS ADICIONALES
- Responde SIEMPRE con un único tag
- Ante duda entre un dominio solo o cruce, prefiere [CROSS]
```

**Validar el Router Agent**

Antes de integrarlo al workflow, prueba el Router Agent en el Playground con estas consultas y verifica que emita el tag correcto:

| Consulta de prueba | Tag esperado |
|---|---|
| ¿Cuáles son nuestras ventas de laptop este año? | `[SALES]` |
| ¿Cuáles son las tendencias del mercado para laptops? | `[MARKET]` |
| ¿Cuántos clientes tenemos con perfil crediticio Alto? | `[CREDIT]` |
| ¿Cómo se comparan nuestros precios de laptop vs el mercado? | `[CROSS]` |
| ¿Qué productos premium recomendar a clientes de perfil Alto según tendencias? | `[CROSS]` |

✅ **Resultado esperado:** El Router Agent responde con un único tag, sin texto adicional.

![New Foundry](/img/router-agent.png)

---

### 5 - Crear el Workflow Multi-Agente

**Configuración Inicial del Workflow**

Para poder construir un workflow multi-agente existen varias opciones pro-code como el uso de **Semantic Kernel** o **AutoGen** ahora fusionados dentro del [Microsoft Agent Framework](https://learn.microsoft.com/en-us/agent-framework/overview/agent-framework-overview). Recientemente AI Foundry anunció un nuevo método llamado **Workflows** de bajo-código que permite realizar estos flujos de forma visual facilitando el proceso.

Para este ejercicio vamos a utilizar este método.

**Nota**: Antes de construir el flujo asegúrate de que tienes construidos los 5 agentes: Router, Sales, Market Research, Credit Risk y Strategy Advisor.

**Navegar a Workflows**
- En el portal de AI Foundry estando dentro de la opción **Build** navegamos al menú lateral → **Workflows**

  ![New Foundry](/img/workflow1.png)

- Click en **Create** y en la lista desplegable seleccionamos **Sequential**. Diseñaremos el flujo desde 0 comenzando con el nodo **Start**.

  ![New Foundry](/img/workflow2.png)

---

**Configurar Nodos del Workflow**

**Nodo Start**: Ya está creado. Agrega una nota opcional para documentar el flujo.

---

**Agregar Nodos: Set Variable — Capturar Query del Usuario**

Agregamos dos nodos de variable al inicio para preservar el query original y restaurarlo antes de cada agente.

- Click en **+** → **Set variable**
  - **Variable name**: `UserQuestion`
  - **Value**: `=System.LastMessageText`
- Click en **+** → **Set variable**
  - **Variable name**: `LatestMessage`
  - **Value**: `=UserMessage(Local.UserQuestion)`

*¿Por qué dos variables?* `Local.UserQuestion` guarda el texto plano del query original y no se modifica en ningún momento del flujo. `Local.LatestMessage` es la variable "activa" que cada agente recibe como input y sobreescribe con su respuesta. Antes de invocar cada agente especializado hacemos un `restore` — es decir, reasignamos `Local.LatestMessage` desde `Local.UserQuestion` — para garantizar que cada agente recibe la pregunta original del usuario y no la respuesta del agente anterior.

![New Foundry](/img/workflow3.png) ![New Foundry](/img/workflow3.1.png)

---

**Agregar Nodo: Invoke Router Agent**

Este es el primer agente que se ejecuta. Trabaja en silencio y su tag dirige el flujo.

- Click en **+** → **Invoke agent**
- Configura:
  - **Select an agent**: `Contoso-Router-Agent`
  - **Conversation context**: `System.ConversationId`
  - **Input message**: `=Local.LatestMessage`
  - **Automatically include agent response**: ❌ **Desactivado** (trabaja en silencio)
  - **Save agent output message as**: `LatestMessage` → se guarda como `Local.LatestMessage`
- Presiona **Done**

![New Foundry](/img/workflow4.png)

---

**Agregar Nodo: ConditionGroup — Routing**

Este es el nodo central. Evalúa el tag que emitió el Router y dirige el flujo.

- Click en **+** → **If/Else**

*Nota sobre el patrón `restore`:* Dentro de cada rama, antes de invocar al agente especializado, siempre agregamos un nodo **Set variable** que reasigna `Local.LatestMessage = UserMessage(Local.UserQuestion)`. Esto es necesario porque después del Router Agent, `Local.LatestMessage` contiene la respuesta del Router (los tags), no el query del usuario. Sin el restore, el agente especializado recibiría `[SALES]` como input en lugar de la pregunta original.

**Condition 1 — `[SALES]`:**
```
=!IsBlank(Find("[SALES]", Upper(Last(Local.LatestMessage).Text)))
```
Acciones (rama YES):
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
Acciones (rama YES):
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
Acciones (rama  YES):
- **Set variable**: `LatestMessage` = `=UserMessage(Local.UserQuestion)`
- **Invoke agent**: `Contoso-Credit-Risk-Analyst` → output: `Local.LatestMessage`, autoSend: false
- **End Conversation**

 ![New Foundry](/img/ifelse6.png)
 ![New Foundry](/img/ifelse7.png)
 ![New Foundry](/img/ifelse8.png)
 

**elseActions — `[CROSS]` (o cualquier caso no capturado):**

Cuando el Router emite `[CROSS]`, ninguna condición individual es verdadera y el flujo cae aquí. Se ejecutan los 3 agentes en secuencia y el Strategy Advisor sintetiza.

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

**Guardar el Workflow**
- Click en **Save** y nómbralo **Workflow-Multi-Agente-Contoso**

![New Foundry](/img/workflow9.png)

---

**Opción alternativa: YAML**

Si prefieres cargar el workflow directamente vía YAML en lugar de construirlo nodo a nodo, abre la pestaña **YAML** en el canvas y pega el contenido del archivo [workflow-multi-agente-contoso](/workflow-multi-agente-contoso.yaml) incluido en este repositorio. Luego regresa a la pestaña **Visualizer** para verificar la estructura y guarda.


### 6 - Testing y Validación el Workflow Multi-Agente
En este paso vamos a validar el flujo con preguntas que pongan a prueba el enrutamiento inteligente del Router Agent.

**Preview del Workflow**

Escenario 1:

**Query de un solo dominio — solo Sales**
- Click en **Preview** en la parte superior
- Esto abrirá una ventana de chat
- Agregamos una pregunta de prueba y ejecutamos

  ```
  ¿Cuál es el top 5 de productos más vendidos durante el 2024?
  ```

Flujo esperado:

✅ Router Agent analiza la consulta → emite `[SALES]`  
✅ Condition `[SALES]` es verdadera → Sales Agent se ejecuta  
⏭️ Market Research y Credit Risk se SALTAN  
⏭️ Strategy Advisor se SALTA (no es caso `[CROSS]`)  
✅ Respuesta directa del Sales Agent al usuario  

![New Foundry](/img/workflow11.png)

---

Escenario 2:

**Query cross-dominio — Sales + Market + Strategy Advisor**
- Click en **Preview**
- Agregamos una pregunta de prueba y ejecutamos

  ```
  ¿Cómo se comparan nuestras ventas de smartphone con las tendencias del mercado?
  ```

Flujo esperado:

✅ Router Agent → emite `[CROSS]`  
⏭️ Ninguna condición individual es verdadera → cae al `elseActions`  
✅ Sales Agent se ejecuta (datos internos de smartphones)  
✅ Market Research se ejecuta (tendencias externas de mercado)  
✅ Credit Risk se ejecuta  
✅ Strategy Advisor sintetiza y responde al usuario  

![New Foundry](/img/workflow12.png)

---

Escenario 3:

**Query de perfil de clientes — solo Credit**
- Click en **Preview**
- Agregamos una pregunta de prueba y ejecutamos

  ```
  ¿Cuántos clientes tenemos con perfil crediticio alto?
  ```

Flujo esperado:

✅ Router Agent → emite `[CREDIT]`  
✅ Condition `[CREDIT]` es verdadera → Credit Risk Agent se ejecuta  
⏭️ Sales, Market y Strategy Advisor se SALTAN  
✅ Respuesta directa del Credit Risk Agent al usuario  

![New Foundry](/img/workflow13.png)

En el menú **traces** también se puede analizar el flujo de cada nodo para efectos de resolución de problemas. Verás claramente cuáles nodos se ejecutaron y cuáles se saltaron en cada escenario.

### Recomendaciones

- El Router Agent puede refinarse continuamente ajustando su system prompt con más ejemplos de clasificación (few-shot examples). Cuantos más ejemplos específicos del dominio de Contoso incluyas, más preciso será el ruteo.
- Una recomendación adicional es extender las capacidades de este flujo con ramificaciones que consideren reintentos cuando el Router no emita tags reconocidos, y otros flujos secundarios para casos "edge".
- Como vimos, este flujo es determinístico pero inteligente en el ruteo inicial. Se invita opcionalmente a construir un flujo de tipo **Group Chat** que permita un manejo aún más autónomo de la colaboración entre agentes.

### 🎓 Bonus: Explorando Group Chat Workflow (Opcional)

**¿Por qué Group Chat es diferente?**

En Sequential, fuiste el director de orquesta - definiste cada paso del flujo. En **Group Chat**, los agentes forman una mesa redonda donde un Manager Agent (IA) decide dinámicamente quién debe hablar y cuándo.

Analogía:

**Sequential** = Director de orquesta (tú) que indica a cada músico cuándo tocar
**Group Chat** = Mesa redonda de expertos que deciden entre sí quién contribuye


**Cuándo considerar Group Chat**

Group Chat es útil cuando:

✅ Los agentes deben negociar o debatir  
✅ El orden de participación depende del contexto  
✅ Necesitas escalamiento dinámico (Tier 1 → Tier 2 → Specialist)  
✅ Quieres que la IA decida la colaboración  

**Ejemplos de casos de uso ideales:**

- Customer Support Escalation: Agente básico → Especialista → Manager (según complejidad)  
- Medical Diagnosis: Múltiples especialistas discuten síntomas y llegan a consenso  
- Legal Case Analysis: Abogados debaten estrategia colaborativamente  
- Product Design: Designer, Engineer, PM iteran dinámicamente  

### 📚 Recursos Adicionales

[Orchestrating Multi-Agent Conversations with Microsoft Foundry Workflows](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/orchestrating-multi-agent-conversations-with-microsoft-foundry-workflows/4472329)   
[Multi-Agent Orchestration Patterns](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/building-a-digital-workforce-with-multi-agents-in-azure-ai-foundry-agent-service/4414671)  
[Agent Framework Examples](https://github.com/microsoft/agent-framework)  
[Building No-Code Agentic Workflows with Microsoft Foundry](https://medium.com/data-science-collective/building-no-code-agentic-workflows-with-microsoft-foundry-52ad377ad644)  


