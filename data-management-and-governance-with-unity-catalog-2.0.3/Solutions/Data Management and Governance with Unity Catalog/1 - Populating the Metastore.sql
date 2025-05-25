-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Populating the Metastore
-- MAGIC In this demo, we will populate the metastore, focusing on the three-level namespace concept to create data containers and objects. We will cover the creation and management of catalogs, schemas, tables, views, and user-defined functions, demonstrating the execution of SQL commands to achieve these tasks. Additionally, we will verify the settings and inspect the data objects to ensure they are correctly stored and accessible for further analysis. This process includes creating and populating a managed table and view, as well as defining and executing a user-defined function to enhance SQL capabilities within the Unity Catalog environment.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Learning Objectives
-- MAGIC By the end of this demo, you will be able to:
-- MAGIC 1. Identify the prerequisites and understand the three-level namespace concept introduced by Unity Catalog.
-- MAGIC 2. Describe the process of creating and managing catalogs, schemas, tables, views, and user-defined functions within Unity Catalog.
-- MAGIC 3. Execute SQL commands to create and manage catalogs, schemas, tables, and views, and implement user-defined functions in the Unity Catalog environment.
-- MAGIC 4. Inspect and verify the current catalog and schema settings, ensuring that the objects created are correctly stored and accessible for further analysis.
-- MAGIC 5. Develop and populate a managed table and a view, as well as define and execute a user-defined function to extend SQL capabilities within the Unity Catalog.

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
-- MAGIC Run the following cell to configure your working environment for this course. 
-- MAGIC
-- MAGIC **NOTE:** The `DA` object is only used in Databricks Academy courses and is not available outside of these courses. It will dynamically reference the information needed to run the course.

-- COMMAND ----------

-- MAGIC %run ./Includes/Classroom-Setup-1

-- COMMAND ----------

-- MAGIC %md
-- MAGIC In this course, we may use dynamically generated variables created by the classroom setup scripts to reference your catalog and/or schema within the `DA` object. For example, the `DA.catalog_name` variable will dynamically reference your specific catalog when executing SQL code.
-- MAGIC
-- MAGIC
-- MAGIC Run the cell below to view the value of the variable and confirm it matches your catalog name in the cell above.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC print(DA.catalog_name)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## B. Three-Level Namespace Recap

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC
-- MAGIC #### B1. Traditional Two-Level Namespace
-- MAGIC
-- MAGIC Anyone with SQL experience will likely be familiar with the traditional two-level namespace to address tables or views within a schema (often referred to as a database) as shown in the following example:
-- MAGIC <br></br>
-- MAGIC
-- MAGIC ```sql
-- MAGIC SELECT * 
-- MAGIC FROM myschema.mytable;
-- MAGIC ```
-- MAGIC <br>
-- MAGIC
-- MAGIC #### B2. Unity Catalog Three-Level Namespace
-- MAGIC Unity Catalog introduces the concept of a **catalog** into the hierarchy, which provides another containment layer above the schema layer. This provides a new way for organizations to segregate their data and can be handy in many use cases. For example:
-- MAGIC
-- MAGIC * Separating data relating to business units within your organization (sales, marketing, human resources, etc)
-- MAGIC * Satisfying SDLC requirements (dev, staging, prod, etc)
-- MAGIC * Establishing sandboxes containing temporary datasets for internal use
-- MAGIC
-- MAGIC You can have as many catalogs as you want in the metastore, and each can contain as many schemas as you want. To deal with this additional level, complete table/view references in Unity Catalog use a three-level namespace, like this:
-- MAGIC <br></br>
-- MAGIC ```sql
-- MAGIC SELECT * 
-- MAGIC FROM mycatalog.myschema.mytable;
-- MAGIC ```
-- MAGIC We can take advantage of the **`USE`** statements to select a default catalog or schema to make our queries easier to write and read:
-- MAGIC <br></br>
-- MAGIC ```sql
-- MAGIC USE CATALOG mycatalog;
-- MAGIC USE SCHEMA myschema;
-- MAGIC ```

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## C. Create Data Containers and Objects to Populate the Metastore
-- MAGIC
-- MAGIC In this section, let's explore how to create data containers and objects in the metastore. This can be done using SQL and Python. We will focus on SQL in this course. 
-- MAGIC
-- MAGIC   Note that the SQL statements used throughout this lab could also be applied to a DBSQL warehouse as well.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C1. Catalogs

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### C1.1 Create a Catalog 
-- MAGIC
-- MAGIC 1. To create a catalog, use the `CREATE CATALOG <catalog_name>` statement. The `IF NOT EXISTS` keywords will prevent any errors if the catalog name already exists.
-- MAGIC
-- MAGIC ##### NOTE - PLEASE READ, CELL BELOW WILL RETURN AN ERROR (permission denied)
-- MAGIC The code is for example purposes only. Your lab environment does not grant you permission to create your own catalog in this shared training workspace. Instead, the training environment has automatically created your course catalog for you.
-- MAGIC
-- MAGIC Be aware, depending on your organization's setup, there may be occasions when you do not have permission to create catalogs in your environment.

-- COMMAND ----------

-------------------------------------
-- Note below will fail on purpose --
-------------------------------------
CREATE CATALOG IF NOT EXISTS the_catalog_name;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### C1.2 Selecting a Default Catalog
-- MAGIC
-- MAGIC 1. Let's set **your** specific course catalog as the default catalog using the `USE CATALOG <catalog_name>` statement.
-- MAGIC
-- MAGIC    After this, any schema references you make will be assumed to be in this catalog unless you explicitly select a different catalog using a three-level specification.
-- MAGIC
-- MAGIC    **NOTE:** The cell below uses `spark.sql()` to dynamically specify the catalog name using the `DA.catalog_name` variable.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC spark.sql(f'USE CATALOG {DA.catalog_name}')

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### C1.3 Verify the Current Catalog
-- MAGIC 1. Inspect the current catalog setting again using the `current_catalog()` function in SQL. Notice that your default catalog has been set to your specific catalog name.

-- COMMAND ----------

SELECT current_catalog()

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C2. Schemas

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### C2.1 Creating and Using a Schema
-- MAGIC 1. In the following code cell, we will:
-- MAGIC * Create a schema named **example** within our default catalog set in the previous cell
-- MAGIC * Select the **example** schema as the default schema
-- MAGIC * Verify that our default schema is, indeed, the **example**
-- MAGIC
-- MAGIC **NOTE:** The concept of a schema in Unity Catalog is similar to the schemas or databases with which you're already likely familiar. Schemas contain data objects like tables and views but can also contain functions and ML/AI models. Let's create a schema in the catalog we just created. We don't have to worry about name uniqueness since our new catalog represents a clean namespace for the schemas it can hold.
-- MAGIC

-- COMMAND ----------

-- Create a new schema
CREATE SCHEMA IF NOT EXISTS example;

-- Make our newly created schema the default
USE SCHEMA example;

-- Verify the current default schema
SELECT current_catalog(), current_schema();

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Manually view the catalog and schema using the navigation bar on the left by completing the following steps:
-- MAGIC    1. Select the catalog icon on the left.
-- MAGIC
-- MAGIC    2. Expand your unique catalog name.
-- MAGIC
-- MAGIC    3. Expand the **example** schema we previously created.
-- MAGIC
-- MAGIC    4. Leave your catalog explorer open on the left.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C3. Managed Tables
-- MAGIC With all the necessary containers in place, let's turn our attention to creating some data objects.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### C3.1 Create a Managed Table
-- MAGIC
-- MAGIC 1. First let's create a table named **silver**. For this example, we'll pre-populate the table with a simple mock dataset containing synthetic patient heart rate data.
-- MAGIC
-- MAGIC Note the following:
-- MAGIC * We only need to specify the table name when creating the table. We don't need to specify the containing catalog or schema because we already selected defaults earlier with the `USE` statements.
-- MAGIC * This will be a Managed table since we aren't specifying a `LOCATION` or `PATH` keyword in `CREATE TABLE` statement.
-- MAGIC * Because it's a Managed table, it must be a Delta Lake table. (as opposed to Parquet, AVRO, ORC, etc.)

-- COMMAND ----------

-- Create an empty silver table
CREATE OR REPLACE TABLE silver (
  device_id  INT,
  mrn        STRING,
  name       STRING,
  time       TIMESTAMP,
  heartrate  DOUBLE
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Run the `SHOW TABLES` statement to view tables in your default catalog and the schema we set earlier. In the results, you should see the table named **silver** in the **example** schema (database).

-- COMMAND ----------

SHOW TABLES;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### C3.2 Populate and Query the Managed Table
-- MAGIC 1. Populate the **silver** table with some sample data.

-- COMMAND ----------

INSERT OVERWRITE silver VALUES
  (23,'40580129','Nicholas Spears','2020-02-01T00:01:58.000+0000',54.0122153343),
  (17,'52804177','Lynn Russell','2020-02-01T00:02:55.000+0000',92.5136468131),
  (37,'65300842','Samuel Hughes','2020-02-01T00:08:58.000+0000',52.1354807863),
  (23,'40580129','Nicholas Spears','2020-02-01T00:16:51.000+0000',54.6477014191),
  (17,'52804177','Lynn Russell','2020-02-01T00:18:08.000+0000',95.033344842),
  (37,'65300842','Samuel Hughes','2020-02-01T00:23:58.000+0000',57.3391541312),
  (23,'40580129','Nicholas Spears','2020-02-01T00:31:58.000+0000',56.6165053697),
  (17,'52804177','Lynn Russell','2020-02-01T00:32:56.000+0000',94.8134313932),
  (37,'65300842','Samuel Hughes','2020-02-01T00:38:54.000+0000',56.2469995332),
  (23,'40580129','Nicholas Spears','2020-02-01T00:46:57.000+0000',54.8372685558),
  (23,'40580129',NULL,'2020-02-01T00:01:58.000+0000',54.0122153343),
  (17,'52804177',NULL,'2020-02-01T00:02:55.000+0000',92.5136468131),
  (37,'65300842',NULL,'2020-02-01T00:08:58.000+0000',1000052.1354807863),
  (23,'40580129',NULL,'2020-02-01T00:16:51.000+0000',54.6477014191),
  (17,'52804177','Lynn Russell','2020-02-01T00:18:08.000+0000',9),
  (37,'65300842','Samuel Hughes','2020-02-01T00:23:58.000+0000',7),
  (23,'40580129','Nicholas Spears','2020-02-01T00:31:58.000+0000',6),
  (17,'52804177','Lynn Russell','2020-02-01T00:32:56.000+0000',5),
  (37,'65300842','Samuel Hughes','2020-02-01T00:38:54.000+0000',9000),
  (23,'40580129','Nicholas Spears','2020-02-01T00:46:57.000+0000',66),
  (23,'40580129',NULL,'2020-02-01T00:01:58.000+0000',54.0122153343),
  (17,'52804177',NULL,'2020-02-01T00:02:55.000+0000',92.5136468131),
  (37,'65300842',NULL,'2020-02-01T00:08:58.000+0000',1000052.1354807863),
  (23,'40580129',NULL,'2020-02-01T00:16:51.000+0000',54.6477014191),
  (17,'52804177','Lynn Russell','2020-02-01T00:18:08.000+0000',98),
  (37,'65300842','Samuel Hughes','2020-02-01T00:23:58.000+0000',90),
  (23,'40580129','Nicholas Spears','2020-02-01T00:31:58.000+0000',60),
  (17,'52804177','Lynn Russell','2020-02-01T00:32:56.000+0000',50),
  (37,'65300842','Samuel Hughes','2020-02-01T00:38:54.000+0000',30),
  (23,'40580129','Nicholas Spears','2020-02-01T00:46:57.000+0000',80);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Execute queries on the created table to examine its contents, ensuring that the data is correctly stored and accessible for analysis purposes.

-- COMMAND ----------

-- View the rows inside the silver table
SELECT * 
FROM silver;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C4. Creating and Managing Views
-- MAGIC
-- MAGIC 1. Let's create a **vw_gold** view that presents a processed version of the **silver** table data by averaging heart rate data per patient on a daily basis. In the following cell, we will:
-- MAGIC - Create the view
-- MAGIC - Query the view

-- COMMAND ----------

-- Create a gold view
CREATE OR REPLACE VIEW vw_gold AS (
  SELECT 
    mrn, 
    name, 
    MEAN(heartrate) 
    avg_heartrate, 
    DATE_TRUNC("DD", time) AS date
  FROM silver
  GROUP BY mrn, name, DATE_TRUNC("DD", time)
);


-- View the rows inside the gold view
SELECT * 
FROM vw_gold;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Use the `SHOW VIEWS` statement to display all available views. Run the cell and view the results. Notice that we have a view named **vw_gold**. The view is neither temporary nor materialized.

-- COMMAND ----------

SHOW VIEWS;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C5. Creating, Managing and Executing User-Defined Functions
-- MAGIC 1. A User-Defined Function (UDF) in SQL is a feature that allows you to extend the native capabilities of SQL. It enables you to define your business logic as reusable functions that extend the vocabulary of SQL for transforming or masking data and reuse it across your applications. User-defined functions are contained by schemas as well. For this example, we'll set up simple function that masks all but the last two characters of a string.

-- COMMAND ----------

-- Create a custom function to mask a string value except for 2 left-most characters
CREATE OR REPLACE FUNCTION dbacademy_mask(x STRING)
  RETURNS STRING
  RETURN CONCAT(LEFT(x, 2) , REPEAT("*", LENGTH(x) - 2));

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Manually view the newly created function by completing the following steps:
-- MAGIC
-- MAGIC    1. Select the **Catalog** icon (3rd one in icon list) in the left vertical bar (directly under **File** menu).
-- MAGIC
-- MAGIC    2. Expand your unique catalog name.
-- MAGIC
-- MAGIC    3. Expand the **example** schema we previously created. Notice that the schema now contains **Tables** and **Functions**.
-- MAGIC
-- MAGIC    4. Expand **Functions** (you might have to refresh your schema).
-- MAGIC    
-- MAGIC    5. Notice that the newly created function, **dbacademy_mask**, is available in your schema.
-- MAGIC
-- MAGIC
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 3. Let's see how the function we just defined works. Note that you can expand the table by dragging the border to the right if the output is truncated.

-- COMMAND ----------

-- Run the custom function to verify its output
SELECT dbacademy_mask('sensitive data') AS data;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D. Catalog Explorer
-- MAGIC All of the data objects we have created are available to us in the Data Explorer. We can view and change permissions, change object ownership, examine lineage, and a whole lot more.
-- MAGIC
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D1. Using the Catalog Explorer
-- MAGIC 1. Open the Catalog Explorer by right-clicking on **Catalog** in the far left sidebar menu and opening the link in a new tab. This will allow you to keep these instructions open.
-- MAGIC
-- MAGIC 1. Click on your catalog's name. 
-- MAGIC
-- MAGIC     You will see a list of at least five schemas in the catalog: 
-- MAGIC     - **default** - this schema is created when the catalog is created and can be dropped, if needed
-- MAGIC     - **dmguc** - created by the *Classroom Setup* script we ran at the beginning of the notebook (**dmguc** is short for *Data Management and Governance with Unity Catalog*)
-- MAGIC     - **example** - we created this schema above
-- MAGIC     - **information_schema** - this schema is created when the catalog is created and contains a wealth of metadata. We will talk more about this schema in a future lesson
-- MAGIC     - **other** - created by the *Classroom Setup* script.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D2. Delete a Schema
-- MAGIC Let's delete the **other** schema. 
-- MAGIC 1. Under **Your** Catalog, click the **other** schema in the left navigation bar. 
-- MAGIC
-- MAGIC 2. Select the three dots to the right of the schema name.
-- MAGIC
-- MAGIC 3. Select **Open in Catalog Explorer**. 
-- MAGIC
-- MAGIC 4. In the upper-right corner, click the three dots. Then you can select **Delete** to delete the **other** schema. 
-- MAGIC
-- MAGIC 5. Click the warning to accept.
-- MAGIC
-- MAGIC 6. Close the Catalog Explorer browser.
-- MAGIC
-- MAGIC You can also drop a schema with code:
-- MAGIC ```
-- MAGIC DROP SCHEMA IF EXISTS other;
-- MAGIC ```

-- COMMAND ----------

-- If didn't DROP the 'other' schema via the User Interface, you can use the below code to do the same thing

DROP SCHEMA IF EXISTS other;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D3. Add AI Generated Comments
-- MAGIC Now, lets look at the *example* schema we created:
-- MAGIC
-- MAGIC 1. Click **example** schema in the left navigation bar and select the three dots.
-- MAGIC
-- MAGIC 1. Select **Open in Catalog Explorer** to view the details for this schema.
-- MAGIC
-- MAGIC 1. Note the two data objects in the schema, the **silver** table and the **vw_gold** view. 
-- MAGIC
-- MAGIC 1. Click the **silver** table name.
-- MAGIC
-- MAGIC 1. We see the columns we defined for this table. Note the button labeled **AI Generate**. We can use this to generate comments for our columns. 
-- MAGIC
-- MAGIC 1. Click **AI generate**.
-- MAGIC
-- MAGIC 1. The Data Intelligence Platform proposes comments for each column in our table. Click the check next to the first comment to accept it.
-- MAGIC
-- MAGIC 1. We also have an AI suggested description for the table. Click **Accept**. 
-- MAGIC
-- MAGIC 1. Leave the browser open.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D4. Explore Table Information
-- MAGIC 1. There are tabs along the top where we can view and manage metadata about this table:
-- MAGIC   - **Overview** - On the right, we have information about the table, tags, its description, and we can add a row filtering function if we wish. We will talk about this in a future lesson. On the left, we get information about each column in the table
-- MAGIC
-- MAGIC   - **Sample data** - This tab gives us the first rows of the table, so we can see the data contained within the table.
-- MAGIC
-- MAGIC   - **Details** - We get the same information here as we would get by running **`DESCRIBE EXTENDED silver`**.
-- MAGIC
-- MAGIC   - **Permissions** - The UI gives us the ability to manage table permissions. We can **`GRANT`** and **`REVOKE`** permissions here. We will talk about doing this programmatically in a future lesson.
-- MAGIC
-- MAGIC   - **History** - The Delta Lake transaction log is on this tab. We can get this programmatically by running **`DESCRIBE HISTORY silver`**.
-- MAGIC   
-- MAGIC   - **Lineage** - It is very helpful to see table lineage. Click **`See lineage graph`** to see both our *silver* table and the *gold* view. Note that the view gets its data from the *silver* table. Click the "X" in the upper-right corner to close the window.
-- MAGIC
-- MAGIC   - **Insights** - The Databricks Data Intelligence Platform provides these insights, so we can see how our data object is being used.
-- MAGIC
-- MAGIC   - **Quality** - This tab gives us the ability to monitor this table for data quality. Let's talk more about this next.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### E. Dropping a Managed Table
-- MAGIC 1. Because the table we created is a managed table, when it is dropped, the data we added to it is also deleted.

-- COMMAND ----------

DROP TABLE silver;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Conclusion
-- MAGIC In this demo, we explored the process of upgrading tables to Unity Catalog, focusing on the three-level namespace concept. We created and managed catalogs, schemas, tables, views, and user-defined functions, demonstrating the execution of SQL commands for each task. We ensured correct storage and accessibility of data objects, created and populated a managed table and view, and defined a user-defined function to enhance SQL capabilities within the Unity Catalog environment. This comprehensive approach provided a structured and efficient method to manage data in the metastore, leveraging Unity Catalog's advanced features.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
-- MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
