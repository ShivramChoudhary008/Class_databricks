# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
# MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
# MAGIC </div>
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC # Pipeline Results
# MAGIC
# MAGIC
# MAGIC While DLT abstracts away many of the complexities associated with running production ETL on Databricks, many folks may wonder what's actually happening under the hood.
# MAGIC
# MAGIC In this notebook, we'll avoid getting too far into the weeds, but will explore how data and metadata are persisted by DLT.

# COMMAND ----------

# MAGIC %md
# MAGIC ## REQUIRED - SELECT CLASSIC COMPUTE
# MAGIC
# MAGIC Before executing cells in this notebook, please select your classic compute cluster in the lab. Be aware that **Serverless** is enabled by default.
# MAGIC
# MAGIC Follow these steps to select the classic compute cluster:
# MAGIC
# MAGIC 1. Navigate to the top-right of this notebook and click the drop-down menu to select your cluster. By default, the notebook will use **Serverless**.
# MAGIC
# MAGIC 1. If your cluster is available, select it and continue to the next cell. If the cluster is not shown:
# MAGIC
# MAGIC   - In the drop-down, select **More**.
# MAGIC
# MAGIC   - In the **Attach to an existing compute resource** pop-up, select the first drop-down. You will see a unique cluster name in that drop-down. Please select that cluster.
# MAGIC
# MAGIC **NOTE:** If your cluster has terminated, you might need to restart it in order to select it. To do this:
# MAGIC
# MAGIC 1. Right-click on **Compute** in the left navigation pane and select *Open in new tab*.
# MAGIC
# MAGIC 1. Find the triangle icon to the right of your compute cluster name and click it.
# MAGIC
# MAGIC 1. Wait a few minutes for the cluster to start.
# MAGIC
# MAGIC 1. Once the cluster is running, complete the steps above to select your cluster.

# COMMAND ----------

# MAGIC %md
# MAGIC ## A. Classroom Setup
# MAGIC
# MAGIC Run the following cell to configure your working environment for this course. It will also set your default catalog to **dbacademy** and the schema to your specific schema name shown below using the `USE` statements.
# MAGIC <br></br>
# MAGIC
# MAGIC
# MAGIC ```
# MAGIC USE CATALOG dbacademy;
# MAGIC USE SCHEMA dbacademy.<your unique schema name>;
# MAGIC ```
# MAGIC
# MAGIC **NOTE:** The `DA` object is only used in Databricks Academy courses and is not available outside of these courses. It will dynamically reference the information needed to run the course.

# COMMAND ----------

# MAGIC %run ./Includes/Classroom-Setup-4

# COMMAND ----------

# MAGIC %md
# MAGIC **NOTES:** 
# MAGIC - If you have not completed the DLT pipeline from the previous steps (**1a, 1b, and 1c**), uncomment and run the following cell to create the pipeline using the solution SQL notebooks to complete this demonstration. Wait a few minutes for the DLT pipeline to complete execution.
# MAGIC - If you have not completed demo **3 - Delta Live Tables Running Modes**, your numbers might not match, but you can still continue with the demonstration.

# COMMAND ----------

# DA.generate_pipeline(
#     pipeline_name=DA.generate_pipeline_name(), 
#     use_schema = DA.schema_name,
#     notebooks_folder='2A - SQL Pipelines/(Solutions) 2A - SQL Pipelines', 
#     pipeline_notebooks=[
#         '1 - Orders Pipeline',
#         '2 - Customers Pipeline',
#         '3L - Status Pipeline Lab'
#         ],
#     use_configuration = {'source':f'{DA.paths.stream_source}'}
#     )


# DA.start_pipeline()

# COMMAND ----------

# MAGIC %md
# MAGIC ## B. Querying Tables in the Target Database
# MAGIC
# MAGIC As long as a target database is specified during DLT Pipeline configuration, tables should be available to users throughout your Databricks environment. Let's explore them now. 
# MAGIC
# MAGIC Run the cell below to see the tables registered to the database used so far. The tables were created in the **dbacademy** catalog, within your unique **schema** name.

# COMMAND ----------

# MAGIC %sql
# MAGIC SHOW TABLES

# COMMAND ----------

# MAGIC %md
# MAGIC Note that the view we defined in our pipeline is absent from our tables list.
# MAGIC
# MAGIC Query results from the **`orders_bronze`** table.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * 
# MAGIC FROM orders_bronze

# COMMAND ----------

# MAGIC %md
# MAGIC Recall that **`orders_bronze`** was defined as a streaming table in DLT, but our results here are static.
# MAGIC
# MAGIC Because DLT uses Delta Lake to store all tables, each time a query is executed, we will always return the most recent version of the table. But queries outside of DLT will return snapshot results from DLT tables, regardless of how they were defined.

# COMMAND ----------

# MAGIC %md
# MAGIC ## C. Examine Results of `APPLY CHANGES INTO`
# MAGIC
# MAGIC Recall that the **customers_silver** table was implemented with changes from a CDC feed applied as Type 1 SCD.
# MAGIC
# MAGIC Let's query this table below.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * 
# MAGIC FROM customers_silver

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
# MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
# MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
# MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
# MAGIC <a href="https://help.databricks.com/">Support</a>
