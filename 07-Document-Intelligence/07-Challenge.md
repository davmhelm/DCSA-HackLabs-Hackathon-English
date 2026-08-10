# 🏆 Challenge 07: Automate Document Processing with Logic Apps 🚀

## 📖 Objective

In this challenge you must:

✅ Configure an **Azure Logic App** to automatically process PDF files
✅ Enable **Managed Identity** for secure resource access
✅ Assign **permissions** to the Logic App for storage and AI processing
✅ Use **Document Intelligence (Form Recognizer)** to analyze PDFs
✅ Create an **ADF pipeline** to move PDFs from **Fabric** to a **Storage Account**
✅ Save the **analyzed JSON** files in the **Storage Account**
✅ Verify that the **processed files** are stored correctly in the **Storage Account**

---

## 🚀 Step 1: Create a Logic App

💡 **Why?** The Logic App will automate detection of new PDF files and trigger analysis with **Document Intelligence**.

### 1️⃣ Create an Azure Logic App
🔹 In the **Azure Portal**, create a new **Logic App (Consumption Plan)**.

🔹 **What settings should you define during creation?**

✅ **Result**: A Logic App is created and ready to be configured.

---

## 🚀 Step 2: Enable Managed Identity for the Logic App

💡 **Why?** The Logic App needs secure authentication to interact with **Azure Storage** and **Document Intelligence**.

### 1️⃣ Enable System-Assigned Identity
🔹 In the **Logic App** settings, enable the **System-Assigned Identity** option.

🔹 **Where can you copy the Object (Principal) ID to use later?**

✅ **Result**: The Logic App has an identity for authentication.

---

## 🚀 Step 3: Assign Permissions to the Logic App

💡 **Why?** The Logic App needs **access** to read from **Blob Storage** and write to the **Storage Account**.

### 1️⃣ Assign IAM permissions to the Logic App
🔹 Go to **Storage Account and Document Intelligence** → **Access Control (IAM)**

🔹 Assign the following **roles** to the Logic App’s **Managed Identity**:
✅ **Storage Blob Data Contributor**
✅ **Storage Account Contributor**
✅ **Cognitive Services Contributor** (for Document Intelligence)

🔹 **Why are these roles important for document processing?**

✅ **Result**: The Logic App can now access **Blob Storage** and **AI services**.

---

## 🚀 Step 4: Configure the Logic App using the Azure Portal (Designer)

💡 **Why?** You need to define the workflow to process incoming PDFs.

### 1️⃣ Create the workflow in Logic App Designer
🔹 Open the **Logic App Designer** → Start with a **Blank Logic App**

🔹 **Trigger:**
✅ Add **"When a blob is added or modified (properties only)"
✅ **Select the storage account**: `(Your Storage Account)`
✅ **Select the container**: `Your-Container`
✅ Add a **condition**: only trigger for `.pdf` files

🔹 **Processing step:**
✅ Add **"Analyze Document (Prebuilt-Invoice)"
✅ Provide the **storage URL** of the file

🔹 **Save the output:**
✅ Add **"Create Blob"** in **Azure Blob Storage**
✅ **Select the container**: `processed-json`
✅ **Define the blob name:**

```plaintext
analyzed-document-@{triggerOutputs()?['body']['name']}.json
```
