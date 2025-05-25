# Databricks notebook source
# MAGIC %run ../../Includes/_common

# COMMAND ----------

## This will create a DA variable in SQL to use in SQL queries.
## Queries the dbacademy.ops.meta table and uses those key-value pairs to populate the DA variable for SQL queries.
## Variable can't be used with USE CATALOG in databricks.

create_temp_view = '''
CREATE OR REPLACE TEMP VIEW user_info AS
SELECT map_from_arrays(collect_list(replace(key,'.','_')), collect_list(value))
FROM dbacademy.ops.meta
'''

declare_variable = 'DECLARE OR REPLACE DA MAP<STRING,STRING>'

set_variable_from_view = 'SET VAR DA = (SELECT * FROM user_info)'

spark.sql(create_temp_view)
spark.sql(declare_variable)
spark.sql(set_variable_from_view)

## Drop the view after the creation of the DA variable
spark.sql('DROP VIEW IF EXISTS user_info');

# COMMAND ----------

@DBAcademyHelper.add_method
def create_schema_table_view(self):
    """
    - Creates the example schema in the user's catalog
    - Creates the silver table in the example schema
    - Creates the vw_gold view in the example schema
    """
    
    ## Set the catalog to use
    spark.sql(f'USE CATALOG {self.catalog_name}')
    
    ## Create the example schema in user's catalog
    spark.sql('CREATE SCHEMA IF NOT EXISTS example')
    spark.sql('USE SCHEMA example')

    ## Create silver table
    ct = spark.sql('''
        CREATE OR REPLACE TABLE silver (
            device_id  INT,
            mrn        STRING,
            name       STRING,
            time       TIMESTAMP,
            heartrate  DOUBLE
        )
        ''')
    

    insert_rows = spark.sql('''
    INSERT OVERWRITE silver VALUES
    (23,'40580129','Nicholas Spears','2020-02-01T00:01:58.000+0000',54.0122153343),
    (17,'52804177','Lynn Russell','2020-02-01T00:02:55.000+0000',92.5136468131),
    (37,'65300842','Samuel Hughes','2020-02-01T00:08:58.000+0000',52.1354807863),
    (23,'40580129','Nicholas Spears','2020-02-01T00:16:51.000+0000',54.6477014191),
    (17,'52804177','Lynn Russell','2020-02-01T00:18:08.000+0000',95.033344842),
    (37,'65300842','Samuel Hughes','2020-02-01T00:23:58.000+0000',57.3391541312),
    (23,'40580129','Nicholas Spears','2020-02-01T00:31:58.000+0000',56.6165053697),
    (17,'52804177','Lynn Russell','2020-02-01T00:32:56.000+0000',94.8134313932),
    (37,'65300842','Samuel Hughes','2020-02-01T00:38:54.000+0000',56.2469995332),
    (23,'40580129','Nicholas Spears','2020-02-01T00:46:57.000+0000',54.8372685558),
    (23,'40580129',NULL,'2020-02-01T00:01:58.000+0000',54.0122153343),
    (17,'52804177',NULL,'2020-02-01T00:02:55.000+0000',92.5136468131),
    (37,'65300842',NULL,'2020-02-01T00:08:58.000+0000',1000052.1354807863),
    (23,'40580129',NULL,'2020-02-01T00:16:51.000+0000',54.6477014191),
    (17,'52804177','Lynn Russell','2020-02-01T00:18:08.000+0000',9),
    (37,'65300842','Samuel Hughes','2020-02-01T00:23:58.000+0000',7),
    (23,'40580129','Nicholas Spears','2020-02-01T00:31:58.000+0000',6),
    (17,'52804177','Lynn Russell','2020-02-01T00:32:56.000+0000',5),
    (37,'65300842','Samuel Hughes','2020-02-01T00:38:54.000+0000',9000),
    (23,'40580129','Nicholas Spears','2020-02-01T00:46:57.000+0000',66),
    (23,'40580129',NULL,'2020-02-01T00:01:58.000+0000',54.0122153343),
    (17,'52804177',NULL,'2020-02-01T00:02:55.000+0000',92.5136468131),
    (37,'65300842',NULL,'2020-02-01T00:08:58.000+0000',1000052.1354807863),
    (23,'40580129',NULL,'2020-02-01T00:16:51.000+0000',54.6477014191),
    (17,'52804177','Lynn Russell','2020-02-01T00:18:08.000+0000',98),
    (37,'65300842','Samuel Hughes','2020-02-01T00:23:58.000+0000',90),
    (23,'40580129','Nicholas Spears','2020-02-01T00:31:58.000+0000',60),
    (17,'52804177','Lynn Russell','2020-02-01T00:32:56.000+0000',50),
    (37,'65300842','Samuel Hughes','2020-02-01T00:38:54.000+0000',30),
    (23,'40580129','Nicholas Spears','2020-02-01T00:46:57.000+0000',80)
    ''')


    create_view = spark.sql(f'''
        CREATE OR REPLACE VIEW vw_gold AS (
        SELECT 
            mrn, 
            name, 
            MEAN(heartrate) 
            avg_heartrate, 
            DATE_TRUNC("DD", time) AS date
        FROM silver
        GROUP BY mrn, name, DATE_TRUNC("DD", time)
        )          
    ''')


    create_sql_function = spark.sql(f'''
        CREATE OR REPLACE FUNCTION dbacademy_mask(x STRING)
            RETURNS STRING
            RETURN CONCAT(LEFT(x, 2) , REPEAT("*", LENGTH(x) - 2))
        ''')

    print(f"Created the silver table and vw_gold view in your catalog {self.catalog_name} with the example schema.")
    print(f"Set the default catalog to {self.catalog_name}.")
    print("Set the default schema to example.")

# COMMAND ----------

# def cleanup(self):

# COMMAND ----------

@DBAcademyHelper.add_method
def cleanup_hive_metastore(self):
    '''
    Delete user's schema in the hive_metastore
    '''
    #List all schemas in the hive_metastore catalog
    schemas = spark.sql("SHOW SCHEMAS IN hive_metastore").collect()
    schema_names = [schema.databaseName for schema in schemas]

    #Generate and execute drop statements for each schema
    for schema in schema_names:
        if schema == self.catalog_name:  
            drop_statement = f"DROP SCHEMA IF EXISTS hive_metastore.{self.catalog_name} CASCADE"
            print(f"Dropping Schema: {self.catalog_name} in hive_metastore.")
            spark.sql(drop_statement)
