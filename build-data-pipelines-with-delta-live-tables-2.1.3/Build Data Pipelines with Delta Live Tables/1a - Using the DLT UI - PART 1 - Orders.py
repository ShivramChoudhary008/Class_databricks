# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
# MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
# MAGIC </div>
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC # Using the Delta Live Tables UI - PART 1 - Orders
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
# MAGIC ## B. Explore Available Raw Files

# COMMAND ----------

# MAGIC %md
# MAGIC Complete the following steps to explore the available raw data files that will be used for the DLT pipeline:
# MAGIC
# MAGIC 1. Navigate to the available catalogs by selecting the catalog icon directly to the left of the notebook (do not select the **Catalog** text in the far left navigation bar).
# MAGIC
# MAGIC 2. Expand the **dbacademy** catalog.
# MAGIC
# MAGIC 3. Expand the **ops** schema.
# MAGIC
# MAGIC 4. Expand the **Volumes** within the **ops** schema.
# MAGIC
# MAGIC 5. Expand the volume that contains your **unique username**.
# MAGIC
# MAGIC 6. Expand the **stream-source** directory. Notice that the directory contains three subdirectories: **customers**, **orders**, and **status**.
# MAGIC
# MAGIC 7. Expand each subdirectory. Notice that each contains a JSON file (00.json) with raw data. We will create a DLT pipeline that will ingest the files within this volume to create tables and materialized views for our consumers.

# COMMAND ----------

# MAGIC %md
# MAGIC ## C. Generate Pipeline Configuration
# MAGIC Delta Live Tables (DLT) pipelines can be written in either SQL or python. In this course, we have written examples in both languages. In the code cell below, note that we are first going to look at the SQL example. 
# MAGIC
# MAGIC We are going to manually configure a pipeline using the DLT UI. Configuring this pipeline will require parameters unique to a given user. Run the cell to print out values you'll use to configure your pipeline in subsequent steps.

# COMMAND ----------

pipeline_language = "SQL"
# pipeline_language = "Python"

DA.print_pipeline_config(pipeline_language)

# COMMAND ----------

# MAGIC %md
# MAGIC ## PART 1 - Add a Single Notebook to a DLT Pipeline

# COMMAND ----------

# MAGIC %md
# MAGIC ### PART 1.1 - Create and Configure a Pipeline
# MAGIC
# MAGIC Complete the following steps to configure the pipeline.
# MAGIC
# MAGIC 1. Open the **Pipelines** UI:
# MAGIC     - Find **Pipelines** under the **Data Engineering** section in the left navigation bar.
# MAGIC     - Right click on **Pipelines** to select *Open Link in a New Tab*. Make sure to open it in a new tab so you can continue to follow along this notebook.
# MAGIC
# MAGIC 2. Click **Create pipeline** in the upper-right corner and Select **ETL Pipeline** to create a DLT pipeline.
# MAGIC
# MAGIC 3. Configure the pipeline as specified below. You'll need the values provided in the cell output above for this step.
# MAGIC
# MAGIC | Setting | Instructions |
# MAGIC |--|--|
# MAGIC | Pipeline name | Enter the **Pipeline Name** provided above |
# MAGIC | Serverless | Choose **Serverless** |
# MAGIC | Product edition (not needed with Serverless) | Choose **Advanced**  |
# MAGIC | Pipeline mode | Choose **Triggered** |
# MAGIC | Paths| Use the navigator to select or enter the path for ONLY **Notebook #1** from the cell provided above |
# MAGIC | Storage options | Choose **Unity Catalog** (should already be selected by default)  |
# MAGIC | Default Catalog | Choose your **Default Catalog** provided above (**dbacademy**) |
# MAGIC | Default schema | Choose your **Default schema** provided above (your unique schema name) |
# MAGIC | Configuration | Click **Add Configuration** and input the **Key** and **Value** using the table below |
# MAGIC | Channel | Choose **Current** |
# MAGIC
# MAGIC #### Configuration Details
# MAGIC **NOTE:** The **source** key references the path to your raw files which reside in your volume. The **source** variable will be used in your notebooks to dynamically reference the volume location: 
# MAGIC - Source Volume Path Example: */Volumes/dbacademy/ops/\<your-unique-user-name-from-cell-above>/stream-source*
# MAGIC
# MAGIC | Key                 | Value                                      |
# MAGIC | ------------------- | ------------------------------------------ |
# MAGIC | **`source`** | Enter the **Source** provided in the previous code cell |
# MAGIC
# MAGIC
# MAGIC </br>
# MAGIC
# MAGIC 4. Click the **Create** button to create the DLT pipeline. Leave the Pipelines UI open.

# COMMAND ----------

# MAGIC %md
# MAGIC ### PART 1.2 - Check Your Pipeline Configuration
# MAGIC
# MAGIC ![new_pipeline_editor](files/images/build-data-pipelines-with-delta-live-tables-2.1.3/new_pipeline_editor.png)
# MAGIC
# MAGIC 1. If necessary, in the Databricks workspace open the Pipelines (DLT) UI (**Workflows** -> **Pipelines**) and open your DLT pipeline.
# MAGIC
# MAGIC 2. Select **Settings** to access your pipeline configuration. 
# MAGIC
# MAGIC 3. Review the pipeline configuration settings to ensure they are correctly configured according to the provided instructions.
# MAGIC
# MAGIC 4. Once you've confirmed that the pipeline configuration is set up correctly and the maintenance cluster has been removed, proceed to the next steps for validating and running the pipeline.
# MAGIC
# MAGIC 5. Click **Save** in the bottom right corner.
# MAGIC
# MAGIC **NOTE:** If you accidently enabled the new editor you can disable it by:
# MAGIC   - Going to your user icon at the top right.
# MAGIC   - Select **Settings**
# MAGIC   - Select **Developer**
# MAGIC   - Scroll to the bottom and turn off the following:
# MAGIC
# MAGIC   ![turn_off_editor](files/images/build-data-pipelines-with-delta-live-tables-2.1.3/turn_off_editor.png)

# COMMAND ----------

# MAGIC %md
# MAGIC Run the following cell to check if the pipeline has been set up correctly for the demonstration. This is a custom method specifically built for this course. Fix any specified issues if required.

# COMMAND ----------

DA.validate_pipeline_config(pipeline_language, num_notebooks=1)

# COMMAND ----------

# MAGIC %md
# MAGIC #### NOTE - Additional Notes on Pipeline Configuration
# MAGIC Here are a few notes regarding the pipeline settings above:
# MAGIC
# MAGIC - **Pipeline mode** - This specifies how the pipeline will be run. Choose the mode based on latency and cost requirements.
# MAGIC   - **`Triggered`** pipelines run once and then shut down until the next manual or scheduled update.
# MAGIC   - **`Continuous`** pipelines run continuously, ingesting new data as it arrives.
# MAGIC - **Notebook libraries** - Even though these documents are standard Databricks Notebooks, the SQL syntax is specialized to DLT table declarations. We will be exploring the syntax in the exercise that follows.
# MAGIC - **Storage location** - This optional field allows the user to specify a location to store logs, tables, and other information related to pipeline execution. If not specified, DLT will automatically generate a directory.
# MAGIC - **Catalog and Default schema** - These parameters are necessary to make data available outside the pipeline.
# MAGIC - **Configuration variables** - Key-value pairs that we add here will be passed to the notebooks used in the pipeline. We will look at the one variable we are using, **`source`**, in the next lesson. Please note that keys are case-sensitive.

# COMMAND ----------

# MAGIC %md
# MAGIC ### PART 1.3 -  Full Refresh, Validate, Start
# MAGIC 1. Click the dropdown immediately to the right of the **`Start`** button. There are two additional options (other than "Start").
# MAGIC
# MAGIC   - **Full refresh all** - All live tables are updated to reflect the current state of their input data sources. For all streaming tables, Delta Live Tables attempts to clear all data from each table and then load all data from the streaming source.
# MAGIC
# MAGIC       --**IMPORTANT NOTE**--  
# MAGIC       Because a full refresh clears all data from your current tables and uses the current state of data sources, it is possible for you to lose data if your data sources no longer contain the data you need. Be very careful when running full refreshes.
# MAGIC
# MAGIC  - **Validate** - Builds a directed acyclic graph (DAG) and runs a syntax check but does not actually perform any data updates.

# COMMAND ----------

# MAGIC %md
# MAGIC ### PART 1.4 - Validating Pipelines

# COMMAND ----------

# MAGIC %md
# MAGIC #### 4a. Validate the Pipeline
# MAGIC 1. Click the dropdown next to the **`Start`** button and click **`Validate`**. DLT builds a graph in the graph window and generates log entries at the bottom of the window. The pipeline should pass all checks and look similar to the image below.
# MAGIC
# MAGIC
# MAGIC ![ValidateOneNotebookDLTPipeline](files/images/build-data-pipelines-with-delta-live-tables-2.1.3/ValidateOneNotebookDLTPipeline.png)

# COMMAND ----------

# MAGIC %md
# MAGIC #### 4b. Introduce an Error
# MAGIC Let's introduce an error:
# MAGIC
# MAGIC 1. In the **`Pipeline details`** section (to the right of the DAG), click the **`Source code`** link. Our first source code notebook is opened in a new window. We will be talking about DLT source code in the next lesson. For now, continue through the next steps.
# MAGIC  
# MAGIC     - You may get a note that this notebook is associated with a pipeline. If you do, click the **"`x`"** to dismiss the dialog box.
# MAGIC
# MAGIC 2. Scroll to the first code cell in the notebook and remove the word **`CREATE`** from the SQL command. This will create a syntax error in this notebook.
# MAGIC
# MAGIC     - Note that we do not need to "Save" the notebook.
# MAGIC
# MAGIC 3. Return to the pipeline definition and run **`Validate`** again by clicking the dropdown next to **`Start`** and clicking **`Validate`**.
# MAGIC
# MAGIC 4. The validation fails. Click the log entry marked in red to get more details about the error. We see that there was a syntax error. We can also view the stack trace by clicking the "+" button. 
# MAGIC
# MAGIC 5. Fix the error we introduced, and re-run **`Validate`**. Confirm there are no errors.

# COMMAND ----------

# MAGIC %md
# MAGIC ### PART 1.5 - Run a Pipeline
# MAGIC
# MAGIC Now that we have the pipeline validated, let's run it.
# MAGIC
# MAGIC 1. We are running the pipeline in development mode. Development mode provides for more expeditious iterative development by reusing the cluster (as opposed to creating a new cluster for each run) and disabling retries so that you can readily identify and fix errors. Refer to the <a href="https://docs.databricks.com/aws/en/dlt/develop#overview-of-dlt-development-features" target="_blank">documentation</a> for more information on this feature.
# MAGIC
# MAGIC 2. Click **Start** to begin the pipeline run.
# MAGIC
# MAGIC 3. The pipeline will create the data in the **dbacademy** catalog within your unique schema.
# MAGIC
# MAGIC 4. While the DLT pipeline is running, let's examine Notebook **1 - Orders Pipeline** for the specified language and review the code.
# MAGIC   - [SQL Notebook 1 - Orders Pipeline]($./2A - SQL Pipelines/1 - Orders Pipeline)
# MAGIC   - [Python Notebook 1 - Orders Pipeline]($./2B - Python Pipelines/1 - Orders Pipeline)
# MAGIC
# MAGIC
# MAGIC **NOTE:** We are using Serverless clusters in this course for DLT pipelines. However, if you use a classic compute cluster with the DLT policy, the initial run will take several minutes while a cluster is provisioned. Subsequent runs will be appreciably quicker.

# COMMAND ----------

# MAGIC %md
# MAGIC ### PART 1.6 - Explore the DAG
# MAGIC
# MAGIC As the pipeline completes, the execution flow is graphed. Selecting the streaming tables or materialized views reviews the details.
# MAGIC
# MAGIC Complete the following:
# MAGIC
# MAGIC 1. Select **orders_silver**. Notice the results reported in the **Data Quality** section. 
# MAGIC
# MAGIC **NOTE:** With each triggered update, all newly arriving data will be processed through your pipeline. Metrics will always be reported for the current run.
# MAGIC
# MAGIC </br>
# MAGIC
# MAGIC ![RunOneNotebookDLTPipeline](files/images/build-data-pipelines-with-delta-live-tables-2.1.3/RunOneNotebookDLTPipeline.png)

# COMMAND ----------

# MAGIC %md
# MAGIC Leave your Databricks environment open. We will discuss how to implement Change Data Capture (CDC) in DLT and add another notebook to the pipeline.

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
# MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
# MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
# MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
# MAGIC <a href="https://help.databricks.com/">Support</a>
