-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Lakehouse Monitoring
-- MAGIC
-- MAGIC Databricks Lakehouse Monitoring lets you monitor statistical properties and quality of the data in a particular table or all tables in your account. To monitor a table in Databricks, you create a monitor attached to the table.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Learning Objectives
-- MAGIC By the end of this demo, you will be able to:
-- MAGIC 1. Learn use Lakehouse Monitoring on a table.

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
-- MAGIC ## A. Classroom Setup
-- MAGIC
-- MAGIC Run the following cell to configure your working environment for this course. It will also set your default catalog to **dbacademy** and the schema to your specific schema name shown below using the `USE` statements.
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

-- MAGIC %run ./Includes/Classroom-Setup-6

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## B. Databricks Lakehouse Monitoring 
-- MAGIC ### NOTES (PLEASE READ)
-- MAGIC **This demonstration takes about 25 minutes to complete by an instructor. Complete this bonus demonstration in one of the following methods:**
-- MAGIC 1. (Complete as live demo in an instructor lead class - 25 minutes) Start the demo and take a 10 minute break while the monitor is being created. When you update the monitor it will take another 5-7 minutes to update.
-- MAGIC
-- MAGIC 1.  (Show basics, then use screenshots as walkthrough - 10 minutes) Simply create the monitor and use the screenshots below to show what the monitor looks like. User's can perform this demonstration after class.
-- MAGIC
-- MAGIC 1.  (Do it yourself student lab assignment  - 30 minutes) User complete as homework/lab assignment depending on time.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B1. Create a Monitor
-- MAGIC We can create a monitor using the Catalog Explorer or the API. Let's use the Catalog Explorer to create a monitor attached to our **`silver`** table under user's catalog.
-- MAGIC
-- MAGIC 1. If you aren't already on the **Quality** tab, click it. 
-- MAGIC
-- MAGIC 1. To create a new monitor, click **Get Started**. 
-- MAGIC
-- MAGIC 1. Drop down the **Profile type** and select **Snapshot**. 
-- MAGIC
-- MAGIC 1. Drop down **Advanced options**, and select **Refresh manually** radio button.
-- MAGIC
-- MAGIC 1. Click **Create**.
-- MAGIC
-- MAGIC     **NOTE:** Creating a monitor can take up to 10 minutes. Wait until the monitor is fully created before running the next cell.
-- MAGIC
-- MAGIC 1. To view the progress of the refresh:
-- MAGIC   - Refresh your browser
-- MAGIC   - Select **View refresh history**.
-- MAGIC
-- MAGIC
-- MAGIC ![Class_6_image-1](files/images/data-management-and-governance-with-unity-catalog-2.0.3/Class_6_image-1.png)
-- MAGIC
-- MAGIC <!-- ![Image Title](../images/Class_6_image-1.png) -->

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B2. Looking at the Monitor's Dashboard
-- MAGIC
-- MAGIC 1. Once the initial update is complete, click **View dashboard** on the monitor page to open the monitor's example dashboard. Leave the **Quality** page open.
-- MAGIC
-- MAGIC 1. Since we have been using sample data, we need to change the dropdowns for **Start Time** and **End Time** to fit the dates in the data. 
-- MAGIC
-- MAGIC 1. Drop down **Start Time** by clicking on the number 12 (not the calendar icon) in the dropdown field. 
-- MAGIC
-- MAGIC 1. Click the double, left-pointing arrow until you reach "2019." 
-- MAGIC
-- MAGIC 1. Select the first day of any month in 2019.
-- MAGIC
-- MAGIC 1. Click the calendar icon in the **End Time** field, and select **Now**.
-- MAGIC
-- MAGIC 1. In the top right corner you will need to select a SQL warehouse. Select the drop down and select **shared_warehouse**.
-- MAGIC   
-- MAGIC 1. The dashboard runs a refresh. When the refresh completes, explore some of the visualizations in the dashboard.
-- MAGIC
-- MAGIC ![Class_6_image-2](files/images/data-management-and-governance-with-unity-catalog-2.0.3/Class_6_image-2.png)
-- MAGIC <!-- ![Image Title](../images/Class_6_image-2.png) -->

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B3. Add More Data (30 more rows)
-- MAGIC 1. Run the following two cells to add more data to the **silver** table.

-- COMMAND ----------

INSERT INTO silver VALUES
  (23,'40580129','Nicholas Spears','2024-02-01T00:01:58.000+0000',54.0122153343),
  (17,'52804177','Lynn Russell','2024-02-01T00:02:55.000+0000',92.5136468131),
  (37,'65300842','Samuel Hughes','2024-02-01T00:08:58.000+0000',52.1354807863),
  (23,'40580129','Nicholas Spears','2024-02-01T00:16:51.000+0000',54.6477014191),
  (17,'52804177','Lynn Russell','2024-02-01T00:18:08.000+0000',95.033344842),
  (37,'65300842','Samuel Hughes','2024-02-01T00:23:58.000+0000',57.3391541312),
  (23,'40580129','Nicholas Spears','2024-02-01T00:31:58.000+0000',56.6165053697),
  (17,'52804177','Lynn Russell','2024-02-01T00:32:56.000+0000',94.8134313932),
  (37,'65300842','Samuel Hughes','2024-02-01T00:38:54.000+0000',56.2469995332),
  (23,'40580129','Nicholas Spears','2024-02-01T00:46:57.000+0000',54.8372685558),
  (23,'40580129',NULL,'2024-02-01T00:01:58.000+0000',54.0122153343),
  (17,'52804177',NULL,'2024-02-01T00:02:55.000+0000',92.5136468131),
  (37,'65300842',NULL,'2024-02-01T00:08:58.000+0000',1000052.1354807863),
  (23,'40580129',NULL,'2024-02-01T00:16:51.000+0000',54.6477014191),
  (17,'52804177','Lynn Russell','2024-02-01T00:18:08.000+0000',0),
  (37,'65300842','Samuel Hughes','2024-02-01T00:23:58.000+0000',0),
  (23,'40580129','Nicholas Spears','2024-02-01T00:31:58.000+0000',0),
  (17,'52804177','Lynn Russell','2024-02-01T00:32:56.000+0000',0),
  (37,'65300842','Samuel Hughes','2024-02-01T00:38:54.000+0000',0),
  (23,'40580129','Nicholas Spears','2024-02-01T00:46:57.000+0000',0),
  (23,'40580129',NULL,'2024-02-01T00:01:58.000+0000',54.0122153343),
  (17,'52804177',NULL,'2024-02-01T00:02:55.000+0000',92.5136468131),
  (37,'65300842',NULL,'2024-02-01T00:08:58.000+0000',1000052.1354807863),
  (23,'40580129',NULL,'2024-02-01T00:16:51.000+0000',54.6477014191),
  (17,'52804177','Lynn Russell','2024-02-01T00:18:08.000+0000',0),
  (37,'65300842','Samuel Hughes','2024-02-01T00:23:58.000+0000',0),
  (23,'40580129','Nicholas Spears','2024-02-01T00:31:58.000+0000',0),
  (17,'52804177','Lynn Russell','2024-02-01T00:32:56.000+0000',0),
  (37,'65300842','Samuel Hughes','2024-02-01T00:38:54.000+0000',0),
  (23,'40580129','Nicholas Spears','2024-02-01T00:46:57.000+0000',0);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B4. Refresh the Monitor After Inserting New Data
-- MAGIC 1. Navigate back to the monitor tab and select **Refresh metrics** (this one should not take as long as the first one). 
-- MAGIC
-- MAGIC 1. Click on **View refresh history**. Notice that the monitor is refreshing (about 5 minutes).
-- MAGIC
-- MAGIC 1. When the refresh is complete, navigate back to the dashboard.
-- MAGIC
-- MAGIC 1. In the refreshed dashboard, notice additional information with the new data is shown.
-- MAGIC
-- MAGIC
-- MAGIC ![Class_6_image-3](files/images/data-management-and-governance-with-unity-catalog-2.0.3/Class_6_image-3.png)
-- MAGIC
-- MAGIC <!-- ![Image Title](../images/Class_6_image-3.png) -->

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
-- MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
