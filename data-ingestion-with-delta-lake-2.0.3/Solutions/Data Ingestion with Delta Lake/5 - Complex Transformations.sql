-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Complex Transformations
-- MAGIC
-- MAGIC Querying tabular data stored in the data intelligence platform with Spark SQL is easy, efficient, and fast.
-- MAGIC
-- MAGIC This gets more complicated as the data structure becomes less regular, when many tables need to be used in a single query, or when the shape of data needs to be changed dramatically. This notebook introduces a number of functions present in Spark SQL to help engineers complete even the most complicated transformations.
-- MAGIC
-- MAGIC ## Learning Objectives
-- MAGIC By the end of this lesson, you should be able to:
-- MAGIC - Use **`.`** and **`:`** syntax to query nested data
-- MAGIC - Parse JSON strings into structs
-- MAGIC - Flatten and unpack arrays and structs
-- MAGIC - Combine datasets using joins
-- MAGIC - Reshape data using pivot tables

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
-- MAGIC Run the following cell to configure your working environment for this course. It will also set your default catalog to **dbacademy** and the schema to your specific schema name shown below using the `USE` statements.
-- MAGIC <br></br>
-- MAGIC
-- MAGIC
-- MAGIC ```
-- MAGIC USE CATALOG dbacademy;
-- MAGIC USE SCHEMA dbacademy.<your unique schema name>;
-- MAGIC ```
-- MAGIC
-- MAGIC **NOTE:** The `DA` object is only used in Databricks Academy courses and is not available outside of these courses. It will dynamically reference the information needed to run the course.

-- COMMAND ----------

-- MAGIC %run ./Includes/Classroom-Setup-5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ## Data Overview
-- MAGIC
-- MAGIC The **`events_raw`** table was registered against data representing a Kafka payload. In most cases, Kafka data will be binary-encoded JSON values. 
-- MAGIC
-- MAGIC Let's cast the **`key`** and **`value`** as strings to view these values in a human-readable format.

-- COMMAND ----------

-- DBTITLE 1,Note the two ways to code a CAST
CREATE OR REPLACE TEMP VIEW events_strings AS 
SELECT 
  CAST(key AS string) AS key,  string(value) 
FROM events_raw;



SELECT * 
FROM events_strings LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC As we can see from the results above, the data consists of a unique key and a JSON string of event data.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Manipulate Complex Types

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Work with Nested Data
-- MAGIC Spark SQL has built-in functionality to directly interact with nested data stored as JSON strings or struct types.
-- MAGIC - Use **`:`** syntax in queries to access subfields in JSON strings
-- MAGIC - Use **`.`** syntax in queries to access subfields in struct types
-- MAGIC
-- MAGIC Let's step into the **`value`** column and grab one row of data with an **`event_name`** of "finalize."

-- COMMAND ----------

SELECT * 
FROM events_strings 
WHERE value:event_name = "finalize" 
ORDER BY key 
LIMIT 1;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Let's use the **JSON** string example above to derive the schema, then parse the entire **JSON** column into **STRUCT** types.
-- MAGIC - **`schema_of_json()`** returns the schema derived from an example **JSON** string.
-- MAGIC - **`from_json()`** parses a column containing a **JSON** string into a **STRUCT** type using the specified schema.
-- MAGIC
-- MAGIC After we unpack the **JSON** string to a **STRUCT** type, let's unpack and flatten all **STRUCT** fields into columns.
-- MAGIC
-- MAGIC **`*`** unpacking can be used to flatten a **STRUCT**; **`col_name.*`** pulls out the subfields of **`col_name`** into their own columns.

-- COMMAND ----------

SELECT schema_of_json('{"device":"Linux","ecommerce":{"purchase_revenue_in_usd":1075.5,"total_item_quantity":1,"unique_items":1},"event_name":"finalize","event_previous_timestamp":1593879231210816,"event_timestamp":1593879335779563,"geo":{"city":"Houston","state":"TX"},"items":[{"coupon":"NEWBED10","item_id":"M_STAN_K","item_name":"Standard King Mattress","item_revenue_in_usd":1075.5,"price_in_usd":1195.0,"quantity":1}],"traffic_source":"email","user_first_touch_timestamp":1593454417513109,"user_id":"UA000000106116176"}') AS schema;

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW parsed_events AS 
SELECT json.* 
FROM (
  SELECT from_json(value, 'STRUCT<device: STRING, ecommerce: STRUCT<purchase_revenue_in_usd: DOUBLE, total_item_quantity: BIGINT, unique_items: BIGINT>, event_name: STRING, event_previous_timestamp: BIGINT, event_timestamp: BIGINT, geo: STRUCT<city: STRING, state: STRING>, items: ARRAY<STRUCT<coupon: STRING, item_id: STRING, item_name: STRING, item_revenue_in_usd: DOUBLE, price_in_usd: DOUBLE, quantity: BIGINT>>, traffic_source: STRING, user_first_touch_timestamp: BIGINT, user_id: STRING>') AS json 
  FROM events_strings);


SELECT * 
FROM parsed_events;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Manipulate Arrays
-- MAGIC
-- MAGIC Spark SQL has a number of functions for manipulating array data, including the following:
-- MAGIC - **`explode()`** separates the elements of an array into multiple rows; this creates a new row for each element.
-- MAGIC - **`size()`** provides a count for the number of elements in an array for each row.
-- MAGIC
-- MAGIC The code below explodes the **`items`** field (an array of structs) into multiple rows and shows events containing arrays with 3 or more items.

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW exploded_events AS
SELECT  *, 
  explode(items) AS item
FROM parsed_events;

-- Find users with more than 2 items in their cart
SELECT * 
FROM exploded_events 
WHERE size(items) > 2;

-- COMMAND ----------

-- Confirm data type for new exploded 'item' column
DESCRIBE exploded_events;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Nesting Functions
-- MAGIC We may want to see a list of all events associated with each **`user_id`** and we can collect all items that have been in a user's cart at any time for any event. Let's walk through how we can accomplish this.
-- MAGIC ### Step 1
-- MAGIC We use **`collect_set()`** to gather ("collect") all unique values in a group, including arrays. We use it here to collect all unique **`item_id`**'s in our **`items`** array of structs.
-- MAGIC

-- COMMAND ----------

SELECT 
  user_id,
  collect_set(items.item_id) AS cart_history
FROM exploded_events
GROUP BY user_id
ORDER BY user_id;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC In this case, our result for the list of **`item_id`**'s is an array nested in another array, so let's use **`flatten()`** to pull all items into a single array.
-- MAGIC

-- COMMAND ----------

-- Note we have stripped off the outer most [] brackets from above Output by using 'flatten'
SELECT 
  user_id,
  flatten(collect_set(items.item_id)) AS cart_history
FROM exploded_events
GROUP BY user_id
ORDER BY user_id;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Because there were multiple sets of items involved, there are duplicate values in our array. We use **`array-distinct()`** to remove these duplicates.

-- COMMAND ----------

-- Navigate to Row 97. Compare it to Row 97 of previous output. Note the difference.
SELECT 
  user_id,
  array_distinct(flatten(collect_set(items.item_id))) AS cart_history
FROM exploded_events
GROUP BY user_id
ORDER BY user_id;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC In the following cell, we combine **`collect_set()`**, **`flatten()`**, and **`array_distinct()`** to accomplish what we desire:
-- MAGIC
-- MAGIC We use **`collect_set`** twice in the cell below: once to collect all **`event_name`**'s, and again on the **`item_id`**'s in the **`item`** column. We nest the second call to **`collect_set`** in our **`flatten()`** and **`array_distinct`** calls as outlined above.

-- COMMAND ----------

SELECT 
  user_id,
  collect_set(event_name) AS event_history,
  array_distinct(flatten(collect_set(items.item_id))) AS cart_history
FROM exploded_events
GROUP BY user_id
ORDER BY user_id;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Combine and Reshape Data

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Join Tables
-- MAGIC
-- MAGIC Spark SQL supports standard **`JOIN`** operations (inner, outer, left, right, anti, cross, semi).  
-- MAGIC Here we join the exploded events dataset with a lookup table to grab the standard printed item name.

-- COMMAND ----------

CREATE OR REPLACE TEMP VIEW item_purchases AS
SELECT * 
FROM (SELECT *, explode(items) AS item 
      FROM sales) a
INNER JOIN item_lookup b
ON a.item.item_id = b.item_id;


SELECT * 
FROM item_purchases

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Pivot Tables
-- MAGIC
-- MAGIC We can use **`PIVOT`** to view data from different perspectives by rotating unique values in a specified pivot column into multiple columns based on an aggregate function.
-- MAGIC - The **`PIVOT`** clause follows the table name or subquery specified in a **`FROM`** clause, which is the input for the pivot table.
-- MAGIC - Unique values in the pivot column are grouped and aggregated using the provided aggregate expression, creating a separate column for each unique value in the resulting pivot table.
-- MAGIC
-- MAGIC The following code cell uses **`PIVOT`** to flatten out the item purchase information contained in several fields derived from the **`sales`** dataset. This flattened data format can be useful for dashboarding, but also useful for applying machine learning algorithms for inference or prediction.

-- COMMAND ----------

SELECT *
FROM item_purchases
PIVOT (
  sum(item.quantity) FOR item_id IN (
    'P_FOAM_K',
    'M_STAN_Q',
    'P_FOAM_S',
    'M_PREM_Q',
    'M_STAN_F',
    'M_STAN_T',
    'M_PREM_K',
    'M_PREM_F',
    'M_STAN_K',
    'M_PREM_T',
    'P_DOWN_S',
    'P_DOWN_K')
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved. Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
