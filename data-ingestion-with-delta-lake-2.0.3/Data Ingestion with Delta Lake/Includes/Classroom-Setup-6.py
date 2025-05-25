# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

DA.display_config_values([('Course Catalog',DA.catalog_name),('Your Schema',DA.schema_name)])

drop = spark.sql('DROP TABLE IF EXISTS item_lookup')
create_table = spark.sql('''
  CREATE TABLE item_lookup
  CLONE delta.`/Volumes/dbacademy_ecommerce/v01/delta/item_lookup/`
''')

# DA.clone_source_table("sales", f"{DA.paths.datasets.ecommerce}/delta", "sales_hist")
# DA.clone_source_table("events", f"{DA.paths.datasets.ecommerce}/delta", "events_hist")
# DA.clone_source_table("events_raw", f"{DA.paths.datasets.ecommerce}/delta")
# DA.clone_source_table("item_lookup", f"{DA.paths.datasets.ecommerce}/delta")

# COMMAND ----------


