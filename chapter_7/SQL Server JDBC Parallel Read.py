# Databricks notebook source
# DBTITLE 1,JDBC Driver Setup
# MAGIC %md
# MAGIC ## JDBC Driver Setup
# MAGIC
# MAGIC Before running the cell below, install the SQL Server JDBC driver as a Maven library on this compute:
# MAGIC
# MAGIC **Maven coordinates:** `com.microsoft.sqlserver:mssql-jdbc:12.4.2.jre11`
# MAGIC
# MAGIC On Serverless: add it via **Compute settings → Libraries → Install → Maven**, or upload the JAR to a UC Volume and reference it with `spark.jars`.
# MAGIC
# MAGIC > ⚠️ `trustServerCertificate=true` disables TLS certificate validation — acceptable for dev/migration, but review before production use.

# COMMAND ----------

# DBTITLE 1,Read sales_fact via JDBC

# Configure the source connection
jdbc_url = (
    "jdbc:sqlserver://source-server.company.com:1433;"
    "database=warehouse;encrypt=true;trustServerCertificate=true"
)
connection_props = {
    "user":     dbutils.secrets.get("migration", "src_user"),
    "password": dbutils.secrets.get("migration", "src_password"),
    "driver":   "com.microsoft.sqlserver.jdbc.SQLServerDriver",
}

# Dynamically fetch actual max sale_id to avoid skewed partitions
max_row = (
    spark.read.format("jdbc")
    .option("url", jdbc_url)
    .option("dbtable", "(SELECT MAX(sale_id) AS max_id FROM dbo.sales_fact) t")
    .options(**connection_props)
    .load()
    .collect()[0]
)
upper_bound = int(max_row["max_id"])

# Read with partitioning for parallelism on large tables
df = (
    spark.read
    .format("jdbc")
    .option("url", jdbc_url)
    .option("dbtable", "dbo.sales_fact")
    .option("partitionColumn", "sale_id")
    .option("lowerBound", 1)
    .option("upperBound", upper_bound)
    .option("numPartitions", 16)
    .option("fetchsize", 10000)
    .options(**connection_props)
    .load()
)


# COMMAND ----------

# DBTITLE 1,Parallel multi-table JDBC load
tables = [
    # (source_table, target_table, partition_key, upper_bound)
    ("dbo.sales_fact", "sales.bronze.sales_fact", "sale_id",      50_000_000),
    ("dbo.customer",   "sales.bronze.customer",   "customer_id",   5_000_000),
    ("dbo.product",    "sales.bronze.product",    "product_id",      250_000),
    # ... add more tables here
]

for src_table, tgt_table, key, upper in tables:
    df = (
        spark.read
        .format("jdbc")
        .option("url", jdbc_url)
        .option("dbtable", src_table)
        .option("partitionColumn", key)
        .option("lowerBound", 1)
        .option("upperBound", upper)
        .option("numPartitions", 16)
        .option("fetchsize", 10000)
        .options(**connection_props)
        .load()
    )
    row_count = df.count()  # count before write to avoid re-scanning JDBC
    (df.write
        .format("delta")
        .mode("overwrite")
        .saveAsTable(tgt_table))
    print(f"Loaded {src_table} -> {tgt_table}: {row_count:,} rows")
