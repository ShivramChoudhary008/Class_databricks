-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC <div style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://databricks.com/wp-content/uploads/2018/03/db-academy-rgb-1200px.png" alt="Databricks Learning">
-- MAGIC </div>
-- MAGIC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Cleaning Data
-- MAGIC
-- MAGIC As we inspect and clean our data, we'll need to construct various column expressions and queries to express transformations to apply on our dataset.
-- MAGIC
-- MAGIC Column expressions are constructed from existing columns, operators, and built-in functions. They can be used in **`SELECT`** statements to express transformations that create new columns.
-- MAGIC
-- MAGIC Many standard SQL query commands (e.g. **`DISTINCT`**, **`WHERE`**, **`GROUP BY`**, etc.) are available in Spark SQL to express transformations.
-- MAGIC
-- MAGIC In this notebook, we'll review a few concepts that might differ from other systems you're used to, as well as calling out a few useful functions for common operations.
-- MAGIC
-- MAGIC We'll pay special attention to behaviors around **`NULL`** values, as well as formatting strings and datetime fields.
-- MAGIC
-- MAGIC ## Learning Objectives
-- MAGIC By the end of this lesson, you should be able to:
-- MAGIC - Summarize datasets and describe null behaviors
-- MAGIC - Retrieve and remove duplicates
-- MAGIC - Validate datasets for expected counts, missing values, and duplicate records
-- MAGIC - Apply common transformations to clean and transform data

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

-- MAGIC %run ./Includes/Classroom-Setup-4

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Data Overview
-- MAGIC
-- MAGIC We'll work with new users records from the **`users_bronze`** table, which has the following schema:
-- MAGIC
-- MAGIC | field | type | description |
-- MAGIC |---|---|---|
-- MAGIC | user_id | string | unique identifier |
-- MAGIC | user_first_touch_timestamp | long | time at which the user record was created in microseconds since epoch |
-- MAGIC | email | string | most recent email address provided by the user to complete an action |
-- MAGIC | updated | timestamp | time at which this record was last updated |
-- MAGIC
-- MAGIC Let's start by creating a `users_silver` table, based on the `users_bronze` table. This allows us to keep the `users_bronze` table in its raw, original form so we have it if we need it. Thus, the `users_silver` table will be the clean version of our users data. To create the `users_silver` table we will create an intermediary table named `users_silver_working` and process the data. Then insert into `users_silver`.
-- MAGIC
-- MAGIC We are going to add a handful of extra columns that will store additional items we feel are important for analysts to work with:
-- MAGIC * `first_touch` TIMESTAMP,
-- MAGIC * `first_touch_date` DATE,
-- MAGIC * `first_touch_time` STRING,
-- MAGIC * `email_domain` STRING

-- COMMAND ----------

-- Create the users_silver_working table
DROP TABLE IF EXISTS users_silver_working;

CREATE OR REPLACE TABLE users_silver_working AS
SELECT * FROM users_bronze;

-- Display the table
SELECT * 
FROM users_silver_working LIMIT 10;

-- COMMAND ----------

-- Create the users_silver table structure to insert the clean data into from the users_silver_working
DROP TABLE IF EXISTS users_silver;

CREATE TABLE IF NOT EXISTS users_silver 
  (user_id STRING, 
  user_first_touch_timestamp BIGINT, 
  email STRING, 
  updated TIMESTAMP, 
  first_touch TIMESTAMP,
  first_touch_date DATE,
  first_touch_time STRING,
  email_domain STRING
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Data Profile 
-- MAGIC
-- MAGIC Databricks offers two convenient methods for data profiling within Notebooks: through the cell output UI and via the dbutils library.
-- MAGIC
-- MAGIC When working with data frames or the results of SQL queries in a Databricks Notebook, users have the option to access a dedicated **Data Profile** tab. Clicking on this tab initiates the creation of an extensive data profile, providing not only summary statistics but also histograms that cover the entire dataset, ensuring a comprehensive view of the data, rather than just what is visible.
-- MAGIC
-- MAGIC This data profile encompasses a range of insights, including information about numeric, string, and date columns, making it a powerful tool for data exploration and understanding.
-- MAGIC
-- MAGIC **Using cell output UI:**
-- MAGIC
-- MAGIC 1. In the upper-left corner of the cell output of our query above, you will see the word **Table**. Click the "+" symbol immediately to the right of this, and select **Data Profile**.
-- MAGIC
-- MAGIC 1. Databricks will automatically execute a new command to generate a data profile.
-- MAGIC
-- MAGIC 1. The generated data profile will provide summary statistics for numeric, string, and date columns, along with histograms of value distributions for each column.
-- MAGIC
-- MAGIC **NOTE:** The Data Profile does not work on Serverless.

-- COMMAND ----------

SELECT * 
FROM users_silver_working

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ## Missing Data
-- MAGIC
-- MAGIC Based on the counts above, it looks like there are at least a handful of null values in all of our fields. Null values behave incorrectly in some math functions, including **`count()`**.
-- MAGIC
-- MAGIC But more importantly, we may have problems with null values in our user_id column. From the count of all the rows in the table, found at the bottom of the Table results, and the count of the `user_id` column in the Data Profile, we can see that there are three rows with null values for `user_id`. Let's query these rows.

-- COMMAND ----------

SELECT * 
FROM users_silver_working 
WHERE user_id IS NULL;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Since all three rows are obvious errors, let's remove them.

-- COMMAND ----------

-- Remove nulls
CREATE OR REPLACE TABLE users_silver_working AS
SELECT * 
FROM users_silver_working 
WHERE user_id IS NOT NULL;

-- Confirm get 'No rows returned' when query for null values in 'user_id' rows
SELECT * 
FROM users_silver_working 
WHERE user_id IS NULL;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC  
-- MAGIC ## Deduplicate Rows
-- MAGIC We can use **`DISTINCT *`** to remove true duplicate records where entire rows contain the same values.
-- MAGIC
-- MAGIC After running the cell below, note that there were no true duplicates.

-- COMMAND ----------

INSERT OVERWRITE users_silver_working 
  SELECT DISTINCT(*) 
  FROM users_silver_working;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Deduplicate Rows Based on Specific Columns
-- MAGIC
-- MAGIC The code below uses **`GROUP BY`** to remove duplicate records based on **`user_id`** and **`user_first_touch_timestamp`** column values. (Recall that these fields are both generated when a given user is first encountered, thus forming unique tuples.)
-- MAGIC
-- MAGIC Here, we are using the aggregate function **`max`** as a hack to:
-- MAGIC - Keep values from the **`email`** and **`updated`** columns in the result of our group by
-- MAGIC - Capture non-null emails when multiple records are present

-- COMMAND ----------

INSERT OVERWRITE users_silver_working
SELECT 
  user_id, 
  user_first_touch_timestamp, 
  max(email) AS email, 
  max(updated) AS updated 
FROM users_silver_working
WHERE user_id IS NOT NULL
GROUP BY user_id, user_first_touch_timestamp;



SELECT count(*) 
FROM users_silver_working;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ## Validate Datasets
-- MAGIC Let's programmatically perform validation using simple filters and **`WHERE`** clauses.
-- MAGIC
-- MAGIC Validate that the **`user_id`** for each row is unique.
-- MAGIC
-- MAGIC We expect that there will only be one of each `user_id` in our `users_silver_working` table. By grouping by the `user_id`, and counting the number of rows in each group, we can determine if there is more than one `user_id` by running a comparison in the **`SELECT`** clause. We, therefore, expect a Boolean value as our result set: true if there is only one of each `user_id` and false if there is more than one.

-- COMMAND ----------

SELECT max(row_count) = 1 AS no_duplicate_user_ids 
FROM (
  SELECT user_id, count(*) AS row_count
  FROM users_silver_working
  GROUP BY user_id
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Confirm that each email is associated with at most one **`user_id`**.
-- MAGIC
-- MAGIC We perform the same action as above, but this time, we are checking the `email` field. Again, we get a Boolean in return.

-- COMMAND ----------

SELECT max(user_id_count) = 1 AS one_user_id_per_email 
FROM (
  SELECT email, count(user_id) AS user_id_count
  FROM users_silver_working
  WHERE email IS NOT NULL
  GROUP BY email
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Date Format and Regex
-- MAGIC Now that we've removed null fields and eliminated duplicates, we may wish to extract further value out of the data.
-- MAGIC
-- MAGIC Currently, the **`user_first_touch_timestamp`** is formatted as a Unix timestamp (the number of microseconds since January 1, 1970). We want to convert this to a Spark timestamp in `YYYY-MM-DDThh.mm.sssss` format.
-- MAGIC
-- MAGIC The code below:
-- MAGIC - Correctly scales and casts the **`user_first_touch_timestamp`** to a timestamp
-- MAGIC - Extracts the calendar date and clock time for this timestamp in human readable format
-- MAGIC - Uses **`regexp_extract`** to extract the domains from the email column using regex
-- MAGIC
-- MAGIC We have a number of different [date formats](https://spark.apache.org/docs/latest/sql-ref-datetime-pattern.html) to choose from.
-- MAGIC
-- MAGIC Note also in line 6 that we are using a regular expression (regex). In this regex string, we are using a "positive look behind" to return all characters after the "@" symbol. You can [learn more about Java regular expressions](https://www.w3schools.com/java/java_regex.asp).

-- COMMAND ----------

SELECT *
FROM users_silver_working
LIMIT 5;

-- COMMAND ----------

INSERT INTO users_silver
(SELECT 
  user_id,
  user_first_touch_timestamp,
  email,
  updated,
  first_touch,
  to_date(date_format(first_touch, "yyyy-MM-dd")) AS first_touch_date,
  date_format(first_touch, "HH:mm:ss") AS first_touch_time,
  regexp_extract(email, "@(.*)", 0) AS email_domain
FROM (
  SELECT user_id,
    user_first_touch_timestamp,
    CAST(user_first_touch_timestamp / 1e6 AS timestamp) AS first_touch,
    email,
    updated
  FROM users_silver_working
));

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Run the cell below to see the cleaned data in the `users_silver` table.

-- COMMAND ----------

SELECT * EXCEPT (updated, first_touch) 
FROM users_silver 
LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Bonus lab
-- MAGIC
-- MAGIC #### Rewrite Cell 22 to retrieve 'email_domain' values without the '@' sign.  
-- MAGIC #### Then run Cell 24 to confirm it worked. Note: Add a WHERE clause to find domain names without leading '%'.
-- MAGIC #### For example, want 'smith.com' instead of '@smith.com'.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC &copy; 2025 Databricks, Inc. All rights reserved. Apache, Apache Spark, Spark, the Spark Logo, Apache Iceberg, Iceberg, and the Apache Iceberg logo are trademarks of the <a href="https://www.apache.org/">Apache Software Foundation</a>.<br/>
-- MAGIC <br/><a href="https://databricks.com/privacy-policy">Privacy Policy</a> | 
-- MAGIC <a href="https://databricks.com/terms-of-use">Terms of Use</a> | 
-- MAGIC <a href="https://help.databricks.com/">Support</a>
