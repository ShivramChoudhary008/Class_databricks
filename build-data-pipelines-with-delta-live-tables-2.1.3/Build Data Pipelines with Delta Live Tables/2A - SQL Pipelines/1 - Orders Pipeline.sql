-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Fundamentals of DLT SQL Syntax
-- MAGIC
-- MAGIC This notebook demonstrates using Delta Live Tables (DLT) to process raw data from JSON files landing in cloud object storage, through a series of tables, to drive analytic workloads in the lakehouse. Here we demonstrate a medallion architecture, where data is incrementally transformed and enriched as it flows through a pipeline. This notebook focuses on the SQL syntax of DLT rather than this architecture, but a brief overview of the design:
-- MAGIC
-- MAGIC * The bronze table contains raw records loaded from JSON enriched with data describing how records were ingested
-- MAGIC * The silver table validates and enriches the fields of interest
-- MAGIC * The gold table contains aggregate data to drive business insights and dashboarding
-- MAGIC
-- MAGIC ## Learning Objectives
-- MAGIC
-- MAGIC By the end of this notebook, students should feel comfortable:
-- MAGIC * Declaring Delta Live Tables
-- MAGIC * Ingesting data with Auto Loader
-- MAGIC * Using parameters in DLT Pipelines
-- MAGIC * Enforcing data quality with constraints
-- MAGIC * Adding comments to tables
-- MAGIC * Describing differences in syntax and execution of Materialized View and streaming tables

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## A. About DLT Library Notebooks
-- MAGIC DLT syntax is not intended for interactive execution in a notebook, meaning you will not be able execute any cell below outside of a DLT pipeline. This notebook will need to be scheduled as part of a DLT pipeline for proper execution. 
-- MAGIC
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## B. Parameterization
-- MAGIC During the configuration of the DLT pipeline, a number of options were specified. One of these was a key-value pair added to the **Configuration** field with a key of **`source`**.
-- MAGIC
-- MAGIC Configurations in DLT pipelines are similar to parameters in Databricks Jobs or widgets in Databricks notebooks.
-- MAGIC
-- MAGIC Throughout these lessons, we'll be using the **`${source}`** parameter to perform string substitution of the file path set during configuration into our SQL queries. The path points to a Databricks volume.
-- MAGIC - **Example path:** /Volumes/dbacademy/ops/\<your-unique-user-name>/stream-source

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## C. Tables as Query Results
-- MAGIC
-- MAGIC Delta Live Tables adapts standard SQL queries to combine DDL (data definition language) and DML (data manipulation language) into a unified declarative syntax.
-- MAGIC
-- MAGIC There are two distinct types of persistent tables that can be created with DLT. For both kinds of tables, DLT takes the approach of a slightly modified CTAS (create table as select) statement. Engineers just need to worry about writing queries to transform their data, and DLT handles the rest.
-- MAGIC
-- MAGIC - #### Materialized View  
-- MAGIC Materialized views are refreshed according to the update schedule of the pipeline in which they’re contained. Materialized views are powerful because they can handle any changes in the input. Each time the pipeline updates, query results are recalculated to reflect changes in upstream datasets that might have occurred because of compliance, corrections, aggregations, or general CDC.
-- MAGIC   <br></br>
-- MAGIC   **Syntax**
-- MAGIC   ```
-- MAGIC   CREATE OR REFRESH [MATERIALIZED VIEW] table_name
-- MAGIC   AS select_statement
-- MAGIC   ```
-- MAGIC
-- MAGIC   *Existing users of DLT will notice that the names have evolved. The previous syntax for a materialized view:*
-- MAGIC   ```
-- MAGIC   CREATE OR REFRESH [LIVE TABLE] table_name
-- MAGIC   AS select_statement
-- MAGIC   ```
-- MAGIC - #### Streaming Tables  
-- MAGIC Streaming tables allow you to process a growing dataset, handling each row only once. Because most datasets grow continuously over time, streaming tables are good for most ingestion workloads. Streaming tables are optimal for pipelines that require data freshness and low latency.
-- MAGIC   <br></br>
-- MAGIC   **Syntax**
-- MAGIC   ```
-- MAGIC   CREATE OR REFRESH [STREAMING TABLE] table_name
-- MAGIC   AS select_statement
-- MAGIC   ```
-- MAGIC
-- MAGIC   *Existing users of DLT will notice that the names have evolved. The previous syntax for a streaming table:*
-- MAGIC   ```
-- MAGIC   CREATE OR REFRESH [STREAMING LIVE TABLE] table_name
-- MAGIC   AS select_statement
-- MAGIC   ```
-- MAGIC   
-- MAGIC <br></br>
-- MAGIC Note that both of these objects are persisted as tables stored with the Delta Lake protocol (providing ACID transactions, versioning, and many other benefits). We'll talk more about the differences between materialized views and streaming tables later in the notebook.
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## D. Streaming Ingestion with Auto Loader
-- MAGIC Databricks has developed the [Auto Loader](https://docs.databricks.com/ingestion/auto-loader/index.html) functionality to provide optimized execution for incrementally loading data from cloud object storage into Delta Lake. Using Auto Loader with DLT is simple: just configure a source data directory, provide a few configuration settings, and write a query against your source data. Auto Loader will automatically detect new data files as they land in the source cloud object storage location, incrementally processing new records without the need to perform expensive scans and recomputing results for infinitely growing datasets.
-- MAGIC
-- MAGIC The **`cloud_files()`** method enables Auto Loader to be used natively with SQL. This method takes the following positional parameters:
-- MAGIC * The source location, which should be cloud-based object storage
-- MAGIC * The source data format, which is JSON in this case
-- MAGIC * An arbitrarily sized comma-separated list of optional reader options. In this case, we set **`cloudFiles.inferColumnTypes`** to **`true`**
-- MAGIC
-- MAGIC In the query below, in addition to the fields contained in the source, Spark SQL functions for the **`current_timestamp()`** and **`_metadata.file_name`** as used to capture information about when the record was ingested and the specific file source for each record.

-- COMMAND ----------

CREATE OR REFRESH STREAMING TABLE orders_bronze
AS 
SELECT 
  *,
  current_timestamp() AS processing_time,
  _metadata.file_name AS source_file
FROM cloud_files("${source}/orders", "json", map("cloudFiles.inferColumnTypes", "true"))

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## E. Validating, Enriching, and Transforming Data
-- MAGIC
-- MAGIC DLT allows users to easily declare tables from results of any standard Spark transformations. DLT leverages features used elsewhere in Spark SQL for documenting datasets, while adding new functionality for data quality checks.
-- MAGIC
-- MAGIC Let's break down the syntax of the query below.
-- MAGIC
-- MAGIC #### The Select Statement
-- MAGIC
-- MAGIC The select statement contains the core logic of your query. In this example, we:
-- MAGIC * Cast the field **`order_timestamp`** to the timestamp type
-- MAGIC * Select all of the remaining fields (except a list of 3 we're not interested in, including the original **`order_timestamp`**)
-- MAGIC
-- MAGIC Note that the **`FROM`** clause has two constructs that you may not be familiar with:
-- MAGIC * The **`LIVE`** keyword is used in place of the schema name to refer to the target schema configured for the current DLT pipeline
-- MAGIC * The **`STREAM`** method allows users to declare a streaming data source for SQL queries
-- MAGIC
-- MAGIC Note that if no target schema is declared during pipeline configuration, your tables won't be published (that is, they won't be registered to the metastore and made available for queries elsewhere). The target schema can be easily changed when moving between different execution environments, meaning the same code can easily be deployed against regional workloads or promoted from a dev to prod environment without needing to hard-code schema names.
-- MAGIC
-- MAGIC #### Data Quality Constraints
-- MAGIC
-- MAGIC DLT uses simple boolean statements to allow <a href="https://docs.databricks.com/delta-live-tables/expectations.html#delta-live-tables-data-quality-constraints&language-sql" target="_blank">quality enforcement checks</a> on data. In the statement below, we:
-- MAGIC * Declare a constraint named **`valid_date`**
-- MAGIC * Define the conditional check that the field **`order_timestamp`** must contain a value greater than January 1, 2021
-- MAGIC * Instruct DLT to fail the current transaction if any records violate the constraint
-- MAGIC
-- MAGIC Each constraint can have multiple conditions, and multiple constraints can be set for a single table. In addition to failing the update, constraint violation can also automatically drop records or just record the number of violations while still processing these invalid records.
-- MAGIC
-- MAGIC #### Table Comments
-- MAGIC
-- MAGIC Table comments are standard in SQL, and can be used to provide useful information to users throughout your organization. In this example, we write a short human-readable description of the table that describes how data is being ingested and enforced (which could also be gleaned from reviewing other table metadata).
-- MAGIC
-- MAGIC #### Table Properties
-- MAGIC
-- MAGIC The **`TBLPROPERTIES`** field can be used to pass any number of key/value pairs for custom tagging of data. Here, we set the value **`silver`** for the key **`quality`**.
-- MAGIC
-- MAGIC Note that while this field allows for custom tags to be arbitrarily set, it is also used for configuring number of settings that control how a table will perform. While reviewing table details, you may also encounter a number of settings that are turned on by default any time a table is created.

-- COMMAND ----------

CREATE OR REFRESH STREAMING TABLE orders_silver
  (CONSTRAINT valid_date EXPECT (order_timestamp > "2021-01-01") ON VIOLATION FAIL UPDATE)
COMMENT "Append only orders with valid timestamps"
TBLPROPERTIES ("quality" = "silver")
AS 
SELECT 
  timestamp(order_timestamp) AS order_timestamp, 
  * EXCEPT (order_timestamp, _rescued_data)
FROM STREAM(LIVE.orders_bronze)                    -- References the orders_bronze streaming table

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## F. Materialized View vs. Streaming Tables
-- MAGIC
-- MAGIC The two queries we've reviewed so far have both created streaming tables. Below, we see a simple query that returns a live table (or materialized view) of some aggregated data.
-- MAGIC
-- MAGIC Spark has historically differentiated between batch queries and streaming queries. Live tables and streaming tables have similar differences.
-- MAGIC
-- MAGIC Note the only syntactic differences between streaming tables and live tables are the lack of the **`STREAMING`** keyword in the create clause and not wrapping the source table in the **`STREAM()`** method.
-- MAGIC
-- MAGIC Below are some of the differences between these types of tables.
-- MAGIC
-- MAGIC #### Materialized Views (also known as Live Tables)
-- MAGIC * Always "correct", meaning their contents will match their definition after any update.
-- MAGIC * Return same results as if table had just been defined for first time on all data.
-- MAGIC * Should not be modified by operations external to the DLT Pipeline (you'll either get undefined answers or your change will just be undone).
-- MAGIC
-- MAGIC #### Streaming Tables
-- MAGIC * Only supports reading from "append-only" streaming sources.
-- MAGIC * Only reads each input batch once, no matter what (even if joined dimensions change, or if the query definition changes, etc).
-- MAGIC * Can perform operations on the table outside the managed DLT Pipeline (append data, perform GDPR, etc).

-- COMMAND ----------

CREATE OR REFRESH MATERIALIZED VIEW orders_by_date      -- PREVIOUS SYNTAX: CREATE OR REFRESH LIVE TABLE...
AS 
SELECT 
  date(order_timestamp) AS order_date, 
  count(*) AS total_daily_orders
FROM LIVE.orders_silver                                 -- References the full orders_silver streaming table
GROUP BY date(order_timestamp)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Summary
-- MAGIC
-- MAGIC By reviewing this notebook, you should now feel comfortable:
-- MAGIC * Declaring Delta Live Tables
-- MAGIC * Ingesting data with Auto Loader
-- MAGIC * Using parameters in DLT Pipelines
-- MAGIC * Enforcing data quality with constraints
-- MAGIC * Adding comments to tables
-- MAGIC * Describing differences in syntax and execution of Materialized View and streaming tables
-- MAGIC
-- MAGIC In the next notebook, we'll continue learning about these syntactic constructs while adding a few new concepts.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
-- MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
