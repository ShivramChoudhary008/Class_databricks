# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
# MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
# MAGIC </div>
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC ## Data Ingestion with Delta Lake
# MAGIC This course prepares data professionals to leverage the Databricks Intelligence Platform to productionalize ETL pipelines. Students will use Delta Live Tables with Spark SQL and Python to define and schedule pipelines that incrementally process new data from a variety of data sources into the Lakehouse. Students will also orchestrate tasks with Databricks Workflows and promote code with Databricks Repos.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ### Prerequisites
# MAGIC You should meet the following prerequisites before starting this course:
# MAGIC
# MAGIC - Beginner familiarity with basic cloud concepts (`virtual machines`, `object storage`, `identity management`)
# MAGIC - Ability to perform basic code development tasks (`create compute`, `run code in notebooks`, `use basic notebook operations`, `import repos from git`, etc)
# MAGIC - Intermediate familiarity with basic SQL concepts (`CREATE`, `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `WHILE`, `GROUP BY`, `JOIN`, etc.)
# MAGIC
# MAGIC ---
# MAGIC ### Course Agenda
# MAGIC The following modules are part of the Data Engineer Learning Path by Databricks Academy.
# MAGIC | # | Notebook Name |
# MAGIC | --- | --- |
# MAGIC | 1 | [Set Up and Load Delta Tables]($./1 - Set Up and Load Delta Tables) |
# MAGIC | 2 | [Basic Transformations]($./2 - Basic Transformations) |
# MAGIC | 3 | [Load Data Lab]($./3L - Load Data Lab) |
# MAGIC | 4 | [Cleaning Data]($./4 - Cleaning Data) |
# MAGIC | 5 | [Complex Transformations]($./5 - Complex Transformations) |
# MAGIC | 6 | [SQL UDFs]($./6 - SQL UDFs) |
# MAGIC | 7 | [Advanced Delta Lake Features]($./7 - Advanced Delta Lake Features) |
# MAGIC | 8 | [Manipulate Delta Tables Lab]($./8L - Manipulate Delta Tables Lab) |
# MAGIC
# MAGIC --- 
# MAGIC
# MAGIC ### Requirements
# MAGIC
# MAGIC Please review the following requirements before starting the lesson:
# MAGIC
# MAGIC * To run demo and lab notebooks, you need to use the following Databricks runtime: **`15.4.x-scala2.12`**
# MAGIC
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC &copy; 2025 Databricks, Inc. All rights reserved. Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
# MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
# MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
# MAGIC <a href="https://help.databricks.com/">Support</a>
