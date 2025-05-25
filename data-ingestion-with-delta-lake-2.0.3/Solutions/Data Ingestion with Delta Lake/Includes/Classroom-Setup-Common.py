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
def clone_source_table(self, table_name, source_path=None, source_name=None):

    if source_path is None: source_path = self.paths.datasets.ecommerce
    if source_name is None: source_name = table_name

    print(f"Cloning the \"{table_name}\" table from \"{source_path}/{source_name}\".", end="...")
    
    # spark.sql("set spark.databricks.delta.copyInto.formatCheck.enabled = false")
    spark.sql(f"DROP TABLE IF EXISTS {table_name}")
    spark.sql(f"CREATE TABLE {table_name}")
    spark.sql(f"""   
        COPY INTO {table_name}
            FROM '{source_path}/{source_name}'
            FILEFORMAT = DELTA
            COPY_OPTIONS ('mergeSchema' = 'true');
        """)
