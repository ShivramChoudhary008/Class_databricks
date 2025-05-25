# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()


## DA.clone_source_table("sales", f"{DA.paths.datasets.ecommerce}/delta", "sales_hist")
drop = spark.sql('DROP TABLE IF EXISTS sales')
create_table = spark.sql('''
  CREATE OR REPLACE TABLE sales 
  AS
  SELECT * 
  FROM delta.`/Volumes/dbacademy_ecommerce/v01/delta/sales_hist`
''')

## DA.clone_source_table("events", f"{DA.paths.datasets.ecommerce}/delta", "events_hist")
drop = spark.sql('DROP TABLE IF EXISTS events')
create_table = spark.sql('''
  CREATE TABLE events
  AS
  SELECT * 
  FROM delta.`/Volumes/dbacademy_ecommerce/v01/delta/events_hist`
''')


## DA.clone_source_table("events_raw", f"{DA.paths.datasets.ecommerce}/delta")
drop = spark.sql('DROP TABLE IF EXISTS events_raw')
create_table = spark.sql('''
  CREATE TABLE events_raw
  AS
  SELECT * 
  FROM delta.`/Volumes/dbacademy_ecommerce/v01/delta/events_raw`
''')


## DA.clone_source_table("item_lookup", f"{DA.paths.datasets.ecommerce}/delta")
drop = spark.sql('DROP TABLE IF EXISTS item_lookup')
create_table = spark.sql('''
  CREATE TABLE item_lookup
  AS
  SELECT * 
  FROM delta.`/Volumes/dbacademy_ecommerce/v01/delta/item_lookup`
''')


DA.display_config_values([('Course Catalog',DA.catalog_name),('Your Schema',DA.schema_name)])
