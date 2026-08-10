# **Reto 2 – Transformación intermedia, análisis exploratorio (Silver) y Preparacion Gold 🔧📊**

## **Objetivo y solución paso a paso 🧭**

### **Objetivo 🎯**
Transformar los datos Bronze, realizar análisis exploratorio en Silver y finalmente construir la capa Gold. 

---

## **Solución paso a paso 🪜**

En este approcah se decidio trabajar tres productos de datos **Credit Scores** medallion + segmentacion de clientes con ML (KMeans), **Products** -medallion + segmentacion de productos por valor comercial con ML (KMeans), y **Business Operations** que combina tablas de transactions y products para modelar un analisis operacional de compras de clientes y productos. El ejercicio no pretende ejercer un modelado dimensional estricto y mas bien se invita a trabajar distintos enfoques, Fabric como herramienta se adapta a enfoqaues de modelado dimensional asi como enfoques de denormalizacion comunes en entornos de Big Data.
# **Challenge 2 – Intermediate transformation, exploratory analysis (Silver) and Gold preparation 🔧📊**

## **Goal and step-by-step solution 🧭**

### **Goal 🎯**
Transform Bronze data, perform exploratory analysis in Silver, and finally build the Gold layer.

---

## **Step-by-step solution 🪜**

This approach uses three data products: **Credit Scores** (medallion + customer segmentation with ML KMeans), **Products** (medallion + product segmentation by commercial value with ML KMeans), and **Business Operations** which combines `transactions` and `products` tables to model operational analysis of customer purchases. The exercise is not intended to enforce a strict dimensional model; Fabric supports both dimensional modeling and denormalized approaches common in Big Data environments.

The structure used is shown below:

![Approach](/img/approach.png)


### **Credit score set 🧩**
(This is an example for the financial credit scenario; other approaches are possible.)

- Create a new Dataflow Gen2 or Notebook for the Silver layer
- Configure the source from Bronze tables
- Apply intermediate transformations
- Create derived credit score columns
- Segment customers by credit profile
- Save as a Silver table in the Lakehouse
- Create a new Notebook for the Gold layer of credit scoring
- Configure the source from Silver tables
- Identify the cluster with the highest average score
- Filter customers that belong to that cluster
- Store the results in the Gold layer
- Result: a subset of customers with a high credit profile

---

# **SILVER LAYER - CREDIT SCORE**

# **Example – Create Silver tables - Credit Score 🧮**


## **Load Bronze table with financial data 🧾**

```python

df_fin = spark.sql("SELECT * FROM Contoso_Lakehouse.bronze.credit_score") 
```

---

## **Derive `score_estimado` column based on payment behavior and credit usage 💳**

```python

from pyspark.sql.functions import col, when, udf 
from pyspark.sql.types import StringType 

df_fin = df_fin.withColumn("score_estimado", 
    when(col("Payment_Behaviour") == "High_spent_Small_value_payments", 650)
    .when(col("Payment_Behaviour") == "Low_spent_Large_value_payments", 750)
    .when(col("Payment_Behaviour") == "High_spent_Large_value_payments", 800)
    .when(col("Payment_Behaviour") == "Low_spent_Small_value_payments", 600)
    .otherwise(620)
)
```
---

## **Penalty for late payments ⏰**

```python
df_fin = df_fin.withColumn("score_estimado", 
    col("score_estimado") - (col("Num_of_Delayed_Payment") * 5)
)
```
---

## **Penalty for high credit utilization 📉**

```python
df_fin = df_fin.withColumn("score_estimado", 
    when(col("Credit_Utilization_Ratio") > 0.8, col("score_estimado") - 20)
    .otherwise(col("score_estimado"))
)
```
---

## **Limit score between 300 and 850 ⚙️**

```python
df_fin = df_fin.withColumn("score_estimado", 
    when(col("score_estimado") < 300, 300)
    .when(col("score_estimado") > 850, 850)
    .otherwise(col("score_estimado"))
)
```
---

## **Filter valid records for clustering 🧹**

```python
df_fin_clean = df_fin.filter(col("score_estimado").isNotNull()) 

```
 
---

## **Normalize column names to lower case**

```python
df_fin_clean = df_fin_clean .toDF(*[c.lower() for c in df_fin_clean.columns])
```
---
## **Filter out records with nulls/na and validate ages and loan counts**
```python
df_fin_clean = df_fin_clean.dropna().filter(
col("age").between(1, 120) & 
(col("num_of_loan") >= 0) &
(col("credit_history_age") != "NA"))
```
---

## **💾 Save prepared Silver table**

```python
df_fin_clean.write.option("overwriteSchema", "true").mode("overwrite").saveAsTable("Contoso_Lakehouse.silver.credit_score") 

```

---


# **GOLD LAYER - CREDIT SCORE**

# **Example – Customer segmentation by credit score 🧮**


## **📌 Import required functions**

```python
from pyspark.sql.functions import col, when, udf 
from pyspark.sql.types import StringType 
from pyspark.ml.feature import VectorAssembler 
from pyspark.ml.clustering import KMeans 
```


## **Load prepared Silver table with financial data 🧾**

```python
df_fin = spark.sql("SELECT * FROM Contoso_Lakehouse.silver.credit_score")

```

---

## **Vectorize `score_estimado` column for ML 🤖**

```python
assembler = VectorAssembler(inputCols=["score_estimado"], outputCol="features") 
df_fin_vec = assembler.transform(df_fin_clean) 
```

---

## **Apply KMeans clustering to segment customers 🧠**

```python
kmeans = KMeans(k=3, seed=42) 
model_fin = kmeans.fit(df_fin_vec) 
df_fin_clustered = model_fin.transform(df_fin_vec) 
```

---

## **Label credit profiles by average score per cluster 🏷️**

```python
cluster_scores = df_fin_clustered.groupBy("prediction") \
    .avg("score_estimado") \
    .orderBy("avg(score_estimado)", ascending=False) \
    .collect()
```

---

## **Create label map: High, Medium, Low 🗺️**

```python
cluster_map = {} 
for i, row in enumerate(cluster_scores): 
    cluster_map[row["prediction"]] = ["Alto", "Medio", "Bajo"][i] 
```

---

## **UDF to assign label ⚡**

```python
def map_cluster(pred): 
    return cluster_map.get(pred, "Desconocido") 

map_udf = udf(map_cluster, StringType()) 
df_segmentado = df_fin_clustered.withColumn("perfil_crediticio", map_udf(col("prediction"))) 
```

---

## **Count customers by profile (optional for validation) 📊**

```python
df_segmentado.groupBy("perfil_crediticio").count().orderBy("count", ascending=False).show() 
```

---

## **Filter customers by profile 🥇**
**NOTE**: This step can be adjusted to analyze all tiers or only high-profile customers

```python
#df_gold_fin = df_segmentado.filter(col("perfil_crediticio") == "Alto") 
#display(df_gold_fin)
df_gold_fin = df_segmentado
```

---

## **Drop ML helper columns**

```python
drop_columns = ["features", "prediction"]
df_gold_fin = df_gold_fin.drop(*drop_columns)
```

---

## **Save Gold table with top-tier customers 💾**

```python
df_gold_fin.write.option("mergeSchema", "true").mode("overwrite").saveAsTable("Contoso_Lakehouse.gold.credit_score") 

```

---

### **Retail set by Product 🧩**
(This is another example; apply similar steps to product scenarios)

- Create a new Dataflow Gen2 or Notebook for Silver
- Configure the source from Bronze tables
- Apply intermediate transformations
- Create derived columns
- Segment products/customers
- Save as a Silver table and prepare Gold
- Result: curated subsets ready for Gold


# **SILVER LAYER - RETAIL**

# **Example – Create Silver tables - Retail 🧮**

---

## **📌 Import required functions**

```python
from pyspark.sql.functions import col, when, udf 
from pyspark.sql.types import StringType 

```

---

## **Load Silver table with retail product catalog 🧾**

```python
df_retail = spark.read.table("productos_silver") 
```

---

## **🧮 Derive `valor_comercial` = Price × Stock**

```python
df_retail = df_retail.withColumn("valor_comercial", col("Price") * col("Stock")) 
```

---

## **🧮 Derive binary availability column**

```python
df_retail = df_retail.withColumn("disponible", 
    when(col("Availability") == "in_stock", 1).otherwise(0)
)
```

---

## **🧹 Filter valid records for clustering**

```python
df_retail_clean = df_retail.filter( 
    col("valor_comercial").isNotNull() & col("disponible").isNotNull()
)
```

---

## **Normalize column names to lower case**

```python
df_fin_clean = df_fin_clean .toDF(*[c.lower() for c in df_fin_clean.columns])
```
---

## **💾 Save prepared Silver table**

```python
df_retail_clean.write.option("overwriteSchema", "true").mode("overwrite").saveAsTable("Contoso_Lakehouse.silver.products") 

```

---



# **GOLD LAYER - RETAIL**

# **Example – Product segmentation 🧮**

---

## **📌 Import required functions**

```python
from pyspark.sql.functions import col, when, udf 
from pyspark.sql.types import StringType 
from pyspark.ml.feature import VectorAssembler 
from pyspark.ml.clustering import KMeans 
```
---

## **📊 Vectorize columns for ML**

```python
assembler = VectorAssembler(inputCols=["valor_comercial", "disponible"], outputCol="features") 
df_retail_vec = assembler.transform(df_retail_clean) 
```

---

## **🤖 Apply KMeans clustering to segment products**

```python
kmeans = KMeans(k=3, seed=42) 
model_retail = kmeans.fit(df_retail_vec) 
df_retail_clustered = model_retail.transform(df_retail_vec) 
```

---

## **🏷️ Label products by average commercial value per cluster**

```python
cluster_scores = df_retail_clustered.groupBy("prediction") \
    .avg("valor_comercial") \
    .orderBy("avg(valor_comercial)", ascending=False) \
    .collect()
```

---

## **Create label map: Valuable, Medium, Low 🗺️**

```python
cluster_map = {} 
for i, row in enumerate(cluster_scores): 
    cluster_map[row["prediction"]] = ["Valioso", "Medio", "Bajo"][i] 
```

---

## **UDF to assign label ⚡**

```python
def map_cluster(pred): 
    return cluster_map.get(pred, "Desconocido") 

map_udf = udf(map_cluster, StringType()) 
df_segmentado = df_retail_clustered.withColumn("perfil_producto", map_udf(col("prediction"))) 
---

## **🥇 Filtrar productos disponibles**
**NOTA**: Este paso puede ajustarse si se desea analizar todos los tiers o solo los productos de perfil alto (valioso)

```python
#df_gold_retail = df_segmentado.filter(
#    (col("perfil_producto") == "Valioso") & (col("disponible") == 1)
#)
#display(df_gold_retail)
df_gold_retail = df_segmentado.filter(
    (col("disponible") == 1))
```

---

## **Eliminar columnas innecesarias de ML**

```python
drop_columns = ["features", "prediction"]
df_gold_retail = df_gold_retail.drop(*drop_columns)

```

## **💾 Guardar tabla Gold con productos valiosos**

```python
df_gold_retail.write.option("overwriteSchema", "true").mode("overwrite").saveAsTable("Contoso_Lakehouse.gold.products")
```

---


# **Preparacion + Promoción a Gold (Business Operations - Transacciones) 🛍️🤖**


## **Solución paso a paso 🪜**

### **Set de transacciones🧩**  
(Esto es un ejemplo de como trabajar el escenario de transactions, se puede hacer con otros enfoques)

- Crear nuevo Dataflow Gen2 o Notebook para la capa Silver
- Configurar el origen en las tablas Bronze.
- Aplicar transformaciones intermedias 
- Extracciones temporales basicas
- Segmentacion simple de tickets
- Flags de financiamento
- Guardar en el Lakehouse como tabla una tabla silver
- Se crea un nuevo Notebook para la capa Gold de score crediticio
- Configurar el origen en las tablas Silver.
- Se identifica el cluster con mayor promedio de score 
- Se filtran los clientes pertenecientes a ese cluster
- Se almacenan los datos en la capa Gold
- Resultado: subconjunto de clientes con perfil crediticio alto 

---


# **CAPA SILVER - TRANSACTIONS**

# **Ejemplo -Creacion tablas silver - Transactions  🧮**

---

## **📌 Importar funciones necesarias**

```python
from pyspark.sql.functions import *
```
---

## **Leer Bronze**

```python
df_transactions = spark.read.table("Contoso_Lakehouse.bronze.transactions")

print(f"💳 Transactions en Bronze: {df_transactions.count():,}")
print("\n📋 Schema:")
df_transactions.printSchema()
```
---

## **Transformaciones Silver**

```python
df_transactions_enriched = (
    df_transactions
    
    # ============================================
    # FEATURES TEMPORALES (solo lo esencial)
    # ============================================
    .withColumn("year", year("transaction_date"))
    .withColumn("month", month("transaction_date"))
    .withColumn("quarter", quarter("transaction_date"))
    .withColumn("year_month", date_format("transaction_date", "yyyy-MM"))
    
    # ============================================
    # SEGMENTACIÓN SIMPLE
    # ============================================
    .withColumn("ticket_segment", 
        when(col("amount") < 500, "Low")
        .when(col("amount") < 1000, "Medium")
        .otherwise("High")
    )
    
    # ============================================
    # FLAGS DE FINANCIAMIENTO
    # ============================================
    .withColumn("is_msi", col("installments") > 1)
    .withColumn("is_credit", col("payment_method") == "Credit")
    
    # Solo transacciones aprobadas
    .filter(col("approval_status") == "Approved")
    
    # ============================================
    # SELECCIÓN FINAL (campos esenciales)
    # ============================================
    .select(
        # IDs
        "transaction_id",
        "customer_id",
        "product_id",
        
        # Transacción
        "transaction_date",
        "amount",
        "quantity",
        "payment_method",
        "installments",
        "channel",
        "store_location",
        
        # Tiempo
        "year",
        "month",
        "quarter",
        "year_month",
        
        # Segmentos
        "ticket_segment",
        "is_msi",
        "is_credit"
    )
)
```
---

## **Validaciones de Calidad**

```python
total_transactions = df_transactions_enriched.count()
print(f"✅ Total transacciones en Silver: {total_transactions:,}")

unique_customers = df_transactions_enriched.select("customer_id").distinct().count()
print(f"👥 Clientes únicos: {unique_customers:,}")

print("\n💰 Distribución por Ticket Segment:")
df_transactions_enriched.groupBy("ticket_segment").count().orderBy("ticket_segment").show()

```
---

## **💾 Guardar tabla silver preparada**

```python
df_transactions_enriched.write \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("Contoso_Lakehouse.silver.transactions")

print(f"✅ Silver table created: silver.transactions")
print(f"   Records: {total_transactions:,}")
print(f"   Customers: {unique_customers:,}")
```

---

# **CAPA GOLD - BUSINESS OPS**
Este notebook crea una tabla Gold que combina:
- Transacciones (silver.transactions)
- Productos (silver.products)

**Output**: `gold.business_operations` - Fact table para análisis operacional


# **Ejemplo - Business Operations - Combinando transacciones + productos🧮**

```python
from pyspark.sql.functions import *
```

---

## **Leer datos de Silver**

```python
# Transacciones enriquecidas
df_transactions = spark.read.table("Contoso_Lakehouse.silver.transactions")

# Productos enriquecidos
df_products = spark.read.table("Contoso_Lakehouse.silver.products")

print(f"Transactions: {df_transactions.count():,} registros")
print(f"Products: {df_products.count():,} registros")
```

---

## **Crear tabla Gold**

```python

df_business_operations = (
    df_transactions
    
    # JOIN con productos
    .join(
        df_products.select(
            "product_id",
            "product_name",
            "brand", 
            "category",
            "price",
        ),
        "product_id",
        "left"
    )
    
    # Selección final (solo campos necesarios)
    .select(
        # IDs
        "transaction_id",
        "customer_id",
        "product_id",
        
        # Producto
        "product_name",
        "brand", 
        "category",
        "price",
        
        
        # Transacción
        "transaction_date",
        "amount",
        "quantity",
        "payment_method",
        "installments",
        "channel",
        "store_location",
        
        # Tiempo
        "year",
        "month",
        "quarter",
        "year_month",
        
        # Segmentos
        "ticket_segment",
        "is_msi",
        "is_credit"
    )
)

```

---

## **Validaciones**

```python
total_records = df_business_operations.count()
print(f"✅ Total registros en Gold: {total_records:,}")

# Verificar nulls críticos
null_checks = df_business_operations.select([
    count(when(col(c).isNull(), c)).alias(c) 
    for c in ["customer_id", "product_id", "amount", "transaction_date"]
])
print("\n📊 Nulls en campos críticos:")
null_checks.show()
```

---

## **Guardar tabla Gold**

```python

df_business_operations.write \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("Contoso_Lakehouse.gold.business_operations")

print(f"✅ Tabla gold.business_operations creada exitosamente")
print(f"   Registros: {total_records:,}")

```

---

## **Queries de Validación**

```python
# Top 10 productos por revenue
print("🏆 Top 10 Productos por Revenue:")
df_business_operations.groupBy("product_name", "category") \
    .agg(
        count("*").alias("units_sold"),
        sum("amount").alias("total_revenue")
    ) \
    .orderBy(col("total_revenue").desc()) \
    .limit(10) \
    .show(truncate=False)

# Revenue por canal
print("\n📺 Revenue por Canal:")
df_business_operations.groupBy("channel") \
    .agg(
        count("*").alias("transactions"),
        sum("amount").alias("revenue"),
        avg("amount").alias("avg_ticket")
    ) \
    .orderBy(col("revenue").desc()) \
    .show()
```

---


