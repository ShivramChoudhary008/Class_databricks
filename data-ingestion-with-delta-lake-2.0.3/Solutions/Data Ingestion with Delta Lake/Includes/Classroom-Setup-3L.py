# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------


DA = DBAcademyHelper()
DA.init()
# setattr(DA, 'paths.kafka_events', f"{DA.paths.datasets.ecommerce}/raw/events-kafka")


DA.display_config_values([('Course Catalog',DA.catalog_name),('Your Schema',DA.schema_name)])

# spark.sql("set spark.databricks.delta.copyInto.formatCheck.enabled = false")
