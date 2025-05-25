# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

## Create a new schema
spark.sql('CREATE SCHEMA IF NOT EXISTS example')

## Make our newly created schema the default
spark.sql('USE SCHEMA example')

# COMMAND ----------



## Create the silver table
r = spark.sql('DROP TABLE IF EXISTS silver')

print("\nCreating the silver table in your catalog's example schema")
r = spark.sql('''
CREATE OR REPLACE TABLE silver (
  device_id  INT,
  mrn        STRING,
  name       STRING,
  time       TIMESTAMP,
  heartrate  DOUBLE
)
''')

r = spark.sql('''
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

# COMMAND ----------

DA.display_config_values([
            ('Your Unity Catalog name', DA.catalog_name),
            ('Your Course Schema Name', 'example')
        ]
    )
