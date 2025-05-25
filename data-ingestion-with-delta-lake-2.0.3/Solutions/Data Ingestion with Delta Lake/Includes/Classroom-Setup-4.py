# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

@DBAcademyHelper.add_method
def _create_eltwss_users_update(self):
    import time
    import pyspark.sql.functions as F
    start = int(time.time())
    print(f"\nCreating the table \"users_bronze\"", end="...")

    spark.sql("DROP TABLE IF EXISTS users_bronze")

    df = spark.createDataFrame(data=[
                                    (None, None, None, None), 
                                    (None, None, None, None), 
                                    (None, None, None, None)
                              ], 
                               schema="user_id: string, user_first_touch_timestamp: long, email:string, updated:timestamp")
    (spark.read
          .parquet(f"{DA.paths.datasets.ecommerce}/raw/users-30m")
          .withColumn("updated", F.current_timestamp())
          .select("user_id", "user_first_touch_timestamp", "email", "updated")
          .union(df)
          .write
          .mode("overwrite")
          .saveAsTable("users_bronze"))
    
    total = spark.read.table("users_bronze").count()
    print(f"({int(time.time())-start} seconds / {total:,} records)")

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

DA._create_eltwss_users_update()
    
DA.display_config_values([('Course Catalog',DA.catalog_name),('Your Schema',DA.schema_name)])
