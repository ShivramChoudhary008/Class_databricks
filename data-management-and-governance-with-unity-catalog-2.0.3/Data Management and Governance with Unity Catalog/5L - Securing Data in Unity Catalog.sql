-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Securing Data in Unity Catalog
-- MAGIC
-- MAGIC In this lab, you will create two objects secure tables:
-- MAGIC
-- MAGIC 1. Row Filtering and Column Masking Tables
-- MAGIC
-- MAGIC 2. Dynamic Views
-- MAGIC
-- MAGIC
-- MAGIC ### Learning Objectives
-- MAGIC By the end of this demo, you will be able to:
-- MAGIC 1. Assign access permissions to the newly created view for account users and execute queries to validate the view's functionality and data integrity.
-- MAGIC 1. Develop a dynamic view of the cloned table, applying data redaction and access restrictions to enhance data security.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## REQUIRED - SELECT SERVERLESS
-- MAGIC
-- MAGIC Before executing cells in this notebook, please select Serverless cluster in the lab. Be aware that **Serverless** is enabled by default.
-- MAGIC
-- MAGIC Follow these steps to select the Serverless cluster:
-- MAGIC
-- MAGIC - Navigate to the top-right of this notebook and click the drop-down menu to select your cluster. By default, the notebook will use **Serverless**.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## A. Classroom Setup
-- MAGIC
-- MAGIC Run the following cell to configure your working environment for this course. It will also set your default catalog to your specific catalog and the schema to the schema name shown below using the `USE` statements.
-- MAGIC <br></br>
-- MAGIC
-- MAGIC
-- MAGIC ```
-- MAGIC USE CATALOG <your catalog>;
-- MAGIC USE SCHEMA <your catalog>.<schema>;
-- MAGIC ```
-- MAGIC
-- MAGIC **NOTE:** The `DA` object is only used in Databricks Academy courses and is not available outside of these courses. It will dynamically reference the information needed to run the course.

-- COMMAND ----------

-- MAGIC %run ./Includes/Classroom-Setup-5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Run the code below and confirm that your current catalog is set to your unique catalog name and that the current schema is **default**.
-- MAGIC

-- COMMAND ----------

SELECT current_catalog(), current_schema()

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## B. Protect Columns and Rows with Column Masking and Row Filtering

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### REQUIRED: Create the Table Customers
-- MAGIC 1. Run the code below to create the **customers** table in your **default** schema.

-- COMMAND ----------

CREATE OR REPLACE TABLE customers AS
SELECT *
FROM samples.tpch.customer;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Run a query to view *10* rows from the **customers** table in your **default** schema. Notice that the table contains information such as **c_name**, **c_phone**, and **c_mktsegment**.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B1. Create a Function to Perform Column Masking
-- MAGIC View the [Filter sensitive table data using row filters and column masks](https://docs.databricks.com/en/tables/row-and-column-filters.html) documentation for additional help.
-- MAGIC 1. Create a function named **phone_mask** that redacts the **c_phone** column in the **customers** table if the user is not a member of the ('admin') group using the `is_account_group_member` function. The **phone_mask** function should return the string *REDACTED PHONE NUMBER* if the user is not a member.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Apply the column masking function **phone_mask** to the **customers** table using the `ALTER TABLE` statement.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 3. Run the cell below to confirm that you have correctly masked the **c_phone** column in the **customers** table. If an error is returned make sure the function is created and applied correctly.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC sdf = spark.sql('SELECT c_phone FROM customers GROUP BY c_phone')
-- MAGIC value = sdf.collect()[0][0]
-- MAGIC
-- MAGIC assert value == 'REDACTED PHONE NUMBER', 'The c_phone column should only contain the value "REDACTED PHONE NUMBER". Please create the correct column mask function and apply it to the customers table.'
-- MAGIC print('You correctly applied the column mask to the customers table.')

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 4. Run the query below to view the **customers** table with the column mask applied. Confirm that the **c_phone** column displays the value *REDACTED PHONE NUMBER*.
-- MAGIC
-- MAGIC

-- COMMAND ----------

SELECT *
FROM customers
LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B2. Create a Function to Perform Row Filtering
-- MAGIC View the [Filter sensitive table data using row filters and column masks](https://docs.databricks.com/en/tables/row-and-column-filters.html) documentation for additional help.
-- MAGIC
-- MAGIC 1. Run the cell below to count the total number of rows in the **customers** table. Confirm that the table contains 750,000 rows of data.
-- MAGIC

-- COMMAND ----------

SELECT count(*) AS TotalRows
FROM customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Create a function named **nation_filter** that filters on **c_nationkey** in the **customers** table if the user is not a member of the ('admin') group using the `is_account_group_member` function. The function should only return rows where **c_nationkey** equals *21*.
-- MAGIC
-- MAGIC     View the [if function](https://docs.databricks.com/en/sql/language-manual/functions/if.html) documentation for additional help.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 3. Apply the function row filtering function `nation_filter` to the **customers** table using the `ALTER TABLE` statement.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 4. Run the cell below to confirm that you added row filtering to the **customers** table column **c_nationkey** correctly.
-- MAGIC

-- COMMAND ----------

-- MAGIC %python
-- MAGIC sdf = spark.sql('SELECT c_nationkey FROM customers GROUP BY c_nationkey')
-- MAGIC value = sdf.collect()[0][0]
-- MAGIC
-- MAGIC assert value == 21, 'The c_nationkey column should only contain the value 21. Please create the correct row filter function and apply it to the customers table.'
-- MAGIC print('You correctly applied the row filter.')

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 5. Run the query below to count the number of rows in the **customers** table for you since you've filtered out rows for users not admins. Confirm you can only view *29,859* rows (*where c_nationkey = 21*).

-- COMMAND ----------

SELECT count(*) AS TotalRows
FROM customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 6. Run the query below to view the **customers** table. 
-- MAGIC
-- MAGIC Confirm the final table:
-- MAGIC - redactes the **c_phone** column and
-- MAGIC - filters rows based on the **c_nationkey** column for users who are not *admins*.

-- COMMAND ----------

SELECT *
FROM customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## C. Protecting Columns and Rows with Dynamic Views
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### REQUIRED: Create the Table Customers_new
-- MAGIC 1. Run the code below to create the **customers_new** table in your **default** schema.

-- COMMAND ----------

CREATE OR REPLACE TABLE customers_new AS
SELECT *
FROM samples.tpch.customer;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Run a query to view *10* rows from the **customers_new** table in your **default** schema. Notice that the table contains information such as **c_name**, **c_phone**, and **c_mktsegment**.

-- COMMAND ----------

SELECT *
FROM customers_new
LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C1. Create the Dynamic View
-- MAGIC Let's create a view named **vw_customers** that presents a processed view of the **customers_new** table data with the following transformations:
-- MAGIC 1. Selects all columns from the **customers_new** table.
-- MAGIC
-- MAGIC 2. Redact all values in the **c_phone** column to *REDACTED PHONE NUMBER* unless you are in the `is_account_group_member('admins')`
-- MAGIC     - HINT: Use a `CASE WHEN` statement in the `SELECT` clause.
-- MAGIC
-- MAGIC 3. Restrict the rows where **c_nationkey** is equal to *21* unless you are in the `is_account_group_member('admins')`.
-- MAGIC     - HINT: Use a `CASE WHEN` statement in the `WHERE` clause.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 3. Run the cell below to confirm that you have correctly masked the **c_phone** column in the **vw_customers** view. If an error is returned make sure the function is created and applied correctly.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC sdf = spark.sql('SELECT c_phone FROM vw_customers GROUP BY c_phone')
-- MAGIC value = sdf.collect()[0][0]
-- MAGIC
-- MAGIC assert value == 'REDACTED PHONE NUMBER', 'The c_phone column should only contain the value "REDACTED PHONE NUMBER". Please use the following expression in the SELECT clause: CASE WHEN is_account_group_member("admins") THEN c_phone ELSE "REDACTED PHONE NUMBER" END as c_phone.'
-- MAGIC print('You correctly applied the column mask to the vw_customers view.')

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 4. Run the cell below to confirm that you added row filtering to the **customers** table column **c_nationkey** correctly.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC sdf = spark.sql('SELECT c_nationkey FROM vw_customers GROUP BY c_nationkey')
-- MAGIC value = sdf.collect()[0][0]
-- MAGIC
-- MAGIC assert value == 21, 'The c_nationkey column should only contain the value 21. Please create the correct row filter in the view using the following expression in the WHERE clause: CASE WHEN is_account_group_member("admins") THEN TRUE ELSE c_nationkey = 21 END.'
-- MAGIC print('You correctly applied the row filter to the view.')

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 5. Display the data in the **vw_customers** view. Confirm the **c_phone** column is redacted.

-- COMMAND ----------

SELECT * 
FROM vw_customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 6. Count the number of rows in the **vw_customers** view. Confirm the view contains *29,859* rows.

-- COMMAND ----------

SELECT count(*)
FROM vw_customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C2. Issue Grant Access to View
-- MAGIC 1. Let us issue a grant for "account users" to view the **vw_customers** view.
-- MAGIC
-- MAGIC **NOTE:** You will also need to provide users access to the catalog and schema. In this shared training environment, you are unable to grant access to your catalog to other users.
-- MAGIC

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Use the `SHOW` statement to displays all privileges (inherited, denied, and granted) that affect the **vw_customers** view. Confirm that the **Principal** column contains *account users*.
-- MAGIC
-- MAGIC View the [SHOW GRANTS](https://docs.databricks.com/en/sql/language-manual/security-show-grant.html) documentation for help.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
-- MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
