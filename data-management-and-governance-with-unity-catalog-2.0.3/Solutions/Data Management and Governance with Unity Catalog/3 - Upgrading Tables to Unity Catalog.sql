-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Upgrading Tables to Unity Catalog
-- MAGIC
-- MAGIC In this demo, you will learn essential techniques for upgrading tables to the Unity Catalog, a pivotal step in efficient data management. This demo will cover various aspects, including analyzing existing data structures, applying migration techniques, evaluating transformation options, and upgrading metadata without moving data. Both SQL commands and user interface (UI) tools will be utilized for seamless upgrades.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Learning Objectives
-- MAGIC By the end of this demo, you will be able to:
-- MAGIC 1. Analyze the current catalog, schema, and table structures in your data environment.
-- MAGIC 2. Execute methods to move data from Hive metastore to Unity Catalog, including cloning and Create Table As Select \(CTAS\).
-- MAGIC 3. Assess and apply necessary data transformations during the migration process.
-- MAGIC 4. Utilize methods to upgrade table metadata while keeping data in its original location.
-- MAGIC 5. Perform table upgrades using both SQL commands and user interface tools for efficient data management.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Prerequisites
-- MAGIC In order to follow along with this demo, you will need:
-- MAGIC * Account administrator capabilities
-- MAGIC * Cloud resources to support the metastore
-- MAGIC * Have metastore admin capability in order to create and manage a catalog

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## REQUIRED - SELECT CLASSIC COMPUTE
-- MAGIC ### ---SERVERLESS COMPUTE WILL NOT WORK WITH THE HIVE_METASTORE---
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

-- MAGIC %run ./Includes/Classroom-Setup-3

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B. Analyze the List of Available Table and Views in the Custom Schema
-- MAGIC 1. Let us analyze the **example** schema within your catalog for the list of tables and views. This has already been set up for you using the setup script. Take note of the tables in your schema.
-- MAGIC

-- COMMAND ----------

SELECT current_catalog(), current_schema();

-- COMMAND ----------

-- Show the list of tables within the custom schema
SHOW TABLES FROM example;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Display a list of views in your **example** schema. Take note of the view(s) in your schema.
-- MAGIC

-- COMMAND ----------

-- Show the list of views within the custom schema
SHOW VIEWS FROM example;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C. Exploring the Hive Metastore Source Table
-- MAGIC
-- MAGIC As part of the setup, we now have a table called *movies*, residing in a user-specific schema of the Hive metastore. To make things easier, the schema name in the hive_metastore stored in a variable named `user_hive_schema` that was created in the classroom setup script.

-- COMMAND ----------

-- View the value of the user_hive_schema SQL variable
SELECT user_hive_schema;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 1. Let's preview the data stored in this table using that variable. Notice how the three-level namespaces makes referencing data objects in the Hive metastore seamless.
-- MAGIC
-- MAGIC     Here we will use the `IDENTIFIER()` clause which enables SQL injection safe parameterization of SQL statements and enables you to interprets a constant string as a:
-- MAGIC     - table or view name
-- MAGIC     - function name
-- MAGIC     - column name
-- MAGIC     - field name
-- MAGIC
-- MAGIC     View the [documentation](https://docs.databricks.com/en/sql/language-manual/sql-ref-names-identifier-clause.html#identifier-clause) for more information.

-- COMMAND ----------

--  Show the first 10 rows from the movies table residing in the user-specific schema of the Hive metastore

SELECT * 
FROM IDENTIFIER('hive_metastore.' || user_hive_schema || '.movies')
LIMIT 10

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## D. Overview of Upgrade Methods
-- MAGIC
-- MAGIC There are a few different ways to upgrade a table, but the method you choose will be driven primarily by how you want to treat the table data. If you wish to leave the table data in place, then the resulting upgraded table will be an external table. If you wish to move the table data into your Unity Catalog metastore, then the resulting table will be a managed table. Consult [this page](https://docs.databricks.com/en/data-governance/unity-catalog/index.html#managed-versus-external-tables-and-volumes) for tips on whether to choose a managed or external table.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D1. Moving Table Data into the Unity Catalog Metastore
-- MAGIC
-- MAGIC In this approach, table data will be copied from wherever it resides into the managed data storage area for the destination schema, catalog or metastore. The result will be a managed Delta table in your Unity Catalog metastore. 
-- MAGIC
-- MAGIC This approach has two main advantages:
-- MAGIC * Managed tables in Unity Catalog can benefit from product optimization features that may not work well (if at all) on tables that aren't managed
-- MAGIC * Moving the data also gives you the opportunity to restructure your tables, in case you want to make any changes
-- MAGIC
-- MAGIC The main disadvantage to this approach is, particularly for large datasets, the time and cost associated with copying the data.
-- MAGIC
-- MAGIC In this section, we cover two different options that will move table data into the Unity Catalog metastore.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D1.1 Cloning a Table
-- MAGIC
-- MAGIC Cloning a table is optimal when the source table is Delta (see <a href="https://docs.databricks.com/delta/clone.html" target="_blank">documentation</a> for a full explanation). It's simple to use, it will copy metadata, and it gives you the option of copying data (deep clone) or optionally leaving it in place (shallow clone). Shallow clones can be useful in some use cases.
-- MAGIC
-- MAGIC 1. Run the following cell to check the format of the source table. View the results. Notice the following:
-- MAGIC
-- MAGIC - Referring to the *Provider* row, we see the source is a Delta table. 
-- MAGIC - Referring to the *Location* row, we see that the table is stored in DBFS.

-- COMMAND ----------

-- Describe the properties of the "movies" table in the user-specific schema of the Hive metastore using the extended option for more details.
-- DESCRIBE EXTENDED hive_metastore.yourschema.movies

DESCRIBE EXTENDED IDENTIFIER('hive_metastore.' || user_hive_schema || '.movies')

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Let's perform a deep clone operation to copy the table from the hive metastore, creating a destination table named *movies_clone* in the **example** schema with your catalog.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC ## Deep clone the "movies" table from the user-specific schema of the Hive metastore to create a new table named "movies_clone" in the user-specific catalog of the example schema.
-- MAGIC
-- MAGIC results = spark.sql(f'''
-- MAGIC CREATE OR REPLACE TABLE movies_clone 
-- MAGIC DEEP CLONE hive_metastore.{DA.user_hive_schema}.movies
-- MAGIC ''')
-- MAGIC
-- MAGIC display(results)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 3. Let's manually view our **example** schema within our catalog.
-- MAGIC     1. Select the catalog icon on the left. 
-- MAGIC
-- MAGIC     1. Expand your unique catalog name.
-- MAGIC
-- MAGIC     1. Expand the **example** schema.
-- MAGIC
-- MAGIC     1. Expand **Tables**.
-- MAGIC
-- MAGIC     1. Notice that the **movies** table from the hive metastore has been cloned into your schema as **movies_clone**.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D1.2 Create Table As Select (CTAS)
-- MAGIC
-- MAGIC Using CTAS is a universally applicable technique that simply creates a new table based on the output of a **`SELECT`** statement. This will always copy the data, and no metadata will be copied.
-- MAGIC
-- MAGIC 1. Let's copy the table from the hive metastore using this approach, creating a destination table named *movies_ctas* in our catalog within the **example** schema.

-- COMMAND ----------

-- Copy the "movies" table from the user-specific schema of the Hive metastore to create "movies_ctas" in the user-specific catalog's example schema using CTAS (Create Table As Select)

CREATE OR REPLACE TABLE movies_ctas AS 
SELECT * 
FROM IDENTIFIER('hive_metastore.' || user_hive_schema || '.movies');

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Run the `SHOW TABLES` statement to view tables in your **example** schema. Notice that the **movies_ctas** table was created in your catalog from the **movies** table from the hive metastore.

-- COMMAND ----------

SHOW TABLES IN example;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D1.3 Applying Transformations during the Upgrade
-- MAGIC
-- MAGIC CTAS offers an option that other methods do not: the ability to transform the data while copying it.
-- MAGIC
-- MAGIC When migrating your tables to Unity Catalog, it's a great time to consider your table structures and whether they still address your organization's business requirements that may have changed over time.
-- MAGIC
-- MAGIC Cloning, and the CTAS operation we just saw, takes an exact copy of the source table. But CTAS can be easily adapted to perform any transformations during the upgrade.
-- MAGIC
-- MAGIC For example, you could modify the table when migrating it from the hive metastore to Unity Catalog.

-- COMMAND ----------

-- Copy the "movies" table from Hive metastore to create "movies_transformed" in the user-specific catalog using CTAS with the required transformations
CREATE OR REPLACE TABLE movies_transformed AS 
SELECT
  id AS Movie_ID,
  title AS Movie_Title,
  genres AS Genres,
  upper(original_language) AS Original_Language,
  vote_average AS Vote_Average
FROM IDENTIFIER('hive_metastore.' || user_hive_schema || '.movies');

-- COMMAND ----------

-- Display the contents of the "movies_transformed" table from the user-specific catalog of the example schema
SELECT * 
FROM movies_transformed;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ### D2 Upgrade External Tables in Hive Metastore to External Tables in Unity Catalog
-- MAGIC
-- MAGIC **NOTE: This lab environment does not have access to external tables. This is an example of what you can do in your environment.**
-- MAGIC
-- MAGIC We have seen approaches that involve moving table data from wherever it is currently to the Unity Catalog metastore. However, in upgrading external tables, some use cases may call for leaving the data in place. For example:
-- MAGIC * Data location is dictated by an internal or regulatory requirement of some sort
-- MAGIC * Cannot change the data format to Delta
-- MAGIC * Outside writers must be able to modify the data
-- MAGIC * Avoiding time and/or cost of moving large datasets
-- MAGIC
-- MAGIC Note the following constraints for this approach:
-- MAGIC
-- MAGIC * Source table must be an external table
-- MAGIC * There must be a storage credential referencing the storage container where the source table data resides
-- MAGIC
-- MAGIC In this section, we cover two different options that will upgrade to an external table without moving any table data.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D2.1 Using SYNC to Export Hive External Tables to Unity Catalog
-- MAGIC
-- MAGIC The **`SYNC`** SQL command allows us to upgrade **external tables** in Hive Metastore to **external tables** in Unity Catalog.
-- MAGIC
-- MAGIC For more information on the [SYNC statement](https://docs.databricks.com/en/sql/language-manual/sql-ref-syntax-aux-sync.html#sync) view the documentation.
-- MAGIC
-- MAGIC **NOTE:** This lab workspace does not enable you to create external tables.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D2.2 Using Catalog Explorer to Upgrade Tables to Unity Catalog from the Hive Metastore
-- MAGIC
-- MAGIC Let's try upgrading the table using the Catalog Explorer user interface.
-- MAGIC
-- MAGIC 1. Select the catalog icon on the left.
-- MAGIC
-- MAGIC 1. Expand the **hive_metastore**.
-- MAGIC
-- MAGIC 1. Expand your schema name in the hive metastore.
-- MAGIC
-- MAGIC 1. Right click on your schema name and select **Open in Catalog Explorer**.
-- MAGIC
-- MAGIC 1. Select the **movies** table \(it can be any available table\).
-- MAGIC
-- MAGIC 1. Click **Upgrade**.
-- MAGIC
-- MAGIC 1. Select your destination catalog and schema. 
-- MAGIC
-- MAGIC 1. For **Select catalog** select your unique catalog name.
-- MAGIC
-- MAGIC 1. For **Select schema** select the **example** schema.
-- MAGIC
-- MAGIC 1. For this example, let's leave owner set to the default (your username).
-- MAGIC
-- MAGIC 1. Click **Next**.
-- MAGIC
-- MAGIC From here you can run the upgrade, or open a notebook containing the upgrade operations that you can run interactively. For the purpose of the exercise, you don't need to actually run the upgrade since it uses `SYNC` behind the scenes.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## CleanUp
-- MAGIC Lets quickly clean up the data in hive metastore by running below command.

-- COMMAND ----------

-- MAGIC %py
-- MAGIC DA.cleanup_hive_metastore()

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Conclusion
-- MAGIC In this demo, we explored crucial techniques for upgrading tables to the Unity Catalog, focusing on efficient data management. We learned to analyze existing data structures, apply migration techniques, evaluate transformation options, and upgrade metadata without moving data. Through SQL commands and user interface tools, we seamlessly executed upgrades, considering the treatment of table data as either external or managed within the Unity Catalog. With a thorough understanding of these methods, you are now equipped to optimize your data management processes effectively.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
-- MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
