# Data Quality and Auto Tagging 

You will learn how to define and perform Data Quality jobs on customer data in the Data Quality lab, evaluate and understand the DQ findings, and construct a dashboard to assess and monitor DQ , creating tags

Dataplex provides the following two options to validate data quality:

1. Auto data quality (Public Preview) provides an automated experience for getting quality insights about your data. Auto data quality automates and simplifies quality definition with recommendations and UI-driven workflows. It standardizes on insights with built-in reports and drives actions through alerting and troubleshooting.

2. Dataplex data quality task (Generally Available) offers a highly customizable experience to manage your own rule repository and customize execution and results, using Dataplex for managed / serverless execution. Dataplex data quality task uses an open source component, CloudDQ, that can also open up choices for customers who want to enhance the code to their needs.

Today's lab will focus on using Dataplex data quality task(#2)

Data Quality 

Task1: Configure & execute Data Quality Task for Customer Domain Data Products 
Task2: Configure & execute Data Quality for Merchants Domain Data Products
Task3: Configure and execute Data Quality for Transaction Domain Data Products 


## Task1: Configure & Execute Data Quality task for Customer Domain Data Products

- **Step1**: Validate the entites are already discovered and registered in Dataplex 

    ![dataproduct-entities](/lab5/resources/imgs/customer-dp-entities.png)

- **Step2**: Define and review the Yaml file for customer_Data Data product

    As part of the lab we have already defined a yaml file and stored in the gcs bucket 

    - Open cloud shell and execute the below command to review the yaml file 

        ```bash
        export PROJECT_ID=$(gcloud config get-value project)

        gsutil cat gs://${PROJECT_ID}_dataplex_process/customer-source-configs/dq_customer_data_product.yaml
        ```

        Here we have performing 3 key DQ rules: 
        1. Valid Customer which checks Client_id is not null, not blank  and no duplicates 
        2. We verify the timeliness score by checking the ingestion date is not older than 1 day
        3. There is no duplicates in SSN and it's valid means it meets a certain regex pattern - " ^d{3}-?d{2}-?d{4}$" 

        You can learn more about Cloud DQ [here](https://github.com/GoogleCloudPlatform/cloud-data-quality). 


-  **Step3**: Execute the Data Quality task 
    - Open cloud shell and execute the below command. No Changes Needed. 
        ```bash 
        export PROJECT_ID=$(gcloud config get-value project)

        # Google Cloud region for the Dataplex lake.
        export REGION_ID="us-central1"

        # Public Cloud Storage bucket containing the prebuilt data quality executable artifact.
        # There is one bucket for each Google Cloud region.
        export PUBLIC_GCS_BUCKET_NAME="dataplex-clouddq-artifacts-${REGION_ID}"

        # Location of DQ YAML Specifications file
        export YAML_CONFIGS_GCS_PATH="gs://${PROJECT_ID}_dataplex_process/transactions-source-configs/dq_customer_data_product.yaml"

        # The Dataplex lake where your task is created.
        export LAKE_NAME="consumer-banking--customer--domain"

        # The BigQuery dataset where the final results of the data quality checks are stored.
        export TARGET_BQ_DATASET="central_dq_results"

        # The BigQuery table where the final results of the data quality checks are stored.
        export TARGET_BQ_TABLE="${PROJECT_ID}.central_dq_results.dq_results"

        # The unique identifier for the task.
        export TASK_ID="customer-data-product-dq"

        #DQ Service Account
        export SERVICE_ACCOUNT=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com

        gcloud dataplex tasks create \
        --location="${REGION_ID}" \
        --lake="${LAKE_NAME}" \
        --trigger-type=ON_DEMAND \
        --vpc-sub-network-name="default" \
        --execution-service-account="$SERVICE_ACCOUNT" \
        --spark-python-script-file="gs://${PUBLIC_GCS_BUCKET_NAME}/clouddq_pyspark_driver.py" \
        --spark-file-uris="gs://${PUBLIC_GCS_BUCKET_NAME}/clouddq-executable.zip","gs://${PUBLIC_GCS_BUCKET_NAME}/clouddq-executable.zip.hashsum","${YAML_CONFIGS_GCS_PATH}" \
        --execution-args=^::^TASK_ARGS="clouddq-executable.zip, ALL, ${YAML_CONFIGS_GCS_PATH}, --gcp_project_id=${PROJECT_ID}, --gcp_region_id='${REGION_ID}', --gcp_bq_dataset_id='${TARGET_BQ_DATASET}', --target_bigquery_summary_table='${TARGET_BQ_TABLE}'" \
        --summary_to_stdout \
        "$TASK_ID"
        ```
-  **Step4**: Monitor the data quality job
    - Go to Dataplex UI -> Process --> "Data Quality" Tab
    - You will find a DQ job running with name "customer-data-product-dq"
    - Once the job is successful, proceed to the next step

- **Step5**: Review the Data quality metrics 
    - Navigate to BigQuery->SQL Workspace and open the central_dq_results. Review the table and views created in this dataset. 
    - Click on the dq_results table to preview the data quality results. Check the rows which shows the data quality metrics for the rules defined in the yaml configuration file 

- **Step6**: Create a Data Quality Dashboard 
    - Copy the sample dashboard 
    Open a new normal browser window and paste the following link in the navigation bar 
    (This report is In the Pantheon instance)
    https://datastudio.google.com/c/u/0/reporting/faf194a4-6388-4df4-b566-99529a152f5c/page/x16FC
    - Click on the details link next to the 'Edit' button and make a copy of the dashboard
        ![dashboard UI ](/lab5/resources/imgs/dataplex-dashboard.png)

    - Leave the defaults as is and click the ‘Copy Report’ button.
        ![copy-report](/lab5/resources/imgs/copy-report.png)

    - Share Dashboard with your Argolis admin account 
        - Click the Share button in the top right corner to see the following display
        - Enter your Argolis admin email id,  select ‘Can edit’ and click the ‘Send’ button.
        - Click the ‘Share’ button again and choose the ‘Manage Access’ tab. Copy the URL link shown below.

        ![manage-access](/lab5/resources/imgs/manage-access.png)
    - Edit the dashboard. Switch to the lab instance and open it in incognitio browser window and paste the link copies above 
    - Change the title of the dashboard and select the Resource menu and choose Manage added data sources option.
    - Click the Edit button under Action 
    - Select the 'edit Connection' button 
    - Select Project: ${PROJECT_ID}
        Select Dataset: central_dq_results
        Select Table: dq_summary
        Click the ‘Reconnect’ button
    - Click the 'Apply' button 
    - Click the 'Done' button 
    - Click the ‘Close’ button and then click the ‘View’ button
    - View Dashboard. Change the date range if needed and select drill down parameters to refresh the Dashboard. 
    (Sample screenshot shown below)

        ![dq-dashboard](/lab5/resources/imgs/dq-dashboard.png)

- [OPTIONAL] **Step7**: Cloud Logging and Monitoring 
    By appending " --summary_to_stdout" flag to your data quality jobs, you can easily route the DQ summary logs to Cloud Logging. 
    You can use "Alerts" within cloud logging to alert based on dq failures. Alerts can be send through multiple notification channels like webhooks, emails, sms etc.
   The steps to accomplish this will be provided in the next phase. Sorry!

- **Step8**: Data Quality automated tagging job  
    Once we have the DQ results available, using a custom utility which will automatically calculate the dq scores and create the data product tags. We have pre-built the utility as a java library which we can now orchestrate using Dataplex's serverless spark task 
     - Open cloud shell ad execute the below command 
        ```bash 
        export PROJECT_ID=$(gcloud config get-value project)

        gcloud dataplex tasks create customer-dp-dq-tag \
        --project=${PROJECT_ID} \
        --location=us-central1 \
        --vpc-sub-network-name=projects/${PROJECT_ID}/regions/us-central1/subnetworks/default \
        --lake=prod-customer-source-domain \
        --trigger-type=ON_DEMAND \
        --execution-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com \
        --spark-main-class="com.google.cloud.dataplex.templates.dataquality.DataProductQuality" \
        --spark-file-uris="gs://${PROJECT_ID}_dataplex_process/customer-source-configs/data-product-quality-tag-auto.yaml" \
        --container-image-java-jars="gs://${PROJECT_ID}_dataplex_process/common/tagmanager-1.0-SNAPSHOT.jar" \
        --execution-args=^::^TASK_ARGS="--tag_template_id=projects/${PROJECT_ID}/locations/us-central1/tagTemplates/data_product_quality, --project_id=${PROJECT_ID},--location=us-central1,--lake_id=consumer-banking--customer--domain,--zone_id=customer-data-product-zone,--entity_id=customer_data,--input_file=data-product-quality-tag-auto.yaml"
        ```

   
    - Go to Dataplex -> Discover ->  type "tag:data_quality_information" into the search bar  
    - The customer data product should be tagged with the data quality information as show below:



## Task2: Configure & Execute Data Quality task for Merchant Domain Data Products
As you have already learned how to execute Data Quality, for this task we will leverage a pre-defined Composer DAG to automate and execute the above steps. 



- **Step1** : 

## Task2: Configure & Execute Data Quality task for Transaction Domain Data Products
As you have already learned how to execute Data Quality, for this task we will leverage a pre-defined Composer DAG to automate and execute the above steps. 

- **Step1** : 