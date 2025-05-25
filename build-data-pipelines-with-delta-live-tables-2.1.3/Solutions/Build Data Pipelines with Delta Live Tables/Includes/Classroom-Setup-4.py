# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

# COMMAND ----------

pipeline_language = None
# The location that the DLT databases should be written to
DA.paths.storage_location = f"{DA.paths.working_dir}/storage_location"
DA.dlt_data_factory = DataFactory()

DA.dlt_data_factory.load()
