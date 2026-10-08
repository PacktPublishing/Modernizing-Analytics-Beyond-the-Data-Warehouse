import pyspark.sql.functions as F
from databricks.feature_engineering import FeatureEngineeringClient 

# Read the governed silver table 
df = spark.table("catalog_prod.finance.silver_transactions") 
 
# Feature engineering over all available data 
features = (df.groupBy("account_id") 
              .agg( 
                   F.count("*").alias("transaction_count"), 
                   F.avg("amount").alias("avg_amount"), 
                   F.stddev("amount").alias("stddev_amount"), 
                   F.max("amount").alias("max_amount") 
                  )) 
 
# Register as feature table in Unity Catalog 
fe = FeatureEngineeringClient() 

fe.create_table( 
   name="catalog_prod.finance.account_features", 
    primary_keys=["account_id"], 
    df=features, 
    description="Account-level transaction features for fraud detection" 
) 
