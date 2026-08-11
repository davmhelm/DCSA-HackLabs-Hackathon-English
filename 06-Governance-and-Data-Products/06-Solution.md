

# ✅ Solution Challenge 6: Data Governance and Data Products (Purview + Fabric)

## 🎯 Objective
Implement a data governance framework using **Microsoft Purview Unified Catalog** to catalog, classify and publish **Data Products** that group **Microsoft Fabric** (Lakehouse) assets with access policies, documentation and data quality rules.

---

## 📋 Prerequisites

### **Required access:**
- Active Azure subscription
- Microsoft Purview account (same tenant as Fabric)
- Fabric workspace with Lakehouse created from previous exercises
- Permissions:
  - **Fabric Admin** or **Contributor** on the workspace
  - **Data Governance Administrator** in Purview
  - **Data Product Owner** role in Purview

### **Prior configuration:**
- Lakehouse with sales and customer data (from exercises 1-5)
- Contributor access in Fabric for Purview's Managed Identity

---

## 🔧 PART 1: Configure Microsoft Purview

### **1.1 Create a Purview account (if not existing)**

**Portal UI**
1. Azure Portal → **Create Resource** → Search "Microsoft Purview"
2. Fill:
   - **Subscription**: `<your-subscription>`
   - **Resource Group**: `<your-resource_group>`
   - **Purview account name**: `contoso-retail-purview`
   - **Location**: East US 2 (recommended for Unified Catalog workloads)
   - Leave other options as default
     
4. **Review + Create**
 
![Purview](/img/purview-account.png)

---

### **1.2 Access the Microsoft Purview Portal**

1. Navigate to: **https://purview.microsoft.com**
2. Select your Purview account: `contosoretail-purview`
3. Verify the available solutions:
   - **Unified Catalog** (for Data Products)
   - **Data Map** (for scans)
   - **Information Protection**

  
![Purview](/img/purview-account2.png)   

---

### **1.3 Create a Governance Domain**

**Why?** Data Products must belong to a published Governance Domain.

1. In Purview Portal → **Unified Catalog** → **Catalog management** → **Governance domains**
2. Click **New governance domain**:
   - **Name**: `ContosoRetailDomain`
   - **Description**: "Domain for retail sales and customer data products"
   - **Type**: Data Domain
   - **Parent**: Empty
   - **Owner**: Assign your user
   - **Custom Attributes**: Empty
3. **Create**, but **DO NOT publish yet** (publication occurs after creating Data Products)


![Purview](/img/purview-account3.png) 



---

## 🗺️ PART 2: Register and Scan Fabric as a Source


### **1. Configure Security Group**

1. Azure Portal → **Microsoft Entra ID** → **Groups** → **New group**:
   - **Group type**: Security
   - **Name**: `sg-purview-fabric-readers`
   - **Description**: "Security group for Purview to scan Fabric"
   - **Members**: 
     - Purview Managed Identity (search by your Purview account name)
2. **Create**

![Purview](/img/purview-account7.png)

---

### **2. Enable Admin APIs in Fabric**

1. Fabric Portal → **Settings** (⚙️) → **Admin portal** → **Tenant settings**
2. Search for: **"Admin API settings"**
3. Enable the following options:
   - ☑️ **Service principals can access read-only admin APIs**
   - ☑️ **Enhance admin APIs responses with detailed metadata**
   - ☑️ **Enhance admin APIs responses with DAX and mashup expressions**
4. Under **"Apply to"** → Select **Specific security groups** → Add `sg-purview-fabric-readers`
5. **Apply**

⏱️ **IMPORTANT: WAIT 15 minutes** before continuing with the scan registration.

![Purview](/img/purview-account8.png)

---

### **2.4 Grant Purview Managed Identity permissions on the Fabric Workspace**

1. Fabric Portal → Navigate to your Workspace (e.g., `ContosoRetailWorkspace`)
2. Click → **Manage access**
3. **Add people or groups**
4. Search for your Managed Identity MSI: add the group `sp-purview-fabric-readers` that contains the Managed Identity
5. Assign role: **Contributor** or **Admin**
6. **Add**


---

### **2.6 Register Fabric Tenant in Purview Data Map**

1. Purview Portal → **Data Map** → **Data Sources** → **Register**
2. Select: **Microsoft Fabric** (same tenant)
3. Click **Continue**
4. **Register source**:
   - **Name**: `fabric-contoso-tenant`
   - **Fabric Tenant ID**: (auto-populated — your Microsoft Entra tenant ID found in Azure Portal → Microsoft Entra ID → Overview)
   - **Domain**: Create a governance domain or choose the default one
   - **Select a collection**: Create a new collection in Purview or select an existing one
5. **Register**

![Purview](/img/purview-account10.png)

---

### **2.7 Create a Fabric Scan**

1. In your source `fabric-contoso-tenant` → Click **New scan**
2. **Name**: `scan-contoso-lakehouse`
3. **Personal workspaces**: Include or exclude personal Workspaces as desired (leave as exclude for this exercise)
4. **Connect via integration runtime**:
   - Select **Azure AutoResolveIntegrationRuntime**
5. **Credential**: Click **+ New**
   - **Name**: `cred-fabric-sp`
   - **Authentication method**: **Microsoft Purview MSI (system)**
   - **Tenant ID**: (your Microsoft Entra tenant ID)
   - **Collection**: The collection where the data source belongs
   - **Create**
6. **Test connection** → Should show **Connection successful** ✅

![Purview](/img/purview-account11.png)


6. **Scope your scan**:
   - In the workspace tree, expand and select: `ContosoRetailWorkspace` or your Workspace
   
7. **Select a scan rule set**: 
   - Use the default: `Fabric`
   
8. **Set a scan trigger**:
   - **Once** (for this exercise)
   - Or **Recurring** → Weekly (for production environments)

9. **Review your scan** → Verify the configuration

10. **Save and run** 

⏱️ **The scan may take 5-15 minutes** depending on the size of your Lakehouse.

![Purview](/img/purview-account12.png)


---

### **2.8 Verify scan results**

1. **Data Map** → **Sources** → `fabric-contoso-tenant` → Click the name
2. Go to the **Scans** tab → Verify the status is **Completed** ✅
3. Click the scan name → **View details** 
4. You should see:
   - **Assets discovered**: Number of Lakehouses, Tables, Files found
   - **Classifications applied**: Sensitive data detected automatically
   - **Run time**: Scan duration

**Example expected output:**
```
Total assets discovered: 15
- Lakehouses: 1 (Contoso_Sales_Lakehouse)
- Tables: 3 (customers, sales, products)
- Files: 11 (parquet files)
Classifications applied: 8
- Personal.Email: 2 columns
- Personal.PhoneNumber: 1 column
- Personal.Location: 3 columns
```

---

## 📊 PART 3: Explore Assets in the Unified Catalog

### **3.1 Search for Lakehouse Assets**

1. Purview Portal → **Unified Catalog** → **Discovery** → **Data assets**
2. In the left filters:
   - **Source type**: Microsoft Fabric
   - **Collection**: ContosoData
3. Results should show:
   - Your Lakehouse: `Contoso_Sales_Lakehouse`
   - Tables: `customers`, `sales`, `products`
   - Files: individual parquet/delta files

![Purview](/img/purview-account13.png)

---

### **3.2 Review table metadata**

1. Click the table `gold.credit_score`
2. Explore available tabs:
   
   **Overview**:
   - Description
   - Owner/contacts
   - Collection
   - Source information
   
   **Schema**:
   - Columns: name, data type, description
   - Classifications applied to each column
   
   **Lineage**:
   - Upstream data sources
   - Downstream destinations
   - Note: May be empty initially until you add pipelines
   
   **Properties**:
   - Technical metadata (location, format, etc.)
   - Last modified
   - Asset size

---

## 🏷️ PART 4: Business Glossary and Data Products

### **4.1 Create glossary terms in the Governance Domain**

**Official docs:** [Create and manage glossary terms](https://learn.microsoft.com/purview/unified-catalog-glossary-terms-create-manage)

**Model:** Glossary terms are created WITHIN Governance Domains and associated to Data Products, NOT directly to individual data assets.


1. **Unified Catalog** → **Catalog management** → **Governance domains**
2. Click your domain (your default Purview account name)
3. Card **Glossary terms** → **View all** → **New term**

**Term 1:**
```
Name: Customer
Definition: Person or entity that makes purchases at Contoso Retail and is registered in the CRM
Owner: [your user]
Parent term: (none)
Next → Next → Create
```

**Term 2:**
```
Name: Sale
Definition: Commercial transaction including date, amount, products and associated customer
Owner: [your user]
Next → Next → Create
```

**Term 3:**
```
Name: Product
Definition: Sellable item identified by a unique SKU
Owner: [your user]
Next → Next → Create
```

**Status:** The 3 terms remain in **Draft** (not published).

---

### **4.2 ⚠️ IMPORTANT: Term association model**

**IN UNIFIED CATALOG:**
- ✅ Terms → are associated to **Data Products**
- ✅ Data Products → contain **Data Assets**
- ❌ Terms are NOT associated directly to individual data assets

**Correct relationship:**
```
Governance Domain
  └── Glossary Term: "Customer"
       └── Data Product: "Sales Insights Product"
            └── Data Asset: customers table
```

#### **4.3: Linking glossary terms from Data Products**

1. In your data product `Sales Insights Product` → Section **Glossary terms**
2. Click **+ (add terms)** next to "Glossary terms"
3. A side panel search opens
4. Search and select the terms:
   - ☑️ **Customer**
   - ☑️ **Sale**
   - ☑️ **Product**
5. Click **Add**

![Purview](/img/purview-account18.png)

---

## **4.3 Apply classifications (sensitivity labels) to assets**

Classifications ARE applied directly to assets and columns.

#### **A. Automatic classification (during scan)**
Purview automatically detects:
- Emails → `Personal.Email`
- Phone numbers → `Personal.PhoneNumber`
- Addresses → `Personal.Address`
- Locations → `Personal.Location`

**Verify applied classifications:**
1. **Discovery** → **Data assets** → Search for table `customers`
2. **Schema** tab → you will see badges on classified columns

#### **B. Manual classification**

1. In **Discovery** → **Data assets** → Click table `credit_score`
2. Click **Edit**
3. In the **Schema** section, for each column:
   
   **Column `ssn`:**
   - Click the pencil icon next to the column
   - **Classifications** → **+ Add classification**
   - Search and select: `US Social Security Number`
   - **Apply**
4. **Save**

**Repeat for other sensitive tables:**
- Table `transactions`: classify customer-related columns
- Table `products` or `business_operations`: typically not sensitive but may be reviewed

![Purview](/img/purview-account14.png)
  
---

## 🎁 PART 5: Create and Publish a Data Product

### **5.1 Prepare the Governance Domain**

1. **Unified Catalog** → **Catalog management** → **Governance domains**
2. Click `ContosoRetailDomain`
3. Ensure it is in **Draft** state (not published yet); if not, set it back to Draft to allow edits
4. In **Business concepts** → Click **Go to data products**

---

### **5.2 Create a new Data Product**

1. Click **New data product**
2. Fill the form:

**Basic Information:**
```
Name: Sales Insights Product

Description: 
This data product combines customer and sales information for business analysis. 
It provides an integrated view that enables:
- Purchase behavior analysis
- Customer segmentation by value
- Identification of sales trends
- Foundation for predictive models


Data quality expectations:
- Daily refresh
- Maximum latency: 24 hours
- Expected completeness: >95%

Type: Dashboard/Reports

Audience: Business User, Executive

Owner: [your user]

Next:

Use cases:
- Executive monthly sales dashboard
- Customer segmentation analysis (RFM)
- Predictive customer churn models
- Sales-target attainment reports

Next:

Custom attributes: None

```

3. **Create**

![Purview](/img/purview-account15.png)

---

### **5.3 Add Data Assets to the Product**

1. In the `Sales Insights Product` data product, select **Add data assets** in the **Assets** section.
2. In the search interface:
   - **Search:** `credit_score`
   - Select the `gold.credit_score` table from your Lakehouse.
   - Select **Add**.
3. Repeat these steps to add:
   - The `business_operations` table
   - The `gold.business_operations` table, if it exists
   - Optionally, a Power BI semantic model, if one has been published

**Note:** You can add only assets that:

- Are registered in the Data Map through a completed scan
- Belong to the scope of your Governance Domain
- You have permission to view

![Purview](/img/purview-account16.png)


---

### **5.4 Document the Data Product**

#### **A. Add External Links**

1. In the data product, open the **Details** tab.
2. In **Documentation**, select **+ Add link**.
3. Under **Add documentation link**, enter:

````text
Display name: Sales Metrics Specification
Link: https://contoso.sharepoint.com/sites/data/sales-metrics-spec
Description: Document containing KPI definitions and business rules
````
4. Click **Create**

![Purview](/img/purview-account17.png)



#### **B. Add Descriptions to the Assets**

In **Data assets**, add the following information to each asset.

   **For `credit_score` table:**
````text
Description: Table containing active-customer information and credit attributes.
Includes financial and segmentation data.
Grain: One record per unique customer (customer_id)
Refresh schedule: Daily at 2:00 AM
````

   **For `business_operations` table:**
````text
Description: Table containing historical transactions since 2024.
Includes details for each sale, including products, amounts, discounts, and payment methods.
Grain: One record per sales line item (product__id)
Refresh schedule: Daily at 3:00 AM
````

---

### **5.5 Configure access policies**

1. In the data product, select **Manage policies**.
2. Open the **Access policies** tab.

**Access duration:**
````text
Access time limit: 365 days (1 year)
Reason: Users require continuous access for recurring reports
````

**Approval workflow:**
````text
☑️ Approval required
Approvers: [Add your user account or a data stewards group]
````

3. Click **Save**

4. Optionally, open the **Inherited policies** tab:
   - This tab displays policies inherited from the Governance Domain.
   - Examples include data-quality or compliance policies.

---

### **5.6 Publish the Governance Domain**

⚠️ **IMPORTANT:** A Data Product can be published only after its Governance Domain has been published.

1. Return to **Catalog management** → **Governance domains**.
2. Select `ContosoRetailDomain`.
3. Verify that it has:
   - ✅ At least one Data Product
   - ✅ An assigned owner
   - ✅ A complete description
4. Select **Publish** in the upper-right corner.

The domain status changes from **Draft** to **Published** ✅.

---

1. Go to **Data products** → `Sales Insights Product`.
2. Verify that it has:
   - ✅ At least one associated data asset
   - ✅ A complete description and complete use cases
   - ✅ An assigned owner
   - ✅ Configured access policies
3. Select **Publish**.

The product status changes to **Published** ✅.

---


## 🎯 Final Result

After completing this exercise, you have implemented:

- ✅ **Automated cataloging:** Fabric assets are visible in the Purview Data Map
- ✅ **Governed Data Product:** `Sales Insights Product` is published with complete documentation
- ✅ **Business glossary:** Business terms are linked to the relevant Data Products
- ✅ **Sensitive-data classification:** Privacy classifications are applied to sensitive columns
- ✅ **Data lineage:** Traceability from the Lakehouse to downstream data products
- ✅ **Federated governance:** A functional access-request and approval workflow
- ✅ **Discoverability:** Data Products can be found and consumed across the organization

---

## 📚 Official References

### **Core Documentation**
- [Purview + Fabric Integration Overview](https://learn.microsoft.com/fabric/governance/microsoft-purview-fabric)
- [Register and Scan Fabric Tenant (Same Tenant)](https://learn.microsoft.com/purview/register-scan-fabric-tenant)
- [Data Products in Unified Catalog](https://learn.microsoft.com/purview/unified-catalog-data-products)
- [Create and Manage Data Products](https://learn.microsoft.com/purview/unified-catalog-data-products-create-manage)

### **Step-by-Step Tutorials**
- [Governance Tutorial - Publish Data Products](https://learn.microsoft.com/purview/section3-publish-data-products)
- [Sample Setup Walkthrough](https://learn.microsoft.com/purview/data-governance-setup-sample)
- [Get Started with Data Governance](https://learn.microsoft.com/purview/data-governance-get-started)

### **Advanced Configuration**
- [Data Quality for Fabric Lakehouse](https://learn.microsoft.com/purview/data-quality-for-fabric-data-estate)
- [Metadata and Lineage from Fabric](https://learn.microsoft.com/purview/data-map-lineage-fabric)
- [Microsoft Purview Hub in Fabric](https://learn.microsoft.com/fabric/governance/use-microsoft-purview-hub)

### **Permissions and Security**
- [Purview Permissions Overview](https://learn.microsoft.com/purview/catalog-permissions)
- [Access Policies for Data Products](https://learn.microsoft.com/purview/how-to-policies-data-owner-data-product)

---

## 🎓 Key Concepts

### **What Is a Data Product in Purview?**

A **Data Product** is not simply an individual dataset. It is a **business concept** that:

- **Groups multiple related assets**, such as tables, files, and reports, under a specific use case
- **Provides business context**, including descriptions, use cases, and data-quality expectations
- **Improves discoverability** by using business terminology rather than technical terminology
- **Centralizes governance** by applying policies across the product’s assets
- **Simplifies access**, allowing one request to cover all assets in the product

### **Data Map vs. Unified Catalog**

| **Data Map** | **Unified Catalog** |
|---|---|
| Technical view of assets | Business view of Data Products |
| Automated metadata scanning | Manual product curation |
| Intended primarily for data engineers | Intended primarily for data consumers |
| Catalog of what exists | Catalog of what is useful |

### **Governance Flow in Purview and Fabric**
```
1. DISCOVERY (Data Map)
   ↓ Fabric assets → Purview scan → Data Map

2. CLASSIFICATION (Auto + Manual)
   ↓ Sensitive data → Labels applied → Compliance

3. CURATION (Unified Catalog)
   ↓ Business context → Glossary terms → Understanding

4. PRODUCTIZATION (Data Products)
   ↓ Group assets → Add context → Publish

5. ACCESS GOVERNANCE
   ↓ Request → Approval → Time-limited access

6. CONSUMPTION (Fabric Workspace)
   ↓ Discover product → Access data → Build solutions
```

---

