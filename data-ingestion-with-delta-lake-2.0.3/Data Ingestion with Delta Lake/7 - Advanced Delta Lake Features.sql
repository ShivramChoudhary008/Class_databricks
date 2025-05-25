-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Advanced Delta Lake Features
-- MAGIC
-- MAGIC Now that you feel comfortable performing basic data tasks with Delta Lake, we can discuss a few advanced features unique to Delta Lake. We are going to talk about Liquid Clustering, Optimization, and Versioning in Delta Lake.
-- MAGIC
-- MAGIC Note that while some of the keywords used here aren't part of standard ANSI SQL, all Delta Lake operations can be run on Databricks using SQL
-- MAGIC
-- MAGIC ## Learning Objectives
-- MAGIC By the end of this lesson, you should be able to:
-- MAGIC * Use **`CLUSTER BY`** for liquid clustering
-- MAGIC * Use **`OPTIMIZE`** to manually trigger liquid clustering
-- MAGIC * Review a history of table transactions
-- MAGIC * Query and roll back to previous table version
-- MAGIC * Describe how to enable **`Predictive Optimization`**
-- MAGIC
-- MAGIC **Resources**
-- MAGIC * <a href="https://docs.databricks.com/spark/latest/spark-sql/language-manual/delta-optimize.html" target="_blank">Delta Optimize - Databricks Docs</a>
-- MAGIC * <a href="https://docs.databricks.com/spark/latest/spark-sql/language-manual/delta-vacuum.html" target="_blank">Delta Vacuum - Databricks Docs</a>

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

-- MAGIC %run ./Includes/Classroom-Setup-7

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Liquid Clustering
-- MAGIC Delta Lake liquid clustering replaces table partitioning and ZORDER to simplify data layout decisions and optimize query performance. Liquid clustering provides flexibility to redefine clustering keys without rewriting existing data, allowing data layout to evolve alongside analytic needs over time.
-- MAGIC
-- MAGIC Databricks recommends using liquid clustering for all new Delta tables.
-- MAGIC
-- MAGIC We enable liquid clustering on a table by using **`CLUSTER BY`**.
-- MAGIC
-- MAGIC Run **`DESCRIBE events`** and note the names of the columns.

-- COMMAND ----------

DESCRIBE events;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC There are [many reasons](https://docs.databricks.com/en/delta/clustering.html#what-is-liquid-clustering-used-for) to use liquid clustering on a table. We know the **`events`** table will be growing quickly and will require maintenance and tuning, so we are going to enable liquid clustering for this table. Now, we could have enable liquid clustering at the time the table was created by adding **`CLUSTER BY`** to the **`CREATE TABLE`** statement, like this:

-- COMMAND ----------

CREATE OR REPLACE TABLE events_liquid 
CLUSTER BY (user_id) AS 
SELECT * 
FROM events;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC However, we can also add liquid clustering to an existing table using **`ALTER TABLE`**.

-- COMMAND ----------

ALTER TABLE events
CLUSTER BY (user_id);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC When we run **`DESCRIBE events`**, we see the column(s) on which we are currently clustering under **`Clustering Information`**.

-- COMMAND ----------

DESCRIBE events;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Choosing Clustering Keys
-- MAGIC Databricks recommends choosing clustering keys based on commonly used query filters. Clustering keys can be defined in any order. 
-- MAGIC
-- MAGIC In the **`CLUSTER BY`** above, we chose **`user_id`** as the clustering key, but we may also want to add **`device`**. Note that we can change clustering keys, as needed, by altering the table in the future.
-- MAGIC
-- MAGIC With liquid clustering, we no longer have to worry about how we have data partitioned or deal with the complexities of using zorder. We get the benefits of both without the struggle.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Triggering Liquid Clustering
-- MAGIC Liquid clustering is incremental, meaning that data is only rewritten as necessary to accommodate data that needs to be clustered. Data files with clustering keys that do not match data to be clustered are not rewritten.
-- MAGIC
-- MAGIC For best performance, Databricks recommends scheduling regular **`OPTIMIZE`** jobs to cluster data. For tables experiencing many updates or inserts, Databricks recommends scheduling an **`OPTIMIZE`** job every one or two hours. Because liquid clustering is incremental, most **`OPTIMIZE`** jobs for clustered tables run quickly.

-- COMMAND ----------

OPTIMIZE events;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Creating a Delta Table with History
-- MAGIC
-- MAGIC In the next cell, we create a table and run a handful of commands that make updates to the table. As you're waiting for this query to run, see if you can identify the total number of transactions being executed.

-- COMMAND ----------

CREATE TABLE students 
  (id INT, name STRING, value DOUBLE);
  
INSERT INTO students VALUES (1, "Yve", 1.0);
INSERT INTO students VALUES (2, "Omar", 2.5);
INSERT INTO students VALUES (3, "Elia", 3.3);

INSERT INTO students
VALUES 
  (4, "Ted", 4.7),
  (5, "Tiffany", 5.5),
  (6, "Vini", 6.3);
  
UPDATE students 
SET value = value + 1
WHERE name LIKE "T%";

DELETE FROM students 
WHERE value > 6;

CREATE OR REPLACE TEMP VIEW updates(id, name, value, type) AS VALUES
  (2, "Omar", 15.2, "update"),
  (3, "", null, "delete"),
  (7, "Blue", 7.7, "insert"),
  (11, "Diya", 8.8, "update");
  
MERGE INTO students b
USING updates u
ON b.id=u.id
WHEN MATCHED AND u.type = "update"
  THEN UPDATE SET *
WHEN MATCHED AND u.type = "delete"
  THEN DELETE
WHEN NOT MATCHED AND u.type = "insert"
  THEN INSERT *;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## The Delta Log
-- MAGIC Each change to a table results in a new entry being written to the Delta Lake transaction log. 
-- MAGIC
-- MAGIC The command, `DESCRIBE HISTORY` allows us to see this log

-- COMMAND ----------

DESCRIBE HISTORY students;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Deletion Vectors
-- MAGIC Note that the log includes an **OPTIMIZE** operation, yet we never called **`OPTIMIZE`** on the **`students`** table. If you open the `operationParameters` for the **`OPTIMIZE`** operation, you will see that `auto: true`. This is because Deletion Vectors triggered auto-compaction. When we delete rows from a table, Deletion Vectors mark those rows for deletion but do not re-write the underlying Parquet files. This helps reduce the so-called small file problem, where a table is made up of a large number of small Parquet files. However, Deletion Vectors will trigger auto-compaction, and the underlying files are re-written.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC
-- MAGIC ## Delta Lake Time Travel
-- MAGIC
-- MAGIC Delta Lake gives us the opportunity to query tables at any point in the transaction log. These time travel queries can be performed by specifying either the version number or the timestamp.
-- MAGIC
-- MAGIC **NOTE**: In most cases, you'll use a timestamp to recreate data at a time of interest. For our demo we'll use version.

-- COMMAND ----------

SELECT * 
FROM students VERSION AS OF 3;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC
-- MAGIC What's important to note about time travel is that we're not recreating a previous state of the table by undoing transactions against our current version; rather, we're just querying all those data files that were indicated as valid as of the specified version.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Rollback Versions
-- MAGIC
-- MAGIC Suppose you're typing up a query to manually delete some records from a table and you accidentally delete all records.

-- COMMAND ----------

DELETE FROM students;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC From the output above, we can see that 4 rows were removed.
-- MAGIC
-- MAGIC Let's confirm this below.

-- COMMAND ----------

SELECT * 
FROM students;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Deleting all the records in your table is probably not a desired outcome. Luckily, we can simply rollback this commit.

-- COMMAND ----------

RESTORE TABLE students TO VERSION AS OF 8;

-- COMMAND ----------

-- Confirm table has been 'Restored'
SELECT * 
FROM students;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Note that a **`RESTORE`** <a href="https://docs.databricks.com/spark/latest/spark-sql/language-manual/delta-restore.html" target="_blank">command</a> is recorded as a transaction; you won't be able to completely hide the fact that you accidentally deleted all the records in the table, but you will be able to undo the operation and bring your table back to a desired state.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Predictive Optimization
-- MAGIC Predictive Optimization is a feature that can be enabled that takes away the necessity for manually performing **`OPTIMIZE`** and **`VACUUM`**.
-- MAGIC
-- MAGIC With predictive optimization enabled, Databricks automatically identifies tables that would benefit from maintenance operations and runs them for the user. Maintenance operations are only run as necessary, eliminating both unnecessary runs for maintenance operations and the burden associated with tracking and troubleshooting performance.
-- MAGIC
-- MAGIC You must enable predictive optimization at the account level. The feature is inherited by all lower-level objects, but it can be enabled/disabled on those objects, as needed.
-- MAGIC
-- MAGIC #### View if Predictive Optimization is Enabled:
-- MAGIC To check whether Predictive Optimization is enabled on a catalog, schema or table: 
-- MAGIC ```
-- MAGIC DESCRIBE (CATALOG | SCHEMA | TABLE) EXTENDED name
-- MAGIC ```
-- MAGIC  
-- MAGIC
-- MAGIC **View Catalog**
-- MAGIC
-- MAGIC `DESCRIBE CATALOG EXTENDED dbacademy;`
-- MAGIC
-- MAGIC ![Catalog PO Check](./Includes/images/po_enabled_catalog.png)
-- MAGIC
-- MAGIC **View Table**
-- MAGIC
-- MAGIC `DESCRIBE TABLE EXTENDED events;`
-- MAGIC
-- MAGIC ![Table PO Check](./Includes/images/po_enabled_table.png)
-- MAGIC
-- MAGIC <br></br>
-- MAGIC
-- MAGIC #### Enabling Predictive Optimization:
-- MAGIC - To enable Predictive Optimization view the [Enable predictive optimization](https://docs.databricks.com/en/optimizations/predictive-optimization.html) documentation.
-- MAGIC ```
-- MAGIC ALTER CATALOG [catalog_name] {ENABLE | DISABLE} PREDICTIVE OPTIMIZATION;
-- MAGIC ALTER {SCHEMA | DATABASE} [schema_name] {ENABLE | DISABLE} PREDICTIVE OPTIMIZATION;
-- MAGIC ALTER TABLE [table_name] {ENABLE | DISABLE} PREDICTIVE OPTIMIZATION;
-- MAGIC ```
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Run the `DESCRIBE CATALOG EXTENDED` statement below. Is Predictive Optimization turned on at the catalog level?

-- COMMAND ----------

DESCRIBE CATALOG EXTENDED dbacademy;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Run the `DESCRIBE TABLE EXTENDED` statement below. Is Predictive Optimization turned on for the **events** table?

-- COMMAND ----------

DESCRIBE TABLE EXTENDED events;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved. Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
