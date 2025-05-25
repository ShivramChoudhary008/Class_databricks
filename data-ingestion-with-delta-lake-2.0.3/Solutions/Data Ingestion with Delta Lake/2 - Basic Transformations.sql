-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC
-- MAGIC # Basic Transformations
-- MAGIC This lesson will show you various ways to bring data into the Databricks Data Intelligence Platform. This data may be in different formats or may exist in various locations. We will talk about the intricacies of these situations. 
-- MAGIC
-- MAGIC ## Learning Objectives
-- MAGIC By the end of this lesson, you should be able to:
-- MAGIC - Use Spark SQL to configure options for extracting data from external sources
-- MAGIC - Use Spark SQL DDL to define schemas and tables
-- MAGIC - Differentiate between managed and external tables in Spark SQL 
-- MAGIC - Explain how managed and external tables impact storage location and management
-- MAGIC

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

-- MAGIC %run ./Includes/Classroom-Setup-2

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Cloning Delta Lake Tables
-- MAGIC Delta Lake has two options for efficiently copying Delta Lake tables.
-- MAGIC
-- MAGIC **`DEEP CLONE`** fully copies data and metadata from a source table to a target. This copy occurs incrementally, so executing this command again can sync changes from the source to the target location.

-- COMMAND ----------

CREATE OR REPLACE TABLE historical_sales_clone
DEEP CLONE historical_sales_bronze;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Because all the data files must be copied over, this can take quite a while for large datasets.
-- MAGIC
-- MAGIC If you wish to create a copy of a table quickly to test out applying changes without the risk of modifying the current table, **`SHALLOW CLONE`** can be a good option. Shallow clones just copy the Delta transaction logs, meaning that the data doesn't move.

-- COMMAND ----------

CREATE OR REPLACE TABLE historical_sales_shallow_clone
SHALLOW CLONE historical_sales_bronze;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC In either case, data modifications applied to the cloned version of the table will be tracked and stored separately from the source. Cloning is a great way to set up tables for testing SQL code while still in development.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Complete Overwrites
-- MAGIC
-- MAGIC We can use overwrites to atomically replace all of the data in a table. There are multiple benefits to overwriting tables instead of deleting and recreating tables:
-- MAGIC - Overwriting a table is much faster because it doesn’t need to list the directory recursively or delete any files.
-- MAGIC - The old version of the table still exists; can easily retrieve the old data using Time Travel.
-- MAGIC - It’s an atomic operation. Concurrent queries can still read the table while you are deleting the table.
-- MAGIC - Due to ACID transaction guarantees, if overwriting the table fails, the table will be in its previous state.
-- MAGIC
-- MAGIC Spark SQL provides two easy methods to accomplish complete overwrites.
-- MAGIC
-- MAGIC Some students may have noticed previous lesson on CTAS statements actually used CRAS statements (to avoid potential errors if a cell was run multiple times).
-- MAGIC
-- MAGIC **`CREATE OR REPLACE TABLE`** (CRAS) statements fully replace the contents of a table each time they execute.
-- MAGIC
-- MAGIC Note: This table was created using a CRAS statement in the `Classroom-Setup` script.

-- COMMAND ----------

CREATE OR REPLACE TABLE events AS
SELECT * 
FROM parquet.`/Volumes/dbacademy_ecommerce/v01/raw/events-historical/`;

DESCRIBE HISTORY events;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Reviewing the table history shows a previous version of this table was replaced. The version 0 CRAS statement was run in the previous cell.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## INSERT OVERWRITE
-- MAGIC
-- MAGIC **`INSERT OVERWRITE`** provides a nearly identical outcome as above: data in the target table will be replaced by data from the query. 
-- MAGIC
-- MAGIC **`INSERT OVERWRITE`**:
-- MAGIC
-- MAGIC - Can only overwrite an existing table, not create a new one like our CRAS statement
-- MAGIC - Can overwrite only with new records that match the current table schema -- and thus can be a "safer" technique for overwriting an existing table without disrupting downstream consumers
-- MAGIC - Can overwrite individual partitions

-- COMMAND ----------

INSERT OVERWRITE events
SELECT * 
FROM parquet.`/Volumes/dbacademy_ecommerce/v01/raw/events-historical/`;

DESCRIBE HISTORY events;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC The table history records the operation as a WRITE.
-- MAGIC
-- MAGIC A primary difference between using CRAS and using **`INSERT OVERWRITE`** has to do with how Delta Lake enforces schema on write.
-- MAGIC
-- MAGIC Whereas a CRAS statement will allow us to completely redefine the contents of our target table, **`INSERT OVERWRITE`** will fail if we try to change our schema (unless we provide optional settings). 
-- MAGIC
-- MAGIC Uncomment and run the cell below to **generate an expected error message**.

-- COMMAND ----------

-- INSERT OVERWRITE events
-- SELECT
--   *, 
--   current_timestamp() 
-- FROM parquet.`/Volumes/dbacademy_ecommerce/v01/raw/sales-historical/`

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Merge Updates
-- MAGIC
-- MAGIC You can upsert data from a source table, view, or DataFrame into a target Delta table using the **`MERGE`** SQL operation. Delta Lake supports inserts, updates and deletes in **`MERGE`**, and supports extended syntax beyond the SQL standards to facilitate advanced use cases.
-- MAGIC
-- MAGIC <strong><code>
-- MAGIC MERGE INTO target a<br/>
-- MAGIC USING source b<br/>
-- MAGIC ON {merge_condition}<br/>
-- MAGIC WHEN MATCHED THEN {matched_action}<br/>
-- MAGIC WHEN NOT MATCHED THEN {not_matched_action}<br/>
-- MAGIC </code></strong>
-- MAGIC
-- MAGIC We will use the **`MERGE`** operation to update historic users data with updated emails and new users.

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW users_update AS 
SELECT *, current_timestamp() AS updated 
FROM parquet.`/Volumes/dbacademy_ecommerce/v01/raw/users-30m/`;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC The main benefits of **`MERGE`**:
-- MAGIC * updates, inserts, and deletes are completed as a single transaction
-- MAGIC * multiple conditionals can be added in addition to matching fields
-- MAGIC * provides extensive options for implementing custom logic
-- MAGIC
-- MAGIC Below, we'll only update records if the current row has a **`NULL`** email and the new row does not. 
-- MAGIC
-- MAGIC All unmatched records from the new batch will be inserted.

-- COMMAND ----------

MERGE INTO users a
USING users_update b
ON a.user_id = b.user_id
WHEN MATCHED AND a.email IS NULL AND b.email IS NOT NULL THEN
  UPDATE SET email = b.email, updated = b.updated
WHEN NOT MATCHED THEN 
  INSERT (user_id, email, updated)
  VALUES (b.user_id, b.email, b.updated);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Note that we explicitly specify the behavior of this function for both the **`MATCHED`** and **`NOT MATCHED`** conditions; the example demonstrated here is just an example of logic that can be applied, rather than indicative of all **`MERGE`** behavior.
-- MAGIC
-- MAGIC ## Insert-Only Merge for Deduplication
-- MAGIC
-- MAGIC A common ETL use case is to collect logs or other ever-appending datasets into a Delta table through a series of append operations. 
-- MAGIC
-- MAGIC Many source systems can generate duplicate records. With merge, you can avoid inserting the duplicate records by performing an insert-only merge.
-- MAGIC
-- MAGIC This optimized command uses the same **`MERGE`** syntax but only provided a **`WHEN NOT MATCHED`** clause.
-- MAGIC
-- MAGIC Below, we use this to confirm that records with the same **`user_id`** and **`event_timestamp`** aren't already in the **`events`** table.

-- COMMAND ----------

MERGE INTO events a
USING events_update b
ON a.user_id = b.user_id AND a.event_timestamp = b.event_timestamp
WHEN NOT MATCHED AND b.traffic_source = 'email' THEN 
  INSERT *;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC  
-- MAGIC ## Filtering and Renaming Columns from Existing Tables
-- MAGIC
-- MAGIC Simple transformations like changing column names or omitting columns from target tables can be easily accomplished during table creation.
-- MAGIC
-- MAGIC The following statement creates a new table containing a subset of columns from the **`historical_sales_bronze`** table. 
-- MAGIC
-- MAGIC Here, we'll presume that we're intentionally leaving out information that potentially identifies the user or that provides itemized purchase details. We'll also rename our fields with the assumption that a downstream system has different naming conventions than our source data.

-- COMMAND ----------

CREATE OR REPLACE TABLE purchases AS
SELECT 
  order_id AS id, 
  transaction_timestamp, 
  purchase_revenue_in_usd AS price
FROM historical_sales_bronze;


SELECT * 
FROM purchases LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC  
-- MAGIC ## Declare Schema with Generated Columns
-- MAGIC
-- MAGIC Note in the cell above that the `transactions_timestamp` column appears to be some variant of a Unix timestamp, which may not be the most useful for our analysts to derive insights. This is a situation where generated columns would be beneficial.
-- MAGIC
-- MAGIC Generated columns are a special type of column whose values are automatically generated based on a user-specified function over other columns in the Delta table. We first divide the timestamp that is currently in microseconds by 1e6 (1 million). We then use `CAST` to cast the result to a [TIMESTAMP](https://docs.databricks.com/en/sql/language-manual/data-types/timestamp-type.html). Then, we `CAST` to [DATE](https://docs.databricks.com/en/sql/language-manual/data-types/date-type.html).
-- MAGIC
-- MAGIC The code below demonstrates creating a new table while:
-- MAGIC 1. Specifying column names and types
-- MAGIC 1. Adding a <a href="https://docs.databricks.com/en/delta/generated-columns.html" target="_blank">generated column</a> to calculate the date
-- MAGIC 1. Providing a descriptive column comment for the generated column
-- MAGIC
-- MAGIC Note that, at this point, the table contains no data. When we add data to the table that does not already contain a date value, the `date` column will be computed.

-- COMMAND ----------

CREATE OR REPLACE TABLE purchase_dates (
  id STRING, 
  transaction_timestamp STRING, 
  price STRING,
  date DATE GENERATED ALWAYS AS (
    cast(cast(transaction_timestamp/1e6 AS TIMESTAMP) AS DATE))
    COMMENT "generated based on `transaction_timestamp` column");


SELECT * 
FROM purchase_dates LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Let's add some data to the table.
-- MAGIC
-- MAGIC The cell below uses a `MERGE INTO` command. We will see this command in action in the next lesson. For now, just note that our generated column, `date`, has properly computed the date, based on the `transactions_timestamp` column.
-- MAGIC
-- MAGIC As with any Delta Lake source, the query automatically reads the most recent snapshot of the table for any query; you never need to run **`REFRESH TABLE`**.
-- MAGIC
-- MAGIC Lastly, note that if a field that would otherwise be generated is included in an insert to a table, this insert will fail if the value provided does not exactly match the value that would be derived by the logic used to define the generated column.
-- MAGIC
-- MAGIC **NOTE**: The cell below configures a setting to allow for generating columns when using a Delta Lake **`MERGE INTO`** statement: **`SET spark.databricks.delta.schema.autoMerge.enabled=true`. You can't use this in Serverless**
-- MAGIC
-- MAGIC Instead use `MERGE WITH SCHEMA EVOLUTION INTO` to evolve the schema in Databricks Runtime 15.2 and above: [Schema evolution syntax for merge
-- MAGIC ](https://docs.databricks.com/en/delta/update-schema.html#schema-evolution-syntax-for-merge)

-- COMMAND ----------

-- You can set this globally. However, this will not work with Serverless.
--SET spark.databricks.delta.schema.autoMerge.enabled=true; 

-- You can also use MERGE WITH SCHEMA EVOLUTION for the specific MERGE INTO statement
MERGE WITH SCHEMA EVOLUTION INTO purchase_dates a
USING purchases b
ON a.id = b.id
WHEN NOT MATCHED THEN
  INSERT *;


SELECT * 
FROM purchase_dates LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ## Add a Table Constraint
-- MAGIC
-- MAGIC The error message above refers to a **`CHECK constraint`**. Generated columns are a special implementation of check constraints.
-- MAGIC
-- MAGIC Because Delta Lake enforces schema on write, Databricks can support standard SQL constraint management clauses to ensure the quality and integrity of data added to a table.
-- MAGIC
-- MAGIC Databricks currently support two types of constraints:
-- MAGIC * <a href="https://docs.databricks.com/delta/delta-constraints.html#not-null-constraint" target="_blank">**`NOT NULL`** constraints</a>
-- MAGIC * <a href="https://docs.databricks.com/delta/delta-constraints.html#check-constraint" target="_blank">**`CHECK`** constraints</a>
-- MAGIC
-- MAGIC In both cases, you must ensure that no data violating the constraint is already in the table prior to defining the constraint. Once a constraint has been added to a table, data violating the constraint will result in write failure.
-- MAGIC
-- MAGIC Below, we'll add a **`CHECK`** constraint to the **`date`** column of our table. Note that **`CHECK`** constraints look like standard **`WHERE`** clauses you might use to filter a dataset.

-- COMMAND ----------

ALTER TABLE purchase_dates 
  ADD CONSTRAINT valid_date CHECK (date > '2020-01-01');

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Table constraints are shown in the **`TBLPROPERTIES`** field.

-- COMMAND ----------

DESCRIBE EXTENDED purchase_dates;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC The metadata fields added to the table provide useful information to understand when records were inserted and from where. This can be especially helpful if troubleshooting problems in the source data becomes necessary.
-- MAGIC
-- MAGIC All of the comments and properties for a given table can be reviewed using **`DESCRIBE TABLE EXTENDED`**.
-- MAGIC
-- MAGIC **NOTE**: Delta Lake automatically adds several table properties on table creation.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved. Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
