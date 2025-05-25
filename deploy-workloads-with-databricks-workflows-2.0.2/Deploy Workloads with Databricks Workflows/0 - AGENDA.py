# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
# MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
# MAGIC </div>
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC ## Deploy Workloads with Databricks Workflows
# MAGIC By scheduling tasks with Databricks Jobs, applications can be run automatically to keep tables in the Lakehouse fresh. Using Databricks SQL to schedule updates to queries and dashboards allows quick insights using the newest data. In this course, students will be introduced to task orchestration using the Databricks Workflow Jobs UI. Optionally, they will configure and schedule dashboards and alerts to reflect updates to production data pipelines.
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
# MAGIC ### Course Agenda
# MAGIC The following modules are part of the Data Engineer Learning Path by Databricks Academy.
# MAGIC | # | Notebook Name |
# MAGIC | --- | --- |
# MAGIC | 1 | [Scheduling Tasks with the Jobs UI]($./1 - Scheduling Tasks with the Jobs UI) |
# MAGIC | 2 | [Workflows Lab]($./2L - Workflows Lab) |
# MAGIC | 3 | [Explore Scheduling Options]($./3 - Explore Scheduling Options) |
# MAGIC | 4 | [Conditional Tasks and Repair Runs]($./4 - Conditional Tasks and Repair Runs) |
# MAGIC | 5 | [Modular Orchestration]($./5L - Modular Orchestration) |
# MAGIC
# MAGIC ### Requirements
# MAGIC
# MAGIC Please review the following requirements before starting the lesson:
# MAGIC
# MAGIC * To run demo and lab notebooks, you need to use the following Databricks runtime: **`15.4.x-scala2.12`**
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
# MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
# MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
# MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
# MAGIC <a href="https://help.databricks.com/">Support</a>
