-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## A. Classroom Setup
-- MAGIC
-- MAGIC Run the following cell to configure your working environment for this course. It will also set your default catalog to **dbacademy** and the schema to your specific schema name shown below.
-- MAGIC <br></br>
-- MAGIC ```
-- MAGIC USE CATALOG dbacademy;
-- MAGIC USE SCHEMA dbacademy.<your unique schema name>;
-- MAGIC ```
-- MAGIC
-- MAGIC **NOTE:** The **DA** object is only used in Databricks Academy courses and is not available outside of these courses.

-- COMMAND ----------

-- MAGIC %run ../../Includes/Classroom-Setup-2L

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## B. Ingest CSV File and Create Bronze Table

-- COMMAND ----------

CREATE OR REPLACE TABLE customers_bronze
AS
SELECT *
FROM read_files(
        '/Volumes/dbacademy_retail/v01/source_files/customers.csv', 
        format => 'csv',
        header => true);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
-- MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
