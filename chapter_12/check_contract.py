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
