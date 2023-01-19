#  Tag template and bulk tagging
You will learn how to create bulk tags on the Dataplex Data Product entity across domains using Composer in this lab after the Data Products have been created as part of the above lab. You will learn how to find data using the logical structure and business annotations of Dataplex in this lab. Lineage is not enabled as part of the Lab at the moment, but hopefully we can in the future. You will use a [custom metadata tag library](https://github.com/mansim07/datamesh-templates/tree/main/metadata-tagmanager) to create 4 predefined tag templates - Data Classification, Data Quality, Data Exchange and Data product info(Onwership)
We have already explored the Data Quality tagging in the previous lab. 



## Task#1: Prevalidation before proceeding with tagging 

- **Step1**: If you have just run your previous lab i.e. Building your Data Product Lab, make sure the entities are visible in Dataplex before proceeding with the below steps.

    In order to verify Go to Dataplex  → Manage tab → Click on Customer - Source Domain Lake → Click on Customer Data Product Zone

    ![entities](/lab6/resources/imgs/entities_screnshot.png)

    Do this for all the other domain data product zones as well. 

- **Step2**: Make sure tag templates are created in ${PROJECT_ID}  created. Go to Dataplex → Manage Catalog → Tag templates. You should see the below 4 Tag Templates. Open each one and look the schema: 
     ![tagtemplates](/lab6/resources/imgs/tag_templates.png)

- **Step3**: Make sure Data is populated by the DLP job profiler into ${PROJECT_ID}.central_dlp_data dataset. If the data has not been populated the data classification tags will fail. 
    ```bash 
    export PROJECT_ID=$(gcloud config get-value project)

    bq query --use_legacy_sql=false \
    "SELECT
    COUNT(*)
    FROM
    ${PROJECT_ID}.central_dlp_data.dlp_data_profiles"
    ```


## Task#2: Author and build a custom tag for a Customer Data Product 

- **Step1**: Open Cloud Shell and create a new file called “customer-tag.yaml” and copy and paste the below yaml into a file.

    ```bash 
    cd ~
    vim customer-tag.yaml
    ``` 
    Enter the below text 
    ```
    data_product_id: derived
    data_product_name: ""
    data_product_type: ""
    data_product_description: ""
    data_product_icon: ""
    data_product_category: ""
    data_product_geo_region: ""
    data_product_owner: ""
    data_product_documentation: ""
    domain: derived
    domain_owner: ""
    domain_type: ""
    last_modified_by: ""
    last_modify_date: ""
    ```

    **Make sure you always leave the last_modified_by and last _moddify date blank**

- **Step2**: Upload the file to the temp gcs bucket

    ```bash 
    gsutil cp ~/customer-tag.yaml gs://${PROJECT_ID}_dataplex_temp/
    ```

-  **Step3**: Run the below command to create the tag for customer_data product entity 

    ```bash 
    gcloud dataplex tasks create customer-tag-job \
        --project=${PROJECT_ID} \
        --location=us-central1 \
        --vpc-sub-network-name=projects/${PROJECT_ID}/regions/us-central1/subnetworks/default \
        --lake='consumer-banking--customer--domain' \
        --trigger-type=ON_DEMAND \
        --execution-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com \
        --spark-main-class="com.google.cloud.dataplex.templates.dataproductinformation.DataProductInfo" \
        --spark-file-uris="gs://${PROJECT_ID}_dataplex_temp/customer-tag.yaml" \
        --container-image-java-jars="gs://${PROJECT_ID}_dataplex_process/common/tagmanager-1.0-SNAPSHOT.jar" \
        --execution-args=^::^TASK_ARGS="--tag_template_id=projects/${PROJECT_ID}/locations/us-central1/tagTemplates/data_product_information, --project_id=${PROJECT_ID},--location=us-central1,--lake_id=consumer-banking--customer--domain,--zone_id=customer-data-product-zone,--entity_id=customer_data,--input_file=customer-tag.yaml"

    ```

- **Step4**: Go to Dataplex UI → Process → Custom Spark tab → Monitor the job → you will find a job named “customer-tag-job”

- **Step5**: Once job is successful, Go to Dataplex Search Tab and type this into the search bar - tag:data_product_information
    ![tag-search](/lab6/resources/imgs/tag-search.png)
- **Step6**: Click on customer_data -> Go to the Tags section and make sure the data product information is created.

    ![dp_info_tag](/lab6/resources/imgs/dp_info_tag.png)

    As you can see the automation utilities was able to derive most of the information. But at times, certain values may needs to be overriden. 

- **Step7** Now let's update the input file 

    ```bash 
    cd ~
    vim customer-tag.yaml
    ```

    Enter the below text
    ```
    data_product_id: derived
    data_product_name: ""
    data_product_type: ""
    data_product_description: "Adding Custom Description as part of demo"
    data_product_icon: ""
    data_product_category: ""
    data_product_geo_region: ""
    data_product_owner: "alexandra.gill@boma.com"
    data_product_documentation: ""
    domain: derived
    domain_owner: "rebecca.piper@boma.com"
    domain_type: ""
    last_modified_by: ""
    last_modify_date: ""
    ```

- **Step8**: upload the updated file to the temp gcs bucket 

    ```
    gsutil cp ~/customer-tag.yaml gs://${PROJECT_ID}_dataplex_temp
    ```

- **Step9**: Trigger another tagging job 

    ```bash 
    gcloud dataplex tasks create customer-tag-job-2 \
        --project=${PROJECT_ID} \
        --location=us-central1 \
        --vpc-sub-network-name=projects/${PROJECT_ID}/regions/us-central1/subnetworks/default \
        --lake='consumer-banking--customer--domain' \
        --trigger-type=ON_DEMAND \
        --execution-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com \
        --spark-main-class="com.google.cloud.dataplex.templates.dataproductinformation.DataProductInfo" \
        --spark-file-uris="gs://${PROJECT_ID}_dataplex_temp/customer-tag.yaml" \
        --container-image-java-jars="gs://${PROJECT_ID}_dataplex_process/common/tagmanager-1.0-SNAPSHOT.jar" \
        --execution-args=^::^TASK_ARGS="--tag_template_id=projects/${PROJECT_ID}/locations/us-central1/tagTemplates/data_product_information, --project_id=${PROJECT_ID},--location=us-central1,--lake_id=consumer-banking--customer--domain,--zone_id=customer-data-product-zone,--entity_id=customer_data,--input_file=customer-tag.yaml"
    ```

- **Step10**:  Go to Dataplex UI → Process → Custom Spark tab → Monitor the job -> Wait till it completes. You will find a job with name “customer-tag-job-2” 

- **Step11**:  Go to Dataplex-> search tab -> Refresh the tag and see if the updates has been propagated Once the job is successful 


## Task#3: Create bulk DQ tags for Customer Data Product Domain. All the three customer data products
Above we learned how to create and update the tags manually, now let’s see how we can use composer to automate the tagging process end-to-end. Now you can easily add tagging jobs as a downstream dependy to your data pipeline 

**We have limitation on Spark Serverless capacity(8 vCore)  by default so makes sure you trigger the tags sequentially to avoid failures due  resource crunch**

- **Step1**: Go to **Composer** → Go to **Airflow UI** → Click on DAGs 
- **Step2**: Click on DAGs and search for or go to **“data_governance_customer_dp_info_tag”** DAG and click on it 
- **Step3**: Trigger the DAG Manually by clicking on the Run button
- **Step4**: Monitor and wait for the jobs to complete. You can also go to Dataplex UI to monitor the jobs 
- **Step5**: Trigger the **“master_dag_customer_dq”**  and wait for its completion. This first runs a data quality job and then publishes the data quality score tag. 
- **Step6**: Trigger the **“data_governance_customer_exchange_tag”** dag and wait for its completion 
- **Step7**: Trigger the  **“data_governance_customer_classification_tag”** and wait for its completion 	


## Task 4: Create bulk tags for Merchants Domain

- **Step1**: Follow the same steps you used above for triggering the below set of DAGs: and wait for its completion. Execute the below DAGs in airflow 
    - **master_dag_merchant_dq**
    - **data_governance_merchant_classification_tag**
    - **data_governance_merchant_dp_info_tag**
    - **data_governance_merchant_exchange_tag**


## Task 5: [OPTIONAL] Create bulk tags for Transactions Domain
This task is optional and finish this task only if you have time left for your lab. 

- **Step1**: Follow the same steps you used above for triggering the below set of DAGs: and wait for its completion. Execute the below DAGs in airflow
    - **data_governance_transactions_classification_tag**
    - **data_governance_transactions_dp_info_tag**
    - **data_governance_transactions_exchange_tag**
    - **data_governance_transactions_quality_tag**


 
 


