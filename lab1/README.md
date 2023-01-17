# Manage Data Security through Dataplex 

## Introduction

[Cloud Dataplex](https://cloud.google.com/dataplex/docs/lake-security) provides a single control plane for managing data security for distribued data. It translates and propagates  data roles to the underlying storage resource, setting the correct roles for each storage resource. The benefit is that you can grant a single Dataplex data role at the lake hierarchy (for example, a lake), and Dataplex maintains the specified access to data on all resources connected to that lake (for example, Cloud Storage buckets and BigQuery datasets are referred to by assets in the underlying zones). You can specify data roles at lake, zone and asset level. 

In this lab we will grant data roles to the service accounts created by terraform to own and manage the data. 

![Dataplex Security](/lab1/resources/imgs/dataplex-security-lab.png)

 ## Task 1: Manage security policies for Consumer Banking Customer Domain
In this lab task, we will apply the following IAM permissions lake "Consumer Banking - Customer Domain":
-  Sub Task 1: Lake Level security pushdown: 
We will grant the customer (user managed) service account (customer-sa@) auto-created by Terraform, the Dataplex Owner role for the "Cosumer Banking - Customer Domain" (lake)
-  Sub Task 2: Zone Level security pushdown:
We will grant the credit card transaction consumer (user managed) service account (cc-trans-consumer-sa@) Dataplex Data Reader role for the Customer Data Product Zone

### **Sub-Task 1: Make  customer-sa@ service account the data owner for consumer banking - customer domain**


- **Step1**: Pre-verify data access. Make sure your active account has the Service Account Token Creator role for impersonation. 

    - Open Cloud shell and execute the below command to list the tables in the "customer_raw_zone" dataset

        ```bash 

        export PROJECT_ID=$(gcloud config get-value project)

        curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com)" -H "Content-Type: application.json"  https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/customer_refined_data/tables?maxResults=10
        ```
        Sample output: 
        ![permission denied](/lab1/resources/imgs/permission-dnied.png)

- **Step2:** In Dataplex, let's grant the customer user managed service account, access to the “Consumer Banking - Customer Domain” (lake). For this we will use the Lakes Permission feature to apply policy. 

    1. Go to Dataplex in the Google Cloud console.
    2. On the left navigation bar, click on **Manage** menu under **Manage Lakes**.
    4. Click on the “Consumer Banking - Customer Domain” lake.
    5. Click on the "**PERMISSIONS**" tab.
    6.Click on **+GRANT ACCESS**
    8. Choose “customer-sa@<your-project-id>.iam.gserviceaccount.com” as principal
    9. Assign **Dataplex Data Owner** role.
    10. Click the Save button
    11. Verify Dataplex Data Owner roles appear under the permissions 


- **Step3** : Monitor the security policy propagation, you have various options to monitor the security access porpation centrally. Use any of the below methods:
    
    - **Method1:** Using Dataplex UI 

        - Go to Dataplex -> Manage sub menu -> Go to "Consumer Banking - Customer Domain" lake --> Click on "Customer Raw Zone" --> Click on the Customer Raw Data Asset
            ![Dataplex Verify Image](/lab1/resources/imgs/dataplex-security-status-ui.png)

            You can also look at the Asset Status section at the lake level. 

            ![dataplex security status lake](/lab1/resources/imgs/dataplex-security-status-lake.png)

    -  **Method2:** Using Dataplex APIs

        - Open Cloud Shell and execute the below command: 

            ```bash 
            curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://dataplex.googleapis.com/v1/projects/_project_datgov_/locations/us-central1/lakes/central-operations-domain/zones/operations-data-product-zone/assets/audit-data
            ```
            
            ![Dataplex Verify Image](/lab1/resources/imgs/dataplex-security-status-api.png)

    - **Method3:** Check the permissions of the underlying asset

        - Here is an example of the policy for underlying GCS bucket 

            ![Dataplex Verify Image](/lab1/resources/imgs/dataplex-security-status-underlying-assets.png)


- **Step4**: After the access policies has been propagated by Dataplex, rerun the commands in Step1 and verify the service account is able to access underlying data

    - Open Cloud shell and execute the below command which should now execute successfully. 

        ```bash 
        export PROJECT_ID=$(gcloud config get-value project)

        curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com)" -H "Content-Type: application.json"  https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/customer_raw_zone/tables?maxResults=10
        ```
        Sample Output:

        ![successful output](/lab1/resources/imgs/dataplex-security-result.png)


### **Sub Task 2: Grant the Credit card analytics consumer sa read access to the Customer Data product zone.**

- Using “Secure View” to provide the credit card analytics consumer domain access to the Customer Data Products. For this we will use the "Secure" functionality to the apply policy
    1. Go to Dataplex in the Google Cloud console.
    2. Navigate to the **Manage**->**Secure** on the left menu.
    3. Under the **RESOURCE-CENTRIC** tab, find and expand on your project
    4. Expand on the "Consumer Banking -  Customer Domain" lake
    5. Click on the "Customer Data Product Zone"
    6. Click on **+Grant Access**
    7. Choose "cc-trans-consumer-sa@<your-project-id>.iam.gserviceaccount.com as the principle
    8. Add the **Dataplex Data reader** roles
    9. Click on the Save button 
    10. Verify Dataplex Data Reader roles appear for the principal. Use one of the methods outlined in Step#3 above. 

## Task 2: Manage Security Policies for Central Operations domain(through Dataplex APIs)


- **Step1:** Provide Data writer access to all the domain service accounts((customer-sa@, cc-trans-consumer-sa@, cc-trans-sa@, merchant-sa@) to central managed dq reports. This will allow them to publish the data product dq results centrally. 
    - Open Cloud Shell and execute the below command 
        ```bash
        export PROJECT_ID=$(gcloud config get-value project)

        export central_dq_policy="{\"policy\":{
        \"bindings\": [
        {
            \"role\": \"roles/dataplex.dataOwner\",
            \"members\": [
            \"serviceAccount:cc-trans-consumer-sa@${PROJECT_ID}.iam.gserviceaccount.com\",
        \"serviceAccount:cc-trans-sa@${PROJECT_ID}.iam.gserviceaccount.com\",   \"serviceAccount:customer-sa@${PROJECT_ID}.iam.gserviceaccount.com\",    \"serviceAccount:merchant-sa@${PROJECT_ID}.iam.gserviceaccount.com\"
            ]
        }
        ]
        }
        }"

        echo $central_dq_policy

        curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://dataplex.googleapis.com/v1/projects/${PROJECT_ID}/locations/us-central1/lakes/central-operations-domain/zones/operations-data-product-zone/assets/dq-reports:setIamPolicy -d "${central_dq_policy}"
        ```
        Sample Output: 

        ![successful_policy](/lab1/resources/imgs/etag_successful.png)

- **Step2:**  Define and provide security policy to grant read access to all the domain service accounts(customer-sa@, cc-trans-consumer-sa@, cc-trans-sa@, merchant-sa@) to central managed common utilities housed in the gcs bucket e.g. libs, jars, log files etc. As you observe this has been applied at the zone-level.

    -  Open Cloud shell and execute the below commands: 

        ```bash 
        export PROJECT_ID=$(gcloud config get-value project)

        # 1. CREATE POLICY
        export central_common_util_policy="{\"policy\":{
        \"bindings\": [
        {
            \"role\": \"roles/dataplex.dataReader\",
            \"members\": [
            \"serviceAccount:cc-trans-consumer-sa@${PROJECT_ID}.iam.gserviceaccount.com\",
        \"serviceAccount:cc-trans-sa@${PROJECT_ID}.iam.gserviceaccount.com\",   \"serviceAccount:customer-sa@${PROJECT_ID}.iam.gserviceaccount.com\",    \"serviceAccount:merchant-sa@${PROJECT_ID}.iam.gserviceaccount.com\"
            ]
        }
        ]
        }
        }"

        echo " "
        # 2. VIEW POLICY
        echo "==========="
        echo "The policy we just created is "
        echo "==========="
        echo " "
        echo $central_common_util_policy


        echo " "
        # 3. APPLY POLICY
        echo "==========="
        curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://dataplex.googleapis.com/v1/projects/${PROJECT_ID}/locations/us-central1/lakes/central-operations-domain/zones/common-utilities:setIamPolicy -d "${central_common_util_policy}"
        echo " "
        echo "==========="
        ```

- **Step3:**  Cloud logging sink to capture the audit data which we can later query to run and visualize audit reports. Grant permissions to the Cloud Logging sink’s Google Managed Service Account for the Central Operations Domain lake->Data Product zone->Audit Data asset


    - **Step 3.1:**  Create the Cloud Logging sink to capture the Dataplex Audit logs into a BigQuery  table
        ```bash 
        export PROJECT_ID=$(gcloud config get-value project)
        gcloud logging --project=${PROJECT_ID} sinks create audits-to-bq bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/central_audit_data --log-filter='resource.type="audited_resource" AND resource.labels.service="dataplex.googleapis.com" AND protoPayload.serviceName="dataplex.googleapis.com"'
        ```

        Sample output of the author: 

        ```
        Created [https://logging.googleapis.com/v2/projects/mbdatagov-05/sinks/audits-to-bq].
        Please remember to grant `serviceAccount:p52065135315-549975@gcp-sa-logging.iam.gserviceaccount.com` the BigQuery Data Editor role on the dataset.
        More information about sinks can be found at https://cloud.google.com/logging/docs/export/configure_export
        ```
       Validate: Go to Cloud Logging -> Logs Router and you should see a sink called “audits-to-bq” as shown below

    - **Step 3.2:** Grant the Google Managed Cloud Logging Sink Service Account requisite permissions through Dataplex 
        - Open Cloud Shell execute the below command: 
            ```bash 
            export PROJECT_ID=$(gcloud config get-value project)

            LOGGING_GMSA=`gcloud logging sinks describe audits-to-bq | grep writerIdentity | grep serviceAccount | cut -d":" -f3`
            echo $LOGGING_GMSA

            curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://dataplex.googleapis.com/v1/projects/${PROJECT_ID}/locations/us-central1/lakes/central-operations-domain/zones/operations-data-product-zone/assets/audit-data:setIamPolicy -d "{\"policy\":{\"bindings\":[{\"role\":\"roles/dataplex.dataOwner\",\"members\":[\"serviceAccount:$LOGGING_GMSA\"]}]}}" 
            ```

**Step4:**  We will be using DLP for Data Classification in the later lab, here we will grant access service account access to the DLP datasets managed by central operations team. Grant permissions to the DLP Google Managed Service Account for the Central Operations Domain lake->Data Product zone->DLP Reports  asset 

- Open cloud shell and execute the below command
    ```bash 
    export PROJECT_ID=$(gcloud config get-value project)
    export PROJECT_NBR=$(gcloud projects list --filter="${PROJECT_ID}" --format="value(PROJECT_NUMBER)")
    echo $PROJECT_NBR

    curl --request POST \
  "https://dlp.googleapis.com/v2/projects/${PROJECT_ID}/locations/us-central1/content:inspect" \
  --header "X-Goog-User-Project: ${PROJECT_ID}" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{"item":{"value":"google@google.com"}}' \
  --compressed

    curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://dataplex.googleapis.com/v1/projects/${PROJECT_ID}/locations/us-central1/lakes/central-operations-domain/zones/operations-data-product-zone/assets/dlp-reports:setIamPolicy -d "{\"policy\":{\"bindings\":[{\"role\":\"roles/dataplex.dataOwner\",\"members\":[\"serviceAccount:service-${PROJECT_NBR}@dlp-api.iam.gserviceaccount.com\"]}]}}"
    ```

     Note: Sometime there may be upto 30 mins delay in security propagation. Verify the cloud logging is able to publish results and there are no permission issues. 


### Task 3: Execute the below script to grant all the other access 

- Execute the below command to automaically set the access for all the other domains - merchants, transaction and credit card consumer 

    ```bash 

    bash ~/dataplex-labs/lab1/apply-security-policies.sh

    ```

### Task 4: Go to BigQuery and perform analysis on the audit data to analyze and report 


 - Open BigQuery UI, change the processing location to us-central1 and execute the below query after replacing the ${PROJECT_ID}
    ```bash 
    SELECT protopayload_auditlog.methodName,   protopayload_auditlog.resourceName,  protopayload_auditlog.authenticationInfo.principalEmail,  protopayload_auditlog.requestJson, protopayload_auditlog.responseJson FROM `${PROJECT_ID}.central_audit_data.cloudaudit_googleapis_com_activity_*` LIMIT 1000
    ```

## Summary 
In this lab you have learned: 
1. the dfferent ways you can apply the security policies(terraform will be supported in future) 
    1.1 using Dataplex UI - both using the PERMISSIONS tab within Lakes, Zones and Assets and also using the "SECURE" tab under Manage
    1.2 using Dataplex API
2. how to route the Dataplex audit logs into BigQuery for further analysis and reporting  
3. using Dataplex you can simply data security policy using a single policy for both buckets and datasets 