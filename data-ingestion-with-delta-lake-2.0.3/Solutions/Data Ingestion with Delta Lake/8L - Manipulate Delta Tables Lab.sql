-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Manipulate Delta Tables Lab
-- MAGIC
-- MAGIC This notebook provides a hands-on review of some of the more esoteric features Delta Lake brings to the data lakehouse.
-- MAGIC
-- MAGIC ## Learning Objectives
-- MAGIC By the end of this lab, you should be able to:
-- MAGIC - Review table history
-- MAGIC - Query previous table versions and rollback a table to a specific version

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

-- DBTITLE 1,cvf
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

-- MAGIC %run ./Includes/Classroom-Setup-8L

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Create History of Bean Collection
-- MAGIC
-- MAGIC The cell below includes various table operations, resulting in the following schema for the **`beans`** table:
-- MAGIC
-- MAGIC | Field Name | Field type |
-- MAGIC | --- | --- |
-- MAGIC | name | STRING |
-- MAGIC | color | STRING |
-- MAGIC | grams | FLOAT |
-- MAGIC | delicious | BOOLEAN |

-- COMMAND ----------

CREATE OR REPLACE TABLE beans 
(name STRING, color STRING, grams FLOAT, delicious BOOLEAN);

INSERT INTO beans VALUES
("black", "black", 500, true),
("lentils", "brown", 1000, true),
("jelly", "rainbow", 42.5, false);

INSERT INTO beans VALUES
('pinto', 'brown', 1.5, true),
('green', 'green', 178.3, true),
('beanbag chair', 'white', 40000, false);

UPDATE beans
SET delicious = true
WHERE name = "jelly";

UPDATE beans
SET grams = 1500
WHERE name = 'pinto';

DELETE FROM beans
WHERE delicious = false;

CREATE OR REPLACE TEMP VIEW new_beans(name, color, grams, delicious) AS VALUES
('black', 'black', 60.5, true),
('lentils', 'green', 500, true),
('kidney', 'red', 387.2, true),
('castor', 'brown', 25, false);

MERGE INTO beans a
USING new_beans b
ON a.name=b.name AND a.color = b.color
WHEN MATCHED THEN
  UPDATE SET grams = a.grams + b.grams
WHEN NOT MATCHED AND b.delicious = true THEN
  INSERT *;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Review the Table History
-- MAGIC
-- MAGIC Delta Lake's transaction log stores information about each transaction that modifies a table's contents or settings.
-- MAGIC
-- MAGIC Review the history of the **`beans`** table below.

-- COMMAND ----------

DESCRIBE HISTORY beans

-- COMMAND ----------

-- MAGIC %md
-- MAGIC If all the previous operations were completed as described you should see 9 versions of the table (**NOTE**: Delta Lake versioning starts with 0, so the max version number will be 8).
-- MAGIC
-- MAGIC The operations should be as follows:
-- MAGIC
-- MAGIC | version | operation |
-- MAGIC | --- | --- |
-- MAGIC | 0 | CREATE TABLE |
-- MAGIC | 1 | WRITE |
-- MAGIC | 2 | WRITE |
-- MAGIC | 3 | UPDATE |
-- MAGIC | 4 | OPTIMIZE |
-- MAGIC | 5 | UPDATE |
-- MAGIC | 6 | DELETE |
-- MAGIC | 7 | OPTIMIZE |
-- MAGIC | 8 | MERGE |
-- MAGIC
-- MAGIC The **`operationsParameters`** column will let you review predicates used for updates, deletes, and merges. The **`operationMetrics`** column indicates how many rows and files are added in each operation.
-- MAGIC
-- MAGIC Spend some time reviewing the Delta Lake history to understand which table version matches with a given transaction.
-- MAGIC
-- MAGIC **NOTE**: The **`version`** column designates the state of a table once a given transaction completes. The **`readVersion`** column indicates the version of the table an operation executed against. In this simple demo (with no concurrent transactions), this relationship should always increment by 1.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Query a Specific Version
-- MAGIC
-- MAGIC After reviewing the table history, you decide you want to view the state of your table after your very first data was inserted.
-- MAGIC
-- MAGIC Run the query below to see this.

-- COMMAND ----------

SELECT * 
FROM beans VERSION AS OF 1;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC And now review the current state of your data.

-- COMMAND ----------

SELECT * 
FROM beans;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC You want to review the weights of your beans before you deleted any records.
-- MAGIC
-- MAGIC Fill in the statement below to register a temporary view of the version just before data was deleted, then run the following cell to query the view.

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW pre_delete_vw AS
SELECT * 
FROM beans VERSION AS OF 5;

-- COMMAND ----------

SELECT * 
FROM pre_delete_vw;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Run the cell below to check that you have captured the correct version.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC assert spark.catalog.tableExists("pre_delete_vw"), "Make sure you have registered the temporary view with the provided name `pre_delete_vw`"
-- MAGIC assert spark.table("pre_delete_vw").count() == 6, "Make sure you're querying a version of the table with 6 records"
-- MAGIC assert spark.table("pre_delete_vw").selectExpr("int(sum(grams))").first()[0] == 43220, "Make sure you query the version of the table after updates were applied"

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Restore a Previous Version
-- MAGIC
-- MAGIC Apparently there was a misunderstanding; the beans your friend gave you that you merged into your collection were not intended for you to keep.
-- MAGIC
-- MAGIC Revert your table to the version before this **`MERGE`** statement completed.

-- COMMAND ----------

RESTORE TABLE beans TO VERSION AS OF 7;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Review the history of your table. Make note of the fact that restoring to a previous version adds another table version.

-- COMMAND ----------

DESCRIBE HISTORY beans;

-- COMMAND ----------

-- MAGIC %python
-- MAGIC last_tx = spark.conf.get("spark.databricks.delta.lastCommitVersionInSession")
-- MAGIC assert spark.sql(f"DESCRIBE HISTORY beans").select("operation").first()[0] == "RESTORE", "Make sure you reverted your table with the `RESTORE` keyword"
-- MAGIC assert spark.table("beans").count() == 5, "Make sure you reverted to the version after deleting records but before merging"

-- COMMAND ----------

-- MAGIC %md
-- MAGIC By completing this lab, you should now feel comfortable:
-- MAGIC * Completing standard Delta Lake table creation and data manipulation commands
-- MAGIC * Reviewing table metadata including table history
-- MAGIC * Leverage Delta Lake versioning for snapshot queries and rollbacks

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved. Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
