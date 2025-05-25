# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
# MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
# MAGIC </div>
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC # Using the Delta Live Tables UI - PART 2 - Customers
# MAGIC
# MAGIC This demo will explore the DLT UI. By the end of this lesson you will be able to: 
# MAGIC
# MAGIC * Deploy a DLT pipeline
# MAGIC * Explore the resultant DAG
# MAGIC * Execute an update of the pipeline
# MAGIC
# MAGIC This demonstration will focus on using SQL code with DLT. Python notebooks are available that replicate the SQL code.

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

# MAGIC %run ./Includes/Classroom-Setup-1

# COMMAND ----------

# MAGIC %md
# MAGIC ## B. Generate Pipeline Configuration
# MAGIC Run the following cell to obtain the pipeline configuration information we saw earlier. Modify the pipeline_language if necessary.

# COMMAND ----------

pipeline_language = "SQL"
# pipeline_language = "Python"

DA.print_pipeline_config(pipeline_language)

# COMMAND ----------

# MAGIC %md
# MAGIC ## PART 2 - Add a Second Notebook to a DLT Pipeline

# COMMAND ----------

# MAGIC %md
# MAGIC Add **Notebook #2** to the DLT pipeline you created earlier. Complete the following:
# MAGIC
# MAGIC 1. Navigate back to your DLT pipeline.
# MAGIC
# MAGIC 2. Select **Settings** at the top right corner.
# MAGIC
# MAGIC 3. In the **Source code** section select **Add source code** and add the path to **Notebook #2 - Customers Pipeline** using the cell above.
# MAGIC     - You can also manually navigate to the notebook using the UI:
# MAGIC       - For SQL: **Course folder** -> **2A - SQL Pipelines** -> **2 - Customers Pipeline**
# MAGIC       - For Python: **Course folder** -> **2B - Python Pipelines** -> **2 - Customers Pipeline**
# MAGIC
# MAGIC 4. Select **Save** at the bottom right of the screen to save the DLT pipeline.
# MAGIC
# MAGIC 5. Select the drop down arrow to the right of **Start** and select **Full refresh all** to rerun and refresh the entire DLT pipeline with the additional notebook.
# MAGIC     - **IMPORTANT NOTE:** Remember, with a **Full refresh all**, all tables are updated to reflect the current state of their input data sources. For streaming tables, Delta Live Tables attempts to clear all data from each table and then load all data from the input streaming source.
# MAGIC
# MAGIC 6. While the DLT pipeline is running, examine Notebook **2 - Customers Pipeline** and review the code.
# MAGIC     - [SQL Notebook 2 - Customers Pipeline]($./2A - SQL Pipelines/2 - Customers Pipeline)
# MAGIC     - [Python Notebook 2 - Customers Pipeline]($./2B - Python Pipelines/2 - Customers Pipeline)
# MAGIC
# MAGIC 7. Your DLT pipeline DAG should look like the following:
# MAGIC
# MAGIC <br></br>
# MAGIC ![RunTwoNotebookDLTPipeline](files/images/build-data-pipelines-with-delta-live-tables-2.1.3/RunTwoNotebookDLTPipeline.png)

# COMMAND ----------

# MAGIC %md
# MAGIC ## C. DLT Python vs SQL

# COMMAND ----------

# MAGIC %md
# MAGIC | Python | SQL | Notes |
# MAGIC |--------|--------|--------|
# MAGIC | Python API | Proprietary SQL API |  |
# MAGIC | No syntax check | Has syntax checks| In Python, if you run a DLT notebook cell on its own it will show in error, whereas in SQL it will check if the command is syntactically valid and tell you. In both cases, individual notebook cells are not supposed to be run for DLT pipelines. |
# MAGIC | A note on imports | None | The dlt module should be explicitly imported into your Python notebook libraries. In SQL, this is not the case. |
# MAGIC | Tables as DataFrames | Tables as query results | The Python DataFrame API allows for multiple transformations of a dataset by stringing multiple API calls together. Compared to SQL, those same transformations must be saved in temporary tables as they are transformed. |
# MAGIC |`@dlt.table()`  | `SELECT` statement | In SQL, the core logic of your query, containing transformations you make to your data, is contained in the `SELECT` statement. In Python, data transformations are specified when you configure options for @dlt.table().  |
# MAGIC | `@dlt.table(comment = `"Python comment",`table_properties = {"quality": "silver"})` | `COMMENT` "SQL comment"       `TBLPROPERTIES ("quality" = "silver")` | This is how you add comments and table properties in Python vs. SQL |
# MAGIC | Python Metaprogramming | N/A | You can use Python inner functions with Delta Live Tables to programmatically create multiple tables to reduce code redundancy.

# COMMAND ----------

# MAGIC %md
# MAGIC # Complete the Lab
# MAGIC ## Open the notebook: 1c - Using the Delta Live Tables UI - PART 3 Lab - Status

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
# MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
# MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
# MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
# MAGIC <a href="https://help.databricks.com/">Support</a>
