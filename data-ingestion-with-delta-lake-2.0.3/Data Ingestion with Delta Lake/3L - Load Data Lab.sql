-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Load Data Lab
-- MAGIC
-- MAGIC In this lab, you will load data into new and existing Delta tables.
-- MAGIC
-- MAGIC ## Learning Objectives
-- MAGIC By the end of this lab, you should be able to:
-- MAGIC - Create an empty Delta table with a provided schema
-- MAGIC - Use `COPY INTO` and `CAST` to ingest data to an existing Delta table
-- MAGIC - Use a CTAS statement to create a Delta table from files

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## REQUIRED - SELECT CLASSIC COMPUTE
-- MAGIC
-- MAGIC Before executing cells in this notebook, please select your classic compute cluster in the lab. Be aware that **Serverless** is enabled by default.
-- MAGIC
-- MAGIC Follow these steps to select the classic compute cluster:
-- MAGIC
-- MAGIC 1. Navigate to the top-right of this notebook and click the drop-down menu to select your cluster. By default, the notebook will use **Serverless**.
-- MAGIC
-- MAGIC 1. If your cluster is available, select it and continue to the next cell. If the cluster is not shown:
-- MAGIC
-- MAGIC   - In the drop-down, select **More**.
-- MAGIC
-- MAGIC   - In the **Attach to an existing compute resource** pop-up, select the first drop-down. You will see a unique cluster name in that drop-down. Please select that cluster.
-- MAGIC
-- MAGIC **NOTE:** If your cluster has terminated, you might need to restart it in order to select it. To do this:
-- MAGIC
-- MAGIC 1. Right-click on **Compute** in the left navigation pane and select *Open in new tab*.
-- MAGIC
-- MAGIC 1. Find the triangle icon to the right of your compute cluster name and click it.
-- MAGIC
-- MAGIC 1. Wait a few minutes for the cluster to start.
-- MAGIC
-- MAGIC 1. Once the cluster is running, complete the steps above to select your cluster.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Classroom Setup
-- MAGIC
-- MAGIC Run the following cell to configure your working environment for this course. It will also set your default catalog to **dbacademy** and the schema to your specific schema name shown below using the `USE` statements.
-- MAGIC <br></br>
-- MAGIC
-- MAGIC
-- MAGIC ```
-- MAGIC USE CATALOG dbacademy;
-- MAGIC USE SCHEMA dbacademy.<your unique schema name>;
-- MAGIC ```
-- MAGIC
-- MAGIC **NOTE:** The `DA` object is only used in Databricks Academy courses and is not available outside of these courses. It will dynamically reference the information needed to run the course.

-- COMMAND ----------

-- MAGIC %run ./Includes/Classroom-Setup-3L

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Data Overview
-- MAGIC
-- MAGIC We will work with a sample of raw Kafka data written as JSON files. 
-- MAGIC
-- MAGIC Each file contains all records consumed during a 5-second interval, stored with the full Kafka schema as a multiple-record JSON file. 
-- MAGIC
-- MAGIC The schema for the table:
-- MAGIC
-- MAGIC | field  | type | description |
-- MAGIC | ------ | ---- | ----------- |
-- MAGIC | key    | BINARY | The **`user_id`** field is used as the key; this is a unique alphanumeric field that corresponds to session/cookie information |
-- MAGIC | offset | BIGINT | This is a unique value, monotonically increasing for each partition |
-- MAGIC | partition | INTEGER | Our current Kafka implementation uses only 2 partitions (0 and 1) |
-- MAGIC | timestamp | BIGINT    | This timestamp is recorded as milliseconds since epoch, and represents the time at which the producer appends a record to a partition |
-- MAGIC | topic | STRING | While the Kafka service hosts multiple topics, only those records from the **`clickstream`** topic are included here |
-- MAGIC | value | BINARY | This is the full data payload (to be discussed later), sent as JSON |

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ## Define Schema for Empty Delta Table
-- MAGIC Create an empty managed Delta table named **`events_bronze`** using the same schema.

-- COMMAND ----------

CREATE OR REPLACE TABLE events_bronze
(
  key BINARY,
  offset BIGINT,
  partition INT,
  timestamp BIGINT,
  topic STRING,
  value BINARY
)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Run the cell below to confirm the table was created correctly.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC assert spark.catalog.tableExists("events_bronze"), "The table does not exist"
-- MAGIC assert spark.table("events_bronze").count() == 0, "The table should have 0 records"
-- MAGIC for i in ['key','offset','partition','timestamp','topic','value']:
-- MAGIC   assert i in spark.table("events_bronze").columns, f"The column {i} is missing"
-- MAGIC assert str(spark.table("events_bronze").schema['key'].dataType) == 'BinaryType()', "Column key is wrong type"
-- MAGIC assert str(spark.table("events_bronze").schema['offset'].dataType) == 'LongType()', "Column offset is wrong type"
-- MAGIC assert str(spark.table("events_bronze").schema['partition'].dataType) == 'IntegerType()', "Column partition is wrong type"
-- MAGIC assert str(spark.table("events_bronze").schema['timestamp'].dataType) == 'LongType()', "Column timestamp is wrong type"
-- MAGIC assert str(spark.table("events_bronze").schema['topic'].dataType) == 'StringType()', "Column topic is wrong type"
-- MAGIC assert str(spark.table("events_bronze").schema['value'].dataType) == 'BinaryType()', "Column value is wrong type"

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Using `CAST` with JSON Data
-- MAGIC In the next cell, you will use COPY INTO to ingest data into the table.  
-- MAGIC   
-- MAGIC In order to force the JSON data to fit the schema you used when you created the table, you will need to use `CAST` keyword. The syntax for `CAST` is `CAST(column AS data_type)`.  To use `CAST` with `COPY INTO`, replace the path in the `COPY INTO` command you learned in the previous lesson, with a SELECT query (make sure you include the parentheses):
-- MAGIC   
-- MAGIC   <code>(SELECT
-- MAGIC   CAST(key AS BINARY) AS key,<br />
-- MAGIC   CAST(offset AS BIGINT) AS offset,<br />
-- MAGIC   CAST(partition AS INT) AS partition,<br />
-- MAGIC   CAST(timestamp AS BIGINT) AS timestamp,<br />
-- MAGIC   CAST(topic AS STRING) AS topic,<br />
-- MAGIC   CAST(value AS BINARY) AS value<br />
-- MAGIC FROM '/Volumes/dbacademy_ecommerce/v01/raw/events-kafka/')</code>
-- MAGIC   
-- MAGIC Note: Because the data files are in JSON format, you will not need to use the "delimiter" or "header" options.

-- COMMAND ----------

COPY INTO events_bronze 
FROM
  (SELECT
    CAST(key AS BINARY) AS key,
    CAST(offset AS BIGINT) AS offset,
    CAST(partition AS INT) AS partition,
    CAST(timestamp AS BIGINT) AS timestamp,
    CAST(topic AS STRING) AS topic,
    CAST(value AS BINARY) AS value
  FROM '/Volumes/dbacademy_ecommerce/v01/raw/events-kafka/')
FILEFORMAT = JSON;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Manually review the table contents to ensure data was written as expected.

-- COMMAND ----------

SELECT * 
FROM events_bronze LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Run the cell below to confirm the data has been loaded correctly.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC import pyspark.sql.functions as F
-- MAGIC
-- MAGIC assert spark.catalog.tableExists("events_bronze"), "The table does not exist"
-- MAGIC assert spark.table("events_bronze").count() == 2252, "The table should have 2252 records"
-- MAGIC
-- MAGIC first_five = [r["timestamp"] for r in spark.table("events_bronze").orderBy(F.col("timestamp").asc()).limit(5).collect()]
-- MAGIC assert first_five == [1593879303631, 1593879304224, 1593879305465, 1593879305482, 1593879305746], "First 5 values are not correct"
-- MAGIC
-- MAGIC last_five = [r["timestamp"] for r in spark.table("events_bronze").orderBy(F.col("timestamp").desc()).limit(5).collect()]
-- MAGIC assert last_five == [1593881096290, 1593881095799, 1593881093452, 1593881093394, 1593881092076], "Last 5 values are not correct"

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Create a Delta Table From Query Results
-- MAGIC
-- MAGIC In addition to new events data, let's also load a small lookup table that provides product details that we'll use later in the course.
-- MAGIC Use a CTAS statement to create a managed Delta table named **`item_lookup`** that extracts data from the parquet directory provided below. 
-- MAGIC
-- MAGIC Parquet files directory: `/Volumes/dbacademy_ecommerce/v01/raw/item-lookup/`

-- COMMAND ----------

CREATE OR REPLACE TABLE item_lookup AS 
SELECT * 
FROM parquet.`/Volumes/dbacademy_ecommerce/v01/raw/item-lookup/`;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Run the cell below to confirm the lookup table has been loaded correctly.

-- COMMAND ----------

SELECT * 
FROM item_lookup 
LIMIT 10;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC
-- MAGIC assert spark.catalog.tableExists("item_lookup"), "The table does not exist"
-- MAGIC
-- MAGIC actual_values = [r["item_id"] for r in spark.table("item_lookup").collect()]
-- MAGIC expected_values = ['M_PREM_Q','M_STAN_F','M_PREM_F','M_PREM_T','M_PREM_K','P_DOWN_S','M_STAN_Q','M_STAN_K','M_STAN_T','P_FOAM_S','P_FOAM_K','P_DOWN_K']
-- MAGIC assert actual_values == expected_values, "Does not contain the 12 expected item IDs"

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved. Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
