# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
# MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
# MAGIC </div>
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC ## Build Data Pipelines with Delta Live Tables
# MAGIC By scheduling tasks with Databricks Jobs, applications can be run automatically to keep tables in the Lakehouse fresh. Using Databricks SQL to schedule updates to queries and dashboards allows quick insights using the newest data. In this course, students will be introduced to task orchestration using the Databricks Workflow Jobs UI. Optionally, they will configure and schedule dashboards and alerts to reflect updates to production data pipelines.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ### Prerequisites
# MAGIC You should meet the following prerequisites before starting this course:
# MAGIC
# MAGIC - Beginner familiarity with basic cloud concepts (virtual machines, object storage, identity management)
# MAGIC - Ability to perform basic code development tasks (create compute, run code in notebooks, use basic notebook operations, import repos from git, etc.)
# MAGIC - Intermediate familiarity with basic SQL concepts (CREATE, SELECT, INSERT, UPDATE, DELETE, WHILE, GROUP BY, JOIN, etc.)
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ### Course Agenda
# MAGIC The following modules are part of the Data Engineer Learning Path by Databricks Academy.
# MAGIC | # | Notebook Name |
# MAGIC | --- | --- |
# MAGIC | 1 | [a - Using the DLT UI - PART 1 - Orders]($./1a - Using the DLT UI - PART 1 - Orders) |
# MAGIC | 2 | [b - Using the DLT UI - PART 2 - Customers]($./1b - Using the DLT UI - PART 2 - Customers) |
# MAGIC | 3 | [c - Using the DLT UI - PART 3 Lab - Status]($./1c - Using the DLT UI - PART 3 Lab - Status) |
# MAGIC | 4 | Orders Pipeline: [SQL]($./2A - SQL Pipelines/1 - Orders Pipeline) or [Python]($./2B - Python Pipelines/1 - Orders Pipeline)|
# MAGIC | 5 | Customers Pipeline: [SQL]($./2A - SQL Pipelines/2 - Customers Pipeline) or [Python]($./2B - Python Pipelines/2 - Customers Pipeline) |
# MAGIC | 6 | Status Pipeline Lab: [SQL]($./2A - SQL Pipelines/3L - Status Pipeline Lab) or [Python]($./2B - Python Pipelines/3L - Status Pipeline Lab) |
# MAGIC | 7 | [Delta Live Tables Running Modes]($./3 -  Delta Live Tables Running Modes) |
# MAGIC | 8 | [Pipeline Results]($./4 - Pipeline Results) |
# MAGIC | 9 | [Pipeline Event Logs]($./5 - Pipeline Event Logs) |
# MAGIC
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ### Requirements
# MAGIC Please ensure the following before starting:
# MAGIC
# MAGIC - Use Databricks Runtime version: **`15.4.x-scala2.12`** to run all demo and lab notebooks.
# MAGIC
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
# MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
# MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
# MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
# MAGIC <a href="https://help.databricks.com/">Support</a>
