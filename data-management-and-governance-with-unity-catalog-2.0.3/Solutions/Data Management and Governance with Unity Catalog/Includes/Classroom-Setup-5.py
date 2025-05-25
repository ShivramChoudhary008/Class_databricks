# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

schema = spark.sql('CREATE SCHEMA IF NOT EXISTS default')
schema_use = spark.sql('USE SCHEMA default')

print('Dropping the customers table in your default schema if it exists.')
drop_table = spark.sql('DROP TABLE IF EXISTS customers')

print('Dropping the customers_new table in your default schema if it exists.')
drop_table = spark.sql('DROP TABLE IF EXISTS customers_new')

print('Dropping the vw_customers view in your default schema if it exists.')
drop_table = spark.sql('DROP VIEW IF EXISTS vw_customers')

## Clear the hive_metastore
DA.cleanup_hive_metastore()

# COMMAND ----------

## Display user catalog information
DA.display_config_values([('Your Unity Catalog name',DA.catalog_name),('Your Default Schema', "default")])
