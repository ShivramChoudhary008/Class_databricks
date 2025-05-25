# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

DA.display_config_values([('Course Catalog',DA.catalog_name),('Your Schema',DA.schema_name)])

# DA.clone_source_table("events", f"{DA.paths.datasets.ecommerce}/delta", "events_hist")

drop = spark.sql('DROP TABLE IF EXISTS events')
create_table = spark.sql('''
  CREATE TABLE events
  CLONE delta.`/Volumes/dbacademy_ecommerce/v01/delta/events_hist/`
''')
