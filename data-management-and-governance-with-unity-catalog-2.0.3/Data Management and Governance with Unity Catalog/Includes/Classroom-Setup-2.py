# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

## Creates the silver table and vw_gold view for the lab.
DA.create_schema_table_view()

## Clean the user's schema in the hive_metastore if exists.
DA.cleanup_hive_metastore()


DA.display_config_values([
        ('Your Unity Catalog name',DA.catalog_name),
        ('Your Schema Name','example'),    
        ]
    )

# COMMAND ----------


