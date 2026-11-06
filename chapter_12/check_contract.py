import sys 
import yaml 
from pyspark.sql import SparkSession 
  
  
def contract_breaks(spark, product, contract): 
    # A list, not an exit: the certification job reuses this comparison. 
    actual = {f.name: f.dataType.simpleString() 
              for f in spark.table(product).schema} 
    breaking = [] 
    for field in contract["schema"]: 
        name, promised = field["name"], field["type"] 
        if name not in actual: 
            breaking.append(f"removed promised column '{name}'") 
        elif actual[name] != promised: 
            breaking.append(f"'{name}' changed {promised} -> {actual[name]}") 
    return breaking 
 
if __name__ == "__main__":  
  spark = SparkSession.builder.getOrCreate() 
  contract = yaml.safe_load(open(contract_path)) 
  product = f"{catalog}.orders.order_summary" 
  breaking = contract_breaks(spark, product, contract) 
 
  if breaking and not contract.get("major_bump_approved", False): 
    raise SystemExit("Contract violated, release blocked: " + "; ".join(breaking)) 
  print(f"Contract {contract['version']} satisfied for {product}.") 

 
# Runs as the certification job's service principal, the one identity with
# ASSIGN on system.certification_status, so no domain can self-certify.
product = "sales.orders.order_summary"
TAG = "`system.certification_status`"
contract = yaml.safe_load(open(sys.argv[1]))  # absolute path, as in the gate
checks = {
    "contract_holds": not contract_breaks(spark, product, contract),
    "freshness_slo_7d": freshness_slo_met(product, days=7),
    "has_owner_and_comment": has_owner_and_comment(product),
}

if all(checks.values()):
    spark.sql(f"SET TAG ON TABLE {product} {TAG} = `certified`")
    print(f"{product} certified.")
else:
    # Revoke rather than leave a stale badge. UNSET TAG is documented to
    # raise when the tag is absent, so look first: it costs one query.
    tagged = spark.sql("""
        SELECT 1 FROM sales.information_schema.table_tags
        WHERE schema_name = 'orders' AND table_name = 'order_summary'
          AND tag_name = 'system.certification_status'""").count() > 0
    if tagged:
        spark.sql(f"UNSET TAG ON TABLE {product} {TAG}")
    failed = [name for name, ok in checks.items() if not ok]
    print(f"{product} NOT certified. Failing checks: {failed}")
