# Databricks notebook source
# MAGIC %md
# MAGIC
# MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
# MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
# MAGIC </div>
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC ## Data Management and Governance with Unity Catalog
# MAGIC In this Data Governance with Unity Catalog session, you'll learn concepts and perform labs that showcase workflows using Unity Catalog - Databricks’ solution to data governance. We'll start off with a brief introduction to Unity Catalog, discuss fundamental data governance concepts, and then dive into a variety of topics including using Unity Catalog for data access control, managing external storage and tables, data segregation, and more. 
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ### Prerequisites
# MAGIC Content was developed for participants with these skills/knowledge/abilities:
# MAGIC - Familiarity with the Databricks Lakehouse completion (`completion of the course Fundamentals of the Databricks Data Intelligence Platform V2`)
# MAGIC - Familiarity with data governance topics
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ### Course Agenda
# MAGIC The following modules are part of the **Data Engineer Learning** Path by Databricks Academy.
# MAGIC | # | Notebook Name |
# MAGIC | --- | --- |
# MAGIC | 1 | [Populating the Metastore]($./1 - Populating the Metastore) |
# MAGIC | 2 | [Navigating the Metastore]($./2L - Navigating the Metastore) |
# MAGIC | 3 | [Upgrading Tables to Unity Catalog]($./3 - Upgrading Tables to Unity Catalog) |
# MAGIC | 4 | [Controlling Access to Data]($./4 - Controlling Access to Data) |
# MAGIC | 5 | [Securing Data in Unity Catalog]($./5L - Securing Data in Unity Catalog) |
# MAGIC | 6 | [BONUS - Lakehouse Monitoring]($./6 BONUS - Lakehouse Monitoring) |
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ### Requirements
# MAGIC
# MAGIC Please review the following requirements before starting the lesson:
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
