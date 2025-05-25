# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

DA.display_config_values([('Course Catalog',DA.catalog_name),('Your Schema',DA.schema_name)])

# COMMAND ----------

drop = spark.sql('DROP TABLE IF EXISTS users')
create_table = spark.sql('''
  CREATE TABLE users
  AS
  SELECT * 
  FROM delta.`/Volumes/dbacademy_ecommerce/v01/delta/users_hist`
''')

drop = spark.sql('DROP TABLE IF EXISTS events_update')
create_table = spark.sql('''
  CREATE TABLE events_update
  AS
  SELECT * 
  FROM delta.`/Volumes/dbacademy_ecommerce/v01/delta/events_update`
''')


drop = spark.sql('DROP TABLE IF EXISTS historical_sales_bronze')
create_table = spark.sql('''
  CREATE OR REPLACE TABLE historical_sales_bronze 
  AS
  SELECT * 
  FROM parquet.`/Volumes/dbacademy_ecommerce/v01/raw/sales-historical/`
''')

## OLD
# DA.clone_source_table("users", f"{DA.paths.datasets.ecommerce}/delta", "users_historical")
# DA.clone_source_table("events_update", f"{DA.paths.datasets.ecommerce}/delta")
