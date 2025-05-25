-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Pipeline Events Logs
-- MAGIC
-- MAGIC DLT uses the event logs to store much of the important information used to manage, report, and understand what's happening during pipeline execution.
-- MAGIC
-- MAGIC Below, we provide a number of useful queries to explore the event log and gain greater insight into your DLT pipelines.
-- MAGIC
-- MAGIC ##PLEASE READ! 
-- MAGIC Delta Live Tables writes the event log to a hidden Delta table in the default catalog and schema configured for the pipeline. While hidden, the table can still be queried by all sufficiently privileged users. By default, only the owner of the pipeline can query the event log table.
-- MAGIC
-- MAGIC - **DLT UPDATE**: The behavior to query the DLT event log has been modified from the legacy publishing mode which uses the `event_log()` table value function to using `event_log_{pipeline_id}`. 
-- MAGIC
-- MAGIC     The name for the hidden event log is formatted as event_log_{pipeline_id}, where the pipeline ID is the system-assigned UUID with dashed replaced by underscores.
-- MAGIC
-- MAGIC    For more information view the [Query the event log](https://docs.databricks.com/aws/en/delta-live-tables/observability#query-the-event-log) documentation.
-- MAGIC
-- MAGIC - [Delta Live Tables release 2025.04](https://docs.databricks.com/aws/en/release-notes/delta-live-tables/2025/04/)
-- MAGIC
-- MAGIC
-- MAGIC
-- MAGIC For more information view the [Monitor Delta Live Tables pipelines](https://docs.databricks.com/en/delta-live-tables/observability.html#monitor-delta-live-tables-pipelines) documentation.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## REQUIRED! - You must have a DLT pipeline created
-- MAGIC - If you have not completed the DLT pipeline from the previous steps (**1a, 1b, and 1c**), open the notebook **4 - Pipeline Results** and create the DLT pipeline for this course by running cells 5 & 7 using a classic compute cluster. Wait a few minutes for the DLT pipeline to complete execution.
-- MAGIC
-- MAGIC - If you have not completed demo **3 - Delta Live Tables Running Modes**, your numbers might not match, but you can still continue with the demonstration.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## REQUIRED! - Please Change to SQL Warehouse!
-- MAGIC The rest of the cells in this notebook must be run on a SQL warehouse.
-- MAGIC
-- MAGIC **TO DO:** Please select the compute drop down at the top right of the page and select the **shared_warehouse SQL 2X-Small** SQL warehouse prior to running the cells in this notebook. If you do not select **Shared Warehouse** you will not be able to complete this demo.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### A1. Query the DLT Event Log
-- MAGIC The Delta Live Tables event log contains all information related to a pipeline, including audit logs, data quality checks, pipeline progress, and data lineage. You can use the event log to track, understand, and monitor the state of your data pipelines.
-- MAGIC
-- MAGIC The event log is managed as a hidden Delta Lake table with some of the more important fields stored as nested JSON data.
-- MAGIC
-- MAGIC **REQUIRED:** 
-- MAGIC - Your DLT pipeline ID
-- MAGIC - Your lab schema name
-- MAGIC
-- MAGIC ###PLEASE READ! 
-- MAGIC - **DLT UPDATE REMINDER FROM ABOVE**: The behavior to query the DLT event log has been modified from the legacy publishing mode which uses the `event_log()` table value function to using `event_log_{pipeline_id}`. 
-- MAGIC
-- MAGIC     The name for the hidden event log is formatted as event_log_{pipeline_id}, where the pipeline ID is the system-assigned UUID with dashed replaced by underscores.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC Complete the following to get the DLT pipeline id.
-- MAGIC
-- MAGIC 1. Right click on the **Pipelines** tab in the left sidebar and select *Open in new tab*.
-- MAGIC
-- MAGIC 1. Locate the pipeline you created in the previous notebooks:
-- MAGIC    * Click on the pipeline.
-- MAGIC
-- MAGIC    * In the Pipeline Details tab on the right sidebar, find the `Pipeline Id`.
-- MAGIC
-- MAGIC    * Copy the Pipeline Id 
-- MAGIC
-- MAGIC    * In the cell below paste your DLT pipeline ID in the `DECLARE OR REPLACE VARIABLE` statement. The code below will replace the dashes ('-') with ('_') for you.
-- MAGIC ![GetPipelineID](files/images/build-data-pipelines-with-delta-live-tables-2.1.3/GetPipelineID.png)

-- COMMAND ----------

-- Replace with your DLT pipeline ID
DECLARE OR REPLACE VARIABLE my_pipeline_id DEFAULT "9a5091de-3cf4-4dde-bba3-23df87da486c"; 

-- Replaces dashes '-' with underscores '_' in your DLT pipeline ID
SET VAR my_pipeline_id = (SELECT replace(my_pipeline_id,'-','_'));

SELECT my_pipeline_id

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Complete the query below by replacing the following to query your pipeline event logs by creating a temporary view named **pipeline_event_log**:
-- MAGIC
-- MAGIC - Replace `<YOUR SCHEMA>` with your unique lab schema name
-- MAGIC
-- MAGIC - Replace `<YOUR PIPELINE ID>` with your pipeline ID with the `-` replaced with `_` from above.
-- MAGIC
-- MAGIC **EXAMPLE**
-- MAGIC ```
-- MAGIC CREATE OR REPLACE TEMPORARY VIEW pipeline_event_log AS 
-- MAGIC SELECT * 
-- MAGIC FROM dbacademy.labuser1234_5678.event_log_ac222e6d_3abe_4535_a7e0_725517031588;
-- MAGIC ```

-- COMMAND ----------

----------------------------------------------------------------------------------------
-- THIS CELL MUST BE RUN ON A SHARED SQL WAREHOUSE
-- PLEASE PASTE THE QUERY FROM ABOVE BELOW TO QUERY YOUR DLT PIPELINE EVENT LOG
----------------------------------------------------------------------------------------
-- PLEASE MODIFY THIS CELL WITH YOUR INFORMATION
----------------------------------------------------------------------------------------
CREATE OR REPLACE TEMPORARY VIEW pipeline_event_log AS 
SELECT * FROM dbacademy.<YOUR LAB SCHEMA>.event_log_<YOUR PIPELINE ID>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Now let's query the view to see the contents of the event log table.

-- COMMAND ----------

SELECT * 
FROM pipeline_event_log

-- COMMAND ----------

-- MAGIC %md
-- MAGIC The query in the previous cell uses the [**`event_log`** table-valued function](https://docs.databricks.com/en/sql/language-manual/functions/event_log.html). This is a built in function that allows you to query the event log for materialized views, streaming tables, and DLT pipelines.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### A2. Perform Audit Logging
-- MAGIC
-- MAGIC Events related to running pipelines and editing configurations are captured as **`user_action`**.
-- MAGIC
-- MAGIC Yours should be the only **`user_name`** for the pipeline you configured during this lesson.

-- COMMAND ----------

SELECT 
  timestamp, 
  details:user_action:action, 
  details:user_action:user_name
FROM pipeline_event_log
WHERE event_type = 'user_action'

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### A3. Get Latest Update ID
-- MAGIC
-- MAGIC In many cases, you may wish to get information about the latest update to your pipeline.
-- MAGIC
-- MAGIC We can easily capture the most recent update ID with a SQL query.

-- COMMAND ----------

-- Create an SQL STRING variable named latest_updated_id
DECLARE OR REPLACE VARIABLE latest_update_id STRING;

-- Populate the new SQL variable with the latest update ID
SET VARIABLE latest_update_id = (
    SELECT origin.update_id
    FROM pipeline_event_log
    WHERE event_type = 'create_update'
    ORDER BY timestamp DESC LIMIT 1
);

-- View the value of latest_update_id
SELECT latest_update_id

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### A4. Examine Lineage
-- MAGIC
-- MAGIC DLT provides built-in lineage information for how data flows through your table.
-- MAGIC
-- MAGIC While the query below only indicates the direct predecessors for each table, this information can easily be combined to trace data in any table back to the point it entered the lakehouse.

-- COMMAND ----------

SELECT 
  details:flow_definition.output_dataset, 
  details:flow_definition.input_datasets 
FROM pipeline_event_log
WHERE event_type = 'flow_definition' AND 
      origin.update_id = latest_update_id

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### A5. Examine Data Quality Metrics
-- MAGIC
-- MAGIC Finally, data quality metrics can be extremely useful for both long term and short term insights into your data.
-- MAGIC
-- MAGIC Below, we capture the metrics for each constraint throughout the entire lifetime of our table.

-- COMMAND ----------

SELECT 
  row_expectations.dataset as dataset,
  row_expectations.name as expectation,
  SUM(row_expectations.passed_records) as passing_records,
  SUM(row_expectations.failed_records) as failing_records
FROM
  (SELECT explode(
            from_json(details :flow_progress :data_quality :expectations,
                      "array<struct<name: string, dataset: string, passed_records: int, failed_records: int>>")
          ) row_expectations
   FROM pipeline_event_log
   WHERE event_type = 'flow_progress' AND 
         origin.update_id = latest_update_id
  )
GROUP BY row_expectations.dataset, row_expectations.name

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
-- MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
