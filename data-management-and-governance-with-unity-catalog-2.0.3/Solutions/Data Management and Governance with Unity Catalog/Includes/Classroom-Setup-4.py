# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

## Recreate example schema, silver and vw_gold
DA.create_schema_table_view()


DA.display_config_values([('Your Unity Catalog name',DA.catalog_name),('Your Default Schema', "example")])

# COMMAND ----------

DA.cleanup_hive_metastore()
