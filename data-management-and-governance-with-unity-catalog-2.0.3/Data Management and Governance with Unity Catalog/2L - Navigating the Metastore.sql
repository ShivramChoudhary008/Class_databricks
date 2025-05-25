-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Lab: Navigating the Metastore
-- MAGIC In this demo, we'll explore the structure and functionality of a metastore, delving into its various components like catalogs, schemas, and tables. We'll employ SQL commands such as SHOW and DESCRIBE to inspect and analyze these elements, enhancing our understanding of the metastore's configuration and the properties of different data objects. Additionally, we'll examine the roles of system catalogs and information_schema in metadata management, and highlight the importance of data lineage in data governance. This hands-on demonstration will equip participants with the knowledge to effectively navigate and utilize metastores in a cloud environment.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Learning Objectives
-- MAGIC By the end of this demo, you will be able to:
-- MAGIC 1. Discuss the structure and function of a metastore, including its different components such as catalogs, schemas, and tables.
-- MAGIC 2. Apply SQL commands like `SHOW` and `DESCRIBE` to inspect and explore different elements within the metastore, such as catalogs, schemas, tables, user-defined functions, and privileges.
-- MAGIC 3. Analyze and interpret the configuration of the metastore and the properties of various data objects.
-- MAGIC 4. Evaluate the roles of the system catalog and the information_schema in managing and accessing metadata.
-- MAGIC 5. Identify and explain the importance of data lineage as part of data governance.
-- MAGIC

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

-- MAGIC %run ./Includes/Classroom-Setup-2

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## A. Analyze Data Objects in Classroom Setup
-- MAGIC Let us analyze the current data objects and their components during the classroom setup.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### A1. Analyze the Current Catalog
-- MAGIC
-- MAGIC 1. Run code to view your current default catalog. Confirm that the catalog name displayed above is your current catalog.
-- MAGIC

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### A2. Analyze the Current Schema
-- MAGIC
-- MAGIC 1. Run code to view your current default schema. Confirm that your current schema is **example**.
-- MAGIC

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### A3. Analyze the List of Available Tables and Views in the Custom Schema
-- MAGIC
-- MAGIC 1. Let us analyze your **example** schema to display a list of tables and views. Confirm that the schema contains the **silver** table and the **vw_gold** view.
-- MAGIC

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Display the available views in your current schema. Confirm the schema contains the view **vw_gold**.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **NOTE:** `SHOW TABLES` will display both tables and views, and `SHOW VIEWS` will only show views. From the above observation, there are the following tables and views in the custom schema:
-- MAGIC 1. Table\(s\): **silver**
-- MAGIC 2. View\(s\): **vw_gold**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ## B. Exploring the Metastore
-- MAGIC
-- MAGIC In this section, let's explore our metastore and its data objects.
-- MAGIC
-- MAGIC
-- MAGIC ### Using SQL: Inspect Elements with SQL `SHOW` Command
-- MAGIC Let's explore objects using the SQL commands. Though we embed them in a notebook here, you can easily port them over for execution in the DBSQL environment as well.
-- MAGIC
-- MAGIC We use the SQL `SHOW` command to inspect elements at various levels in the hierarchy.
-- MAGIC
-- MAGIC For syntax references, check out the [SQL language reference - DDL statements](https://docs.databricks.com/en/sql/language-manual/index.html#ddl-statements)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### B1. Inspect Catalogs
-- MAGIC 1. Let's start by displaying all available catalogs in the metastore with the `SHOW` statement. Confirm a variety of catalogs exist.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Do any of these entries surprise you? You should definitely see a catalog beginning with your user name as the prefix, which is the one we created earlier. But there may be more, depending on the activity in your metastore, and how your workspace is configured. In addition to catalogs others have created, you will also see some special catalogs:
-- MAGIC * **hive_metastore**. This is not actually a catalog. Rather, it's Unity Catalog's way of making the workspace local Hive metastore seamlessly accessible through the three-level namespace.
-- MAGIC * **main**: this catalog is created by default with each new metastore, though you can remove it from your metastore if desired (it isn't used by the system)
-- MAGIC * **samples**: this references a cloud container containing sample datasets hosted by Databricks.
-- MAGIC * **system**: this catalog provides an interface to the system tables - a collection of tables that return information about objects across all catalogs in the metastore.
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### B2. Inspect Schemas
-- MAGIC 1. Now let's take a look at the schemas contained in your specific catalog (your default catalog). Remember that we have a default catalog selected so we needn't specify it in our query. Confirm the schemas **default**, **dmguc**, **example** and **information_schema** exist.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC The **example** schema, of course, is the one we created earlier but there are a couple additional entries you maybe weren't expecting:
-- MAGIC * **default**: this schema is created by default with each new catalog.
-- MAGIC * **information_schema**: this schema is also created by default with each new catalog and provides a set of views describing the objects in the catalog.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. As a sidenote, if we want to inspect schemas in a catalog that isn't the default, we specify it as follows `SHOW SCHEMAS IN catalog-name`. Run code to view available schemas in the **samples** catalog. Confirm multiple schemas exist.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### B3. Inspect Tables
-- MAGIC 1. Now let's take a look at the tables contained our  **example** schema within our course catalog. Again, we don't need to specify schema or catalog since we're referencing the defaults. Confirm the **silver** table and **vw_gold** view exist.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. If you want to inspect elsewhere, you can explicitly override the default catalog and schema as follows: `SHOW TABLES IN catalog-name.schema-name`. 
-- MAGIC
-- MAGIC    View the available tables in the **samples** catalog within the **tpch** schema. Confirm that a variety of tables are available.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### B4. Inspect User-Defined Functions
-- MAGIC 1. There's a command available for exploring all the different object types. For example, display the available user-defined functions in your default schema (**examples**). Confirm that the `dbacademy_mask` function is available.
-- MAGIC
-- MAGIC [SHOW FUNCTIONS](https://docs.databricks.com/en/sql/language-manual/sql-ref-syntax-aux-show-functions.html)
-- MAGIC

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### B5. Inspect Privileges Granted on Data Objects
-- MAGIC We can also use `SHOW` to see privileges granted on data objects.
-- MAGIC
-- MAGIC For syntax references, check out the [SQL language reference - Security statements](https://docs.databricks.com/en/sql/language-manual/index.html#security-statements) documentation.
-- MAGIC
-- MAGIC 1. Display all privileges (inherited, denied, and granted) on your **silver** table in the **examples** schema (default schema). Confirm that *ALL PRIVILEGES* are available to your user account.
-- MAGIC
-- MAGIC
-- MAGIC
-- MAGIC **HINT:** `SHOW GRANTS ON`

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Since there are no grants on this table yet, no results are returned. That means that only you, the data owner, can access this table. We'll get to granting privileges shortly.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## C. Analyze Additional Information with SQL `DESCRIBE` Command
-- MAGIC
-- MAGIC We also have `DESCRIBE` at our disposal, to provide additional information about a specific object.
-- MAGIC
-- MAGIC For syntax references, check out the [SQL language reference](https://docs.databricks.com/en/sql/language-manual/index.html#sql-language-reference) documentation.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C1. Analyze Tables
-- MAGIC 1. Let us analyze the information about a few tables. 
-- MAGIC
-- MAGIC     Use the `DESCRIBE TABLE EXTENDED` statement on your **silver** table to display detailed information about the specified columns, including the column statistics collected by the command, and additional metadata information (such as schema qualifier, owner, and access time).

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Use the same statement as above to view information about your **vw_gold** view. In the results, scroll down to the *View Text* value in the **col_name** column. Notice that you can view the SQL text for the view.
-- MAGIC

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C2. Analyze User-Defined Functions
-- MAGIC 1. Let us analyze the information about the **dbacademy_mask** user-defined function in the **example** schema. Use the `DESCRIBE FUNCTION EXTENDED` statement to view detailed information about the function.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## D. Analyze Other Data Objects
-- MAGIC We can also analyze other data objects in the metastore.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D1. System Catalog
-- MAGIC The *system* catalog provides an interface to the system tables; that is a collection of views whose purpose is to provide a SQL-based, self-describing API to the metadata related to objects across all catalogs in the metastore. This exposes a host of information useful for administration and housekeeping and there are a lot of applications for this.
-- MAGIC
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 1. Run the following cell to view tables in the **system** catalog's **information_schema** schema. Notice that a variety of system tables are available.
-- MAGIC
-- MAGIC    **NOTE:** System tables are a Databricks-hosted analytical store of your account’s operational data found in the system catalog. These tables can be used for historical observability across your account.
-- MAGIC
-- MAGIC    For more information, check out the [Monitor usage with system tables](https://docs.databricks.com/en/admin/system-tables/index.html#monitor-usage-with-system-tables) documentation.
-- MAGIC

-- COMMAND ----------

SHOW TABLES in system.information_schema;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC 2. Let's consider the following query, which shows all tables that have been modified in the last *24 hours* using the **system** catalog.
-- MAGIC
-- MAGIC     **NOTE:** In addition to demonstrating how to leverage this information, the query also demonstrates a Unity Catalog three-level namespace reference.

-- COMMAND ----------

SELECT 
    table_name, 
    table_owner, 
    created_by, 
    last_altered, 
    last_altered_by, 
    table_catalog
FROM system.information_schema.tables
WHERE  datediff(now(), last_altered) < 1;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D2. Information Schema
-- MAGIC
-- MAGIC The *information_schema* is automatically created with each catalog and contains a collection of views whose purpose is to provide a SQL-based, self-describing API to the metadata related to the elements contained within the catalog.
-- MAGIC
-- MAGIC The relations found in this schema are documented <a href="https://docs.databricks.com/sql/language-manual/sql-ref-information-schema.html" target="_blank">here</a>. 
-- MAGIC
-- MAGIC 1. As a basic example, let's see all of your available tables in your default catalog. Note that since we only specify two levels here, we're referencing the default catalog selected earlier.

-- COMMAND ----------

<FILL_IN>

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## E. Catalog Explorer
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### E1. Open the Catalog Explorer
-- MAGIC 1. Right-click on **Catalog** in the left sidebar to explore the metastore using the Catalog Explorer user interface.
-- MAGIC    
-- MAGIC    1. Observe the catalogs listed in the **Catalog** pane and select *Open Link in New Tab*.
-- MAGIC
-- MAGIC    2. The items in this list resemble those from the `SHOW CATALOGS` SQL statement we executed earlier.
-- MAGIC
-- MAGIC    3. Expand your unique catalog name, then expand **example**. This displays a list of tables, views, and functions.
-- MAGIC    
-- MAGIC    4. Expand **tables**, then select **vw_gold** to see detailed information regarding the view. 
-- MAGIC    
-- MAGIC    5. From here, you can view the schema, sample data, details, and permissions (which we'll get to shortly).
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### E2. Lineage
-- MAGIC
-- MAGIC Data lineage is a key pillar of any data governance solution.
-- MAGIC
-- MAGIC 1. Select the **Lineage** tab.
-- MAGIC
-- MAGIC 2. In the **Lineage** tab, you can identify elements related to the selected object.
-- MAGIC
-- MAGIC 3. Select the **See lineage graph** button in the upper left corner.
-- MAGIC
-- MAGIC 4. The lineage graph provides a visualization of the lineage relationships.
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Conclusion
-- MAGIC In this demo, we explored the structure and functionality of a metastore through practical exercises, enhancing our understanding of data organization and metadata management. We learned how to navigate and inspect various components such as catalogs, schemas, tables, and user-defined functions using SQL commands like SHOW and DESCRIBE. Additionally, we delved into the roles of the system catalog and information_schema, gaining insights into their importance in metadata access and management. The demo also highlighted the significance of data lineage for robust data governance, enabling us to trace data origins and impacts effectively. Overall, this hands-on approach has equipped us with essential skills to manage and analyze metadata within a metastore efficiently.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved.<br/>
-- MAGIC Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
