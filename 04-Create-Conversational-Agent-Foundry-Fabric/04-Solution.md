# Solution Challenge 04 - Create a Conversational Agent in AI Foundry Integrated with Microsoft Fabric

Step-by-step guide to enable a conversational agent from AI Foundry integrated with the Microsoft Fabric Data Agent.

### Objective 🎯
- Design a conversational agent in AI Foundry integrated with Microsoft Fabric.
- Connect the agent to a Data Agent associated with the semantic model/Gold tables.
- Configure intents and prompts aimed at real business questions.
- Validate that the agent answers in natural language without showing code or technical syntax.
- (Optional) Publish the agent for analyst use in Copilot, Power BI, or AI Foundry.

---

## Prerequisites

- Semantic model, Data Agent, and value dashboard (Gold) - see `03-Solution.md`.

## Steps

### 1 - Create the Agent in Foundry

1. To create an agent in Foundry, you need access to a Foundry resource within a project (prerequisites). Go to your Azure AI Foundry resource from the Azure subscription or sign in with your authorized user at [AI Foundry](https://ai.azure.com/). Enable the new Foundry experience, as it provides a simpler and more intuitive environment.

![New Foundry](/img/new_foundry.png)

2. Select your project → from the welcome menu → **Start building** → **Create agent** → in **Agent Name** assign a descriptive and unique name, for example: `Contoso-Virtual-Analyst`.

![Foundry-Start](/img/foundry-start.png)

3. In the agent menu → **Playground** → select the model created as part of the prerequisites (**gpt-4o**) and click **Save**. You can use other conversational models if they are already enabled in the resource.

✅ **Expected result:** The agent is created and configured for conversational interaction.

![Foundry-Agent](/img/foundry-agent.png)


### 2 - Connect the Agent to the Fabric Data Agent

1️. In the **Tools** section (you can also access it from Knowledge) → **+ Add a new tool** → **Fabric Data Agent** → **Add tool**, and then configure the **Data Agent** created in the previous Fabric challenge.


![Foundry-Agent](/img/fabric-tool.png)


2. In the dialog box, configure a new Fabric Data Agent connection by providing the following information:

   - **Name**: A descriptive name for the connection
   - **Workspace ID**: The ID of the workspace hosting the Data Agent. With the Data Agent open, this is the first alphanumeric identifier in the URL (1)
   - **Artifact ID**:  The ID of the Data Agent artifact. With the Data Agent open, this is the second alphanumeric identifier in the URL (2)
  
Reference image for locating and verifying the Data Agent's `Workspace ID` and `Artifact ID`


![Foundry-Agent](/img/workspace-artifact.png)
     

3. In Fabric, verify again that the Data Agent is connected to the **Gold semantic model** or the tables it needs to perform its tasks, including:  
   - `gold.business_operations`  
   - `gold.credit_score`
   - `semantic model`

4. Save the connection configuration.  

✅ **Expected result:** The Foundry agent is connected to the Fabric Data Agent.


![Foundry-Agent](/img/fabric-tools.png)


### 3 - Define Guiding Intents and Prompts

1. Add instructions that help the agent understand what it should do. This configuration, often called a **System Prompt**, tells the agent how it should act, what tasks to perform, and how to format responses (tone, etc.). In this case, orient it toward the Fabric Data Agent.

In **Instructions**, add clear, concise, structured directions, then save the agent configuration again. Here is an example:

```
# Role and Context
You are an operational analytics assistant with access to
Contoso transaction and product data.

# Data Source
You have access to updated data from the Fabric Data Agent named 'Contoso Data Agent' containing:
- business_operations (transaction and product tables)

# Expected Behavior
1. Always consult the data before answering factual questions
2. If you cannot find information in the data, say so clearly
3. Cite specific sources when using data information
4. Maintain a tone [professional and technical as needed]

# Restrictions
- Do not invent information that is not in the data
- Always validate dates and numbers before reporting them

# Response Format
- Use tables for numeric data
- Include context when relevant
- Be concise but complete
```

![Foundry-Agent](/img/sys-prompt.png)


### 4 - Define Guiding Intents and Prompts

1. Now try creating `intents` or queries that reflect Contoso’s analytical needs. To do this, open the gear icon ⚙️ in the top right corner of the chat window.
   In the menu, complete the following:

   - **Display name**: so users identify the agent with a familiar name
   - **Description**: an optional description of what the agent does and how to use it
   - **Starter Prompts**: example intents for the agent’s context. These will appear as suggestions for the user.

```
"Which products have the highest return rate?"
"Which category has the most valuable products?"
"What is the total commercial value by brand?"
```

Save the configuration.

![Foundry-Agent](/img/starter-prompts.png)


### 5 - Validate the Agent with Real Questions

1. In the chat bar, ask questions to validate the responses generated. You can select questions from the `starter prompts` list or use your own queries.

✅ **Expected result:** The agent understands business questions and responds contextually. If it lacks precision, adjust the instructions and test again.

![Foundry-Agent](/img/output-prompt.png)

### 6 - Publish and Enable the Agent

Once the agent is validated and demonstrates accurate behavior, publish it so it can be exported or made available through channels such as Teams and M365 Copilot.

1. In the upper right corner, select the **Publish** button. This lets you enable the agent in Teams and M365 Copilot channels, where corporate users can use it without direct access to Foundry or Microsoft Fabric. You can also configure access and groups.

![Foundry-Agent](/img/publish.png)

2. (Optional) If you have access, you can publish the agent to M365 and Teams. For that, Azure Bot Service must be enabled, which acts as middleware between the agent and the frontend layer (Teams, 365).
   Complete the requested configuration in the menu and continue through the 365 ecosystem for validation.

![Foundry-Agent](/img/optional-365.png)

3. Once published locally in Foundry, view the agent in `Preview`, which is a simulated view of a final application.

![Foundry-Agent](/img/preview.png)

![Foundry-Agent](/img/preview2.png)

✅ **Expected result:** The agent is active and available for natural language queries.
