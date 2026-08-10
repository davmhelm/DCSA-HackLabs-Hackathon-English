# 🚀 Challenge 6: Data Governance with Purview + Fabric

## 🎯 Objective
Catalog Fabric data in Purview and create a governed Data Product with access policies and associated glossary terms.

## 📋 Prerequisites
- Microsoft Purview account (same tenant as Fabric)
- Fabric workspace with Lakehouse populated (from previous exercises)

- Admin permissions on Fabric workspace
- **Data Governance Administrator** role in Purview

## 🧠 Challenge Tasks

### 1. Configure Purview
- Access https://purview.microsoft.com
- Use the default Governance Domain (it uses your Purview account name)
- **Do not publish the domain until the end**

### 2. Scan Fabric in Purview Data Map
**Configure authentication:**
- Create a Security Group including the Purview Managed Identity


**Configure Fabric:**
- Enable "Admin API settings" in Fabric Tenant Settings for the Security Group
- Grant **Contributor** permissions to the Security Group on your workspace

**Run the scan:**
- Register the Fabric tenant as a source in Purview Data Map
- Create a scan using the Managed Identity
- Verify discovery of: Lakehouse + Tables + Files

### 3. Create Glossary Terms
In your Governance Domain → Business concepts → Glossary terms:
- Create 3 terms with business definitions:
  - "Customer"
  - "Sale"
  - "Product"
- Leave the terms in **Draft** state (not published)

### 4. Create a Data Product
In your Governance Domain → Business concepts → Data products:
- Create the data product: "Sales Insights Product"
- Add description and detailed use cases
- **Add data assets**: Lakehouse tables `customers` and `sales`
- **Associate glossary terms**: Customer, Sale, Product
- Configure **access policy**: Approval required, 365 days
- Add documentation links
- Leave the product in **Draft** state

### 5. Publish
- **Publish the Governance Domain** (enables term and product publication)
- **Publish the Data Product**
- Verify in **Discovery → Enterprise glossary** that terms are visible
- Verify in **Discovery → Data products** that the product is discoverable



## 🏁 Deliverables
✅ Fabric tenant scanned (Lakehouse + tables visible in Data Map)
✅ 3 glossary terms created
✅ 1 Data Product published with 2+ assets and associated terms
✅ Screenshot of data lineage
