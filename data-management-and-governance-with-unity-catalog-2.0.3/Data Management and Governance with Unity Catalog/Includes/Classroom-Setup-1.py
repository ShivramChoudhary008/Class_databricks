# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

## Use the default catalog overwriting the DA _common USE catalog code. This is for showing users how to switch catalogs.
spark.sql('USE CATALOG dbacademy_movies')

## Create the dmguc schema (extra schema, not needed)
spark.sql(f"CREATE SCHEMA IF NOT EXISTS {DA.catalog_name}.dmguc")

## Create a schema to delete
spark.sql(f"CREATE SCHEMA IF NOT EXISTS {DA.catalog_name}.other")

DA.display_config_values([('Your Unity Catalog name',DA.catalog_name)])
