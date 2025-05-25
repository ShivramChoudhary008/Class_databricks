# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

## Recreate example schema, silver and vw_gold
DA.create_schema_table_view()

## Clean up user's schema in hive_metastore
DA.cleanup_hive_metastore()



## Drop the movies table to restart the lesson if required
drop_movies = spark.sql(f'DROP TABLE IF EXISTS {DA.catalog_name}.examples.movies_clone')


## Set hive metastore schema name
setattr(DA, 'user_hive_schema', f'{DA.catalog_name}')

## Create STRING sql variable to reference hive
declare_variable = spark.sql('DECLARE OR REPLACE user_hive_schema STRING')
set_variable_from_view = spark.sql(f'SET VAR user_hive_schema = DA.catalog_name')



##
## Create data in hive_metastore for the user within their own schema using their unique catalog/compute name.
##

## Create a schema in hive for the user
create_user_schema_in_hive = spark.sql(f'CREATE SCHEMA IF NOT EXISTS hive_metastore.{DA.user_hive_schema}')

## Create the movies table in the hive_metastore catalog, user's schema name
create_movies_table_in_hive = spark.sql(f"""
                CREATE OR REPLACE TABLE hive_metastore.{DA.user_hive_schema}.movies 
                AS 
                SELECT * FROM dbacademy_movies.movies_samples.movies_bronze
                LIMIT 1000
                """)

print(f'Created a schema in the hive_metastore named {DA.user_hive_schema} for the user and populated it with the movies table.')

## Display user catalog information
DA.display_config_values([
                          ('Your Unity Catalog name',DA.catalog_name),
                          ('Your Default Schema', "example"),
                          ('Your Schema in the hive_metastore catalog',f'hive_metastore.{DA.user_hive_schema}')
                      ])
