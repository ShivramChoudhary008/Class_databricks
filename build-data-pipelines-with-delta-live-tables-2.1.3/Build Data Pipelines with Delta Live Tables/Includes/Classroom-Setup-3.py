# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

# The location that the DLT databases should be written to
setattr(DA, 'paths.storage_location', f'{DA.paths.working_dir}/storage_location')
DA.dlt_data_factory = DataFactory()
DA.dlt_data_factory.load()
