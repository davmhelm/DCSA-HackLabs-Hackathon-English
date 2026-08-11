# Prerequisites Guide for the Hackathon
### 🧩 Essential preparations to participate successfully

---

## ✅ Resource Provider Registration
Make sure the following resource providers are registered in your **Azure** subscription:
- `Microsoft.PolicyInsights`
- `Microsoft.Cdn`
- `Microsoft.StreamAnalytics`

**How to register them:**
1. Go to the **Azure Portal** → Subscription settings → *Resource providers*.
2. Select each provider and click **Register**.

---

## ✅ Identity and Authentication
**Service Principal and Authentication:**
- Client ID and secret *(ensure the secret does not expire before the second day of the event)*.
- Participants should have their **Client ID** and **secret** available during the hackathon.

---

## ✅ Microsoft Fabric Requirements
**Access options:**
- Create a **new Microsoft Fabric trial**, or
- Use an **already provisioned Fabric capacity** in your Azure subscription.

**Fabric configuration requirements:**
- At least one member assigned as a **Microsoft Fabric administrator**.
- A **Fabric workspace** assigned to the team.
- Ability to create **Lakehouses** and **Semantic Models** in Fabric.
- Access to **OneLake** (Fabric storage) to upload files.

---

## ✅ Azure OpenAI Requirements
**TPM quota for OpenAI models:**
- `text-embedding-ada-002`
- `gpt-4o`

If the current quota is less than **100,000**, request an increase before the event to ensure availability.
> ⏱️ Approvals usually take 24 hours, so it is critical to complete this step in advance.

**Recommended steps:**
- Check your current quota → [Azure OpenAI quotas guide](#)
- Request a quota increase → [Quota increase request](#)

---

## ✅ Network and Access Requirements
Ensure unrestricted access to the following platforms:
- **Azure AI Foundry**
- **Azure Data Factory**
- **Document Intelligence Studio**
- **Azure Portal**
- **Microsoft Fabric**

---

## ✅ Visual Studio Code Requirements
**Recommended VS Code extensions:**
- Python 🐍
- Azure Tools ☁️
- Azure Semantic Kernel Tools 🧠

---

## 🎯 What to Expect
- 💡 Hands-on technical challenges
- 🤝 Collaboration with peers
- 🧩 Live problem solving and expert guidance
- 🚀 Opportunity to improve skills and generate ideas with our teams

---

## 🚀 Final Checklist
✔️ Complete all prerequisites before the event
✔️ Verify access to **Azure**, **Microsoft Fabric**, and **OpenAI services**
✔️ Confirm access to **all required resources and tools**

---

# Day 2 Requirements

# 🔐 Azure Roles and Their Purpose

| **Azure Role** | **Primary Use** |
|-----------------|------------------|
| **Owner or Contributor** | Allows creating and managing resources such as *AI Services*, *Azure ML*, *App Services*, and more. |
| **Cognitive Services Contributor** | Enables configuration and management of *Cognitive Services* resources. |
| **Storage Blob Data Contributor** | Grants full access to storage used by *AI Foundry* (read, write, delete blobs). |
| **Azure OpenAI Contributor (if applicable)** | Provides access to GPT models, embeddings and other *Azure OpenAI* services. |
| **Key Vault Administrator (optional)** | Allows managing secrets, certificates and API keys stored in *Azure Key Vault*. |

## 🎉 See you at the Hackathon!
We look forward to a **dynamic and inspiring** event — and above all, a **rich learning experience for everyone**.

If you have questions or need assistance, **please contact the organizers**.

> 🚀 Get ready to innovate, collaborate and build AI-powered solutions! 🎉
