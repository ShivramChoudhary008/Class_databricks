-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # SQL UDFs
-- MAGIC
-- MAGIC
-- MAGIC ## Learning Objectives
-- MAGIC By the end of this lesson, you should be able to:
-- MAGIC * Define and register SQL UDFs
-- MAGIC * Describe the security model used for sharing SQL UDFs
-- MAGIC * Use **`CASE`** / **`WHEN`** statements in SQL code
-- MAGIC * Leverage **`CASE`** / **`WHEN`** statements in SQL UDFs for custom control flow

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

-- MAGIC %run ./Includes/Classroom-Setup-6

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## User-Defined Functions
-- MAGIC
-- MAGIC User Defined Functions (UDFs) in Spark SQL allow you to register custom SQL logic as functions in a database, making these methods reusable anywhere SQL can be run on Databricks. These functions are registered natively in SQL and maintain all of the optimizations of Spark when applying custom logic to large datasets.
-- MAGIC
-- MAGIC At minimum, creating a SQL UDF requires a function name, optional parameters, the type to be returned, and some custom logic.
-- MAGIC
-- MAGIC Below, a simple function named **`sale_announcement`** takes an **`item_name`** and **`item_price`** as parameters. It returns a string that announces a sale for an item at 80% of its original price.

-- COMMAND ----------

CREATE OR REPLACE FUNCTION sale_announcement(item_name STRING, item_price INT)
RETURNS STRING
RETURN concat("The ", item_name, " is on sale for $", round(item_price * 0.8, 0));


SELECT *, 
  sale_announcement(name, price) AS message 
FROM item_lookup;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Note that this function is applied to all values of the column in a parallel fashion within the Spark processing engine. SQL UDFs are an efficient way to define custom logic that is optimized for execution on Databricks.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Scoping and Permissions of SQL UDFs
-- MAGIC SQL user-defined functions:
-- MAGIC - Persist between execution environments (which can include notebooks, DBSQL queries, and jobs).
-- MAGIC - Exist as objects in the metastore and are governed by the same Table ACLs as databases, tables, or views.
-- MAGIC - To **create** a SQL UDF, you need **`USE CATALOG`** on the catalog, and **`USE SCHEMA`** and **`CREATE FUNCTION`** on the schema.
-- MAGIC - To **use** a SQL UDF, you need **`USE CATALOG`** on the catalog, **`USE SCHEMA`** on the schema, and **`EXECUTE`** on the function.
-- MAGIC
-- MAGIC We can use **`DESCRIBE FUNCTION`** to see where a function was registered and basic information about expected inputs and what is returned (and even more information with **`DESCRIBE FUNCTION EXTENDED`**).

-- COMMAND ----------

DESCRIBE FUNCTION EXTENDED sale_announcement;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Note that the **`Body`** field at the bottom of the function description shows the SQL logic used in the function itself.
-- MAGIC ## Viewing Functions in the Catalog Explorer
-- MAGIC After we create a function, it is associated with a schema. We can view the functions associated with a schema in the Catalog Explorer. 
-- MAGIC 1. Follow [**this link**](explore/data) to open Catalog Explorer in a new tab, or use the **Catalog** link in the left sidebar.
-- MAGIC 1. Run the following cell to obtain the name of your current catalog and schema. Paste your catalog name in the cell marked "Type to search".
-- MAGIC 1. Drill into the catalog to reveal the list of schemas in the catalog, by clicking the disclosure triangle to the left of the catalog name.
-- MAGIC 1. Drill open the schema.
-- MAGIC 1. Note that there is currently one function associated with the schema: **`sale_announcement`**. Select it and explore information about the function we created above.

-- COMMAND ----------

SELECT current_catalog(), current_schema();

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Simple Control Flow Functions
-- MAGIC
-- MAGIC Combining SQL UDFs with control flow in the form of **`CASE`** / **`WHEN`** clauses provides optimized execution for control flows within SQL workloads. The standard SQL syntactic construct **`CASE`** / **`WHEN`** allows the evaluation of multiple conditional statements with alternative outcomes based on table contents.
-- MAGIC
-- MAGIC Here, we demonstrate wrapping this control flow logic in a function that will be reusable anywhere we can execute SQL.

-- COMMAND ----------

CREATE OR REPLACE FUNCTION item_preference(name STRING, price INT)
RETURNS STRING
RETURN CASE 
  WHEN name = "Standard Queen Mattress" THEN "This is my default mattress"
  WHEN name = "Premium Queen Mattress" THEN "This is my favorite mattress"
  WHEN price > 100 THEN concat("I'd wait until the ", name, " is on sale for $", round(price * 0.8, 0))
  ELSE concat("I don't need a ", name)
END;


SELECT *, 
  item_preference(name, price) 
FROM item_lookup;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC While the examples provided here are simple, these same basic principles can be used to add custom computations and logic for native execution in Spark SQL. 
-- MAGIC
-- MAGIC Especially for enterprises that might be migrating users from systems with many defined procedures or custom-defined formulas, SQL UDFs can allow a handful of users to define the complex logic needed for common reporting and analytic queries.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved. Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
