# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
# MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
# MAGIC </div>
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC # Delta Live Tables Running Modes
# MAGIC We can trigger execution of DLT pipelines in two modes: triggered and continuous. In triggered mode, we can trigger the pipeline manually or schedule the pipeline to run on specific increments. Let's explore these modes more fully.
# MAGIC
# MAGIC Run the following setup script to get started.

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

# MAGIC %run ./Includes/Classroom-Setup-3

# COMMAND ----------

# MAGIC %md
# MAGIC **NOTE:** If you have not completed the DLT pipeline from the previous steps (**1a, 1b and 1c**), uncomment and run the following cell to create the pipeline using the solution SQL notebooks to complete this demonstration.

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

# COMMAND ----------

# MAGIC %md
# MAGIC Run the next cell. We are going to use its job name from the output in the next steps.

# COMMAND ----------

DA.print_pipeline_job_info()

# COMMAND ----------

# MAGIC %md
# MAGIC ## B. Scheduled Execution
# MAGIC DLT pipelines can be triggered on increments from one minute to one month, all at a specific time of day. Additionally, we can trigger alerts for when the pipeline starts, successfully completes, or fails. Follow the steps below to schedule DLT pipeline runs:
# MAGIC
# MAGIC 1. Find your pipeline using the name from the above cell. Go to your pipeline's configuration page. 
# MAGIC
# MAGIC 2. In the upper-right corner, drop open the **`Schedule`**. Note the dialog that appears. We are actually going to be creating a job that will have one task, our pipeline
# MAGIC
# MAGIC 3. In the **Advanced** tab, set the schedule to every month, but note the other options
# MAGIC
# MAGIC 4. Select the **More options** drop down. Note that we can set notifications for start, success, and failure
# MAGIC
# MAGIC 5. Click **Create**. A small window appears in the upper-right corner that shows our job was successfully created. The **Schedule** drop-down remains open and shows our current job, and we can add additional schedules, if needed.
# MAGIC
# MAGIC 6. Select the job link in the pop up. It will take you to the Workflow (job).
# MAGIC
# MAGIC 7. Click the **Tasks** tab in the upper-left corner
# MAGIC
# MAGIC Our DLT pipeline is the only task for this job. If we wished, we could configure additional tasks.  
# MAGIC   
# MAGIC The task's configuration fields give us more options for the task.  We can: 
# MAGIC * Trigger a full refresh on the Delta Live Tables pipeline
# MAGIC * Add, or change, notifications
# MAGIC * Configure a retry policy for the task
# MAGIC * Set duration thresholds where we can set times where we want to be warned that a pipeline is taking longer than expected or how long before we should cause the pipeline to timeout.  
# MAGIC   
# MAGIC 8. Lastly, there are options on the right side for the whole job. We can see the schedule we created under **Schedules & Triggers**
# MAGIC
# MAGIC 9. We will not be using the job. Click the "kebab" menu to the left of the **Run now** button, and select **Delete job**
# MAGIC
# MAGIC 10. Leave the **Workflows** page open.

# COMMAND ----------

# MAGIC %md
# MAGIC ## C. Continuous Execution
# MAGIC Setting a DLT pipeline to continuous execution will cause the pipeline to run continuously and process data as it arrives in our data sources. To avoid unnecessary processing in continuous execution mode, pipelines automatically monitor dependent Delta tables and perform an update only when the contents of those dependent tables have changed.
# MAGIC
# MAGIC Please note: After a pipeline is set to continuous mode and the pipeline is started, a cluster will run continuously until manually stopped. This will add to costs.
# MAGIC
# MAGIC To configure a DLT pipeline for continuous execution, complete the following:
# MAGIC
# MAGIC 1. On the **Workflows** page select **Pipelines** in the navigation bar and select your pipeline.
# MAGIC
# MAGIC 2. On the pipeline configuration page, click **Settings** at the top right of the page.
# MAGIC
# MAGIC 3. Under **Pipeline mode**, select **Continuous**
# MAGIC
# MAGIC 4. Click **Save and start**
# MAGIC
# MAGIC The pipeline immediately begins its startup process. This process is very similar to a manually triggered start, except that after the first pipeline run, the pipeline will not shutdown, but will continue to monitor for new data.
# MAGIC
# MAGIC Wait for the pipeline to complete before starting the next steps.

# COMMAND ----------

# MAGIC %md
# MAGIC ## D. Get Current Data from Silver Table

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC ### D1. View the tables in your schema
# MAGIC
# MAGIC 1. Navigate to the Catalog icon in the vertical bar (directly to the left of the notebook beneath the **File** icon). This will display all of the available catalogs to the left of the notebook. Do not select the **Catalog** text in the main navigation bar on the far left.
# MAGIC
# MAGIC 2. Expand the **dbacademy** catalog.
# MAGIC
# MAGIC 3. Expand your unique schema name.
# MAGIC
# MAGIC 4. Notice that the DLT pipeline created all of the streaming tables and materialized views in the location you specified.

# COMMAND ----------

# MAGIC %md
# MAGIC ### D2. Query your materialized view
# MAGIC Run the cell below to get the current data for a customer named "Michael Lewis".
# MAGIC
# MAGIC Note the current address for *Michael Lewis* is *706 Melissa Canyon*.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT name, address 
# MAGIC FROM customers_silver 
# MAGIC WHERE name = "Michael Lewis"

# COMMAND ----------

# MAGIC %md
# MAGIC ## E. Let's Add Data
# MAGIC The `DA` object that was created in the Classroom-Setup script we ran at the beginning of this lesson contains a method that will add data to our volume. Let's use this method to see how our continuously running pipeline updates our resulting tables. 
# MAGIC
# MAGIC We will be examining our pipeline results more fully in the next lesson. Run the next cell. While the cell is running you can watch your DLT pipeline and view as data is ingested and created.
# MAGIC
# MAGIC While the cell is running watch your DLT pipeline. Notice that the numbers are changing on each task.
# MAGIC
# MAGIC **Important** - The cell will throw an error if the pipeline has not completed at least one run. If you get an error that the table does not exist, wait for the pipeline to complete one run.

# COMMAND ----------

DA.dlt_data_factory.load(continuous=True, delay_seconds=0)

# COMMAND ----------

# MAGIC %md
# MAGIC ## F. Requery Data
# MAGIC Run the cell below, and note it is the same code that we ran before adding data to our source directory. 
# MAGIC
# MAGIC We added 30 files of data to our source directory. This data included updated information for some of our fake customers. Michael Lewis changed his address, so this change should be reflected in our silver-level customers table. 
# MAGIC
# MAGIC If you run this query too quickly, the pipeline will not have completed its update, and the address will not have changed. Wait a few seconds, and rerun the query.
# MAGIC
# MAGIC The results should show that *Michael Lewis* has an updated address to *451 Hunt Station*.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT name, address 
# MAGIC FROM customers_silver 
# MAGIC WHERE name = "Michael Lewis"

# COMMAND ----------

# MAGIC %md
# MAGIC ## G. (REQUIRED!) Stop the Pipeline
# MAGIC If we do not stop the pipeline, it will continue to run indefinitely.
# MAGIC
# MAGIC * Stop the pipeline by clicking **`Stop`**

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
# MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
# MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
# MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
# MAGIC <a href="https://help.databricks.com/">Support</a>
