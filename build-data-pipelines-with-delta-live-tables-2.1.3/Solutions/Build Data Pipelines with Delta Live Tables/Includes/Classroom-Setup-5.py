# Databricks notebook source
# MAGIC %run ./Classroom-Setup-Common

# COMMAND ----------

DA = DBAcademyHelper()
DA.init()

pipeline_language = None

# The location that the DLT databases should be written to
DA.paths.storage_location = f"{DA.paths.working_dir}/storage_location"

DA.dlt_data_factory = DataFactory() 
DA.dlt_data_factory.load()

# COMMAND ----------

# # Print the name of the catalog and pipeline name
@DBAcademyHelper.add_method
def print_event_query(self):
    list_of_pipelines = self.workspace.pipelines.list_pipelines()

    for pipeline in list_of_pipelines:
        if pipeline.name == self.generate_pipeline_name():
            print(f"CREATE OR REPLACE VIEW pipeline_event_log AS SELECT * FROM event_log('{pipeline.pipeline_id}');")
        else:
            print(f'Pipeline name:"{self.generate_pipeline_name()}" does not exist. Please create the pipeline to continue.')

# COMMAND ----------

# # Print the name of the catalog and pipeline name
# @DBAcademyHelper.add_method
# def print_event_query(self):
#     config = self.get_pipeline_config("Python")

#     pipeline_id = self.workspace_find(
#         'pipelines',
#         config.pipeline_name,
#         api='list_pipelines'
#     ).pipeline_id

#     print(f"""
# CREATE OR REPLACE VIEW pipeline_event_log AS
#   SELECT * FROM event_log("{pipeline_id}");
#   """)
