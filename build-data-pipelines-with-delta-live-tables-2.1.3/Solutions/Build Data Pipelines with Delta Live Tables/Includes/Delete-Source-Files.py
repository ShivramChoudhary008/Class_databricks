# Databricks notebook source
# MAGIC %md
# MAGIC Remove all source files and restart the continuous demo.
# MAGIC
# MAGIC 1. Run the following code to delete all source files.
# MAGIC 2. Delete your DLT pipeline you created in the course.
# MAGIC 3. Restart demonstration.

# COMMAND ----------

# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------


DA = DBAcademyHelper()
DA.init()
setattr(DA, 'paths.storage_location', f'{DA.paths.working_dir}/storage_location')

DA.dlt_data_factory = DataFactory()
DA.dlt_data_factory.load()


DA.delete_all_files()
