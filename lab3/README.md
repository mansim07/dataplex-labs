# Building Data products 

In this lab, you will learn how to build Data Products. The diagram below depicts the overall flow. 

![build-dp-flow](/lab3/resources/imgs/building-dp-flow.png)

1. We will use Open Source Spark-serverless based Dataproc Templates to move the data incrementally from GC(raw/curated buckets) to BigQuery(refined datasets)
2. We will use Dataplex DQ to validate the incoming data quality 
3. Use BQ SQL to transform the data and populate the final data products. We can also take necessary actions based on the DQ results(will be added to lab in future)
4. We will use Dataplex catalog to search for the data products based on technical metadata



## Task 1: Use Dataproc template to move the data from raw/curated zone to refine zone in BQ  

### **Sub Task 1: Move the Customer Data**

- **Step1**: Open cloud shell and run the below command 

    ```bash 
     export PROJECT_ID=$(gcloud config get-value project)

    gcloud dataplex tasks create cust-curated-refined \
        --project=${PROJECT_ID} \
        --location=us-central1 \
    --vpc-sub-network-name=projects/${PROJECT_ID}/regions/us-central1/subnetworks/default \
        --lake=consumer-banking--customer--domain \
        --trigger-type=ON_DEMAND \
        --execution-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com \
        --spark-main-class="com.google.cloud.dataproc.templates.main.DataProcTemplate" \
        --spark-file-uris="gs://${PROJECT_ID}_dataplex_process/common/log4j-spark-driver-template.properties" \
        --container-image-java-jars="gs://${PROJECT_ID}_dataplex_process/common/dataproc-templates-1.0-SNAPSHOT.jar" \
        --execution-args=^::^TASK_ARGS="--template=DATAPLEXGCSTOBQ,\
            --templateProperty=project.id=_project_datsto_,\
            --templateProperty=dataplex.gcs.bq.target.dataset=customer_refined_data,\
            --templateProperty=gcs.bigquery.temp.bucket.name=${PROJECT_ID}_dataplex_temp,\
            --templateProperty=dataplex.gcs.bq.save.mode=append,\
            --templateProperty=dataplex.gcs.bq.incremental.partition.copy=yes,\
            --dataplexEntity=projects/${PROJECT_ID}/locations/us-central1/lakes/consumer-banking--customer--domain/zones/customer-raw-zone/entities/customers_data,\
            --partitionField=ingest_date,\
            --partitionType=DAY,\
            --targetTableName=customers_data,\
            --customSqlGcsPath=gs://${PROJECT_ID}_dataplex_process/customer-source-configs/customercustom.sql"
    ```
 - **Step2**: Monitor the Job. It will take a few seconds to spin up, execute and complete 
    - Go to Dataplex process tab → Choose “Custom Spark” → Click on the name of your task → Click on the job-id (wait for a few seconds and refresh if the job_id URL is not active) → This will take you to Dataproc Batched tab where you can look at the Output for jobs logs and Details tab for input arguments 
     ![dataplex-task-output](/lab3/resources/imgs/dplx-task-output.png)

     One the status is “Successful” move on to next step
- **Step3**: Populate the Customer Credit Card Profile  data feed 
  - Open cloud shell 

    ```bash 
    export PROJECT_ID=$(gcloud config get-value project)
    
    gcloud dataplex tasks create cc-cust-curated-refined \
        --project=${PROJECT_ID} \
        --location=us-central1 \
        --vpc-sub-network-name=projects/${PROJECT_ID}/regions/us-central1/subnetworks/default \
        --lake=consumer-banking--customer--domain \
        --trigger-type=ON_DEMAND \
        --execution-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com \
        --spark-main-class="com.google.cloud.dataproc.templates.main.DataProcTemplate" \
        --spark-file-uris="gs://${PROJECT_ID}_dataplex_process/common/log4j-spark-driver-template.properties" \
        --container-image-java-jars="gs://${PROJECT_ID}_dataplex_process/common/dataproc-templates-1.0-SNAPSHOT.jar" \
        --execution-args=^::^TASK_ARGS="--template=DATAPLEXGCSTOBQ,\
            --templateProperty=project.id=_project_datsto_,\
            --templateProperty=dataplex.gcs.bq.target.dataset=customer_refined_data,\
            --templateProperty=gcs.bigquery.temp.bucket.name=${PROJECT_ID}_dataplex_temp,\
            --templateProperty=dataplex.gcs.bq.save.mode=append,\
            --templateProperty=dataplex.gcs.bq.incremental.partition.copy=yes,\
            --dataplexEntity=projects/${PROJECT_ID}/locations/us-central1/lakes/consumer-banking--customer--domain/zones/customer-raw-zone/entities/cc_customers_data,\
            --partitionField=ingest_date,\
            --partitionType=DAY,\
            --targetTableName=cc_customers_data,\
        --customSqlGcsPath=gs://${PROJECT_ID}_dataplex_process/customer-source-configs/customercustom.sql"

        ```

- **Step4**: Monitor the job using the instructions specified in step#2

- **Step5**: This is a critical validation 
    - Go to BigQuery UI.  Validate both the tables customer tables under the “customer_refined_data” is populated. 

        ![bq_results](/lab3/resources/imgs/bq_results.png)
### **Sub Task 2: Move the Merchant Data**

- **Step1**: Open gCloud shell and  execute the below commands

    ```bash 
    export PROJECT_ID=$(gcloud config get-value project)
    gcloud dataplex tasks create merchant-raw-to-refined \
        --project=${PROJECT_ID} \
        --location=us-central1 \
        --vpc-sub-network-name=projects/${PROJECT_ID}/regions/us-central1/subnetworks/default \
        --lake=consumer-banking--merchant--domain \
        --trigger-type=ON_DEMAND \
        --execution-service-account=merchant-sa@${PROJECT_ID}.iam.gserviceaccount.com \
        --spark-main-class="com.google.cloud.dataproc.templates.main.DataProcTemplate" \
        --spark-file-uris="gs://${PROJECT_ID}_dataplex_process/common/log4j-spark-driver-template.properties" \
        --container-image-java-jars="gs://${PROJECT_ID}_dataplex_process/common/dataproc-templates-1.0-SNAPSHOT.jar" \
        --execution-args=^::^TASK_ARGS="--template=DATAPLEXGCSTOBQ,\
            --templateProperty=project.id=_project_datsto_,\
            --templateProperty=dataplex.gcs.bq.target.dataset=merchants_refined_data,\
            --templateProperty=gcs.bigquery.temp.bucket.name=${PROJECT_ID}_dataplex_temp,\
            --templateProperty=dataplex.gcs.bq.save.mode=append,\
            --templateProperty=dataplex.gcs.bq.incremental.partition.copy=yes,\
            --dataplexEntity=projects/${PROJECT_ID}/locations/us-central1/lakes/consumer-banking--merchant--domain/zones/merchant-raw-zone/entities/merchants_data,\
            --partitionField=ingest_date,\
            --partitionType=DAY,\
            --targetTableName=merchants_data,\
            --customSqlGcsPath=gs://${PROJECT_ID}_dataplex_process/merchant-source-configs/merchantcustom.sql"
        ```
- **Step2**:  Monitor the job through the Dataplex UI and wait for it to complete 
- **Step3:**: Verify the  merchants_refined_data.merchants_data is populated in BQ 


### Sub Task 3: Move the Transaction Data

- **Step1**: Open gCloud shell and  execute the below commands

    ```bash 
    export PROJECT_ID=$(gcloud config get-value project)
    gcloud dataplex tasks create auth-raw-to-refined-10 \
        --project=${PROJECT_ID} \
        --location=us-central1 \
        --vpc-sub-network-name=projects/${PROJECT_ID}/regions/us-central1/subnetworks/default \
        --lake=consumer-banking--creditcards--transaction--domain \
        --trigger-type=ON_DEMAND \
        --execution-service-account=cc-trans-sa@${PROJECT_ID}.iam.gserviceaccount.com \
        --spark-main-class="com.google.cloud.dataproc.templates.main.DataProcTemplate" \
        --spark-file-uris="gs://${PROJECT_ID}_dataplex_process/common/log4j-spark-driver-template.properties" \
        --container-image-java-jars="gs://${PROJECT_ID}_dataplex_process/common/dataproc-templates-1.0-SNAPSHOT.jar" \
        --execution-args=^::^TASK_ARGS="--template=DATAPLEXGCSTOBQ,\
            --templateProperty=project.id=_project_datsto_,\
            --templateProperty=dataplex.gcs.bq.target.dataset=pos_auth_refined_data,\
            --templateProperty=gcs.bigquery.temp.bucket.name=${PROJECT_ID}_dataplex_temp,\
            --templateProperty=dataplex.gcs.bq.save.mode=append,\
            --templateProperty=dataplex.gcs.bq.incremental.partition.copy=yes,\
            --dataplexEntity=projects/${PROJECT_ID}/locations/us-central1/lakes/consumer-banking--creditcards--transaction--domain/zones/authorizations-raw-zone/entities/auth_data,\
            --partitionField=ingest_date,\
            --partitionType=DAY,\
            --targetTableName=auth_data,\
            --customSqlGcsPath=gs://${PROJECT_ID}_dataplex_process/transactions-source-configs/transcustom.sql"
        ```

- **Step2:** Monitor the job through the Dataplex UI and wait for it to complete 
- **Step3:** Verify the pos_auth_refined_data.auth_data is populated in BQ 


## Task 2: Use DataplexDQ+BQ+Composer to populate the Data Productss 


### **Sub Task 1: Create the Customer Data Product**
- **Step1:**: Go to Composer Service UI → You should see _project_datgov_-composer environment. Click on the Airflow UI.

    ![airflow UI](/lab3/resources/imgs/airflow-ui.png)

- **Step2**: Search for  “etl_with_dq_customer_data_product_wf”
- **Step3**: Trigger the DAG manually and monitor
    - You can go to Dataplex --> Process Tab --> Under the "Data Quality" Tab, you will find the DQ job that was triggered by the airflow job.  

- **Step4**: Validate all the 3 Customer Data Products are Populated in BigQuery DS customer_data_product

    ![bq_cust_results](/lab3/resources/imgs/bq_cust_results.png)


### **Sub Task 2: Create the Merchant Data products**

- **Step1**: Go to Airflow UI
- **Step2**: Click on the “etl_with_dq_merchant_data_product_wf”
- **Step 3**: Trigger DAG Manually and Monitor
- **Step 4**: Validate _project_datsto_.merchants_data_product.core_merchants is populated in BQ

### **Sub Task 3: Create the Auth Data products (gcloud)**

- **Step1:** Go to Airflow UI 
- **Step2:** Click on the “etl_with_dq_transactions_data_product_wf”
- **Step 3:** Trigger DAG Manually and Monitor
- **Step 4:** Validate _project_datsto_.auth_data_product.auth_table is populated in BigQuery  


## Summary
In this lab you learned how Dataplex provides serverless data management tasks that easily integrate and complement organizations existing Data Engineering pipleines through simple and open APIs.  