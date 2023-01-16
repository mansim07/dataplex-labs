# Manage Data Security through Dataplex 

## Introduction

[Cloud Dataplex](https://cloud.google.com/dataplex/docs/lake-security) provides a single control plane for managing data security for distribued data. It translates and propagates  data roles to the underlying storage resource, setting the correct roles for each storage resource. The benefit is that you can grant a single Dataplex data role at the lake hierarchy (for example, a lake), and Dataplex maintains the specified access to data on all resources connected to that lake (for example, Cloud Storage buckets and BigQuery datasets are referred to by assets in the underlying zones). You can specify data roles at lake, zone and asset level. 

In this lab we will grant data roles to the service accounts created by terraform to own and manage the data. 

![Dataplex Security](/lab1/resources/imgs/dataplex-security-lab.png)

 ## Task 1: Manage security policies for Consumer Banking Customer Domain
In this lab task, we will apply the following IAM permissions lake "Consumer Banking - Customer Domain":
- Lake Level security pushdown: 
We will grant the customer (user managed) service account (customer-sa@) auto-created by Terraform, the Dataplex Owner role for the "Customer Source Domain" (lake)
-  Zone Level security pushdown:
We will grant the credit card transaction consumer (user managed) service account (cc-trans-consumer-sa@) Dataplex Data Reader role for the Customer Data Product Zone

**Sub-Task 1: Make  customer-sa@ service account the Data Owner for consumer banking - customer domain**

**Step1**: Pre-verify data access. Make sure your active account has the Service Account Token Creator role for impersonization. 

Open Cloud Shell and execute the below command to list the tables in the "customer_raw_zone" dataset and list the objects in the customer raw zone bucket. Both  above commands will fail with authorization issue. 


```bash 

export PROJECT_ID=$(gcloud config get-value project)

curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com)" -H "Content-Type: application.json"  https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/customer_raw_zone/tables?maxResults=10

curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com)" -H "Content-Type: application.json"  https://storage.googleapis.com/storage/v1/b/${PROJECT_ID}_customers_raw_data/o

```


**Step2:** In Dataplex, let's grant the customer user managed service account, access to the “Consumer Banking - Customer Domain” (lake) 

1. Go to Dataplex in the Google Cloud console.
2. On the left navigation bar, click on Manage Lakes view.
3. Click on the  Secure sub-menu item.
4. Click on the “Consumer Banking - Customer Domain”  lake.
5. Select the Data Permissions tab.
6. Click the View By Roles tab.
7. Click Add to add a new role. 
8. Choose “customer-sa@<your-project-id>.iam.gserviceaccount.com” as principal
9. Add the Dataplex Data Owner role.
10. Click the Save button
11. Verify Dataplex Data Owner roles appear as shown below

    ![Dataplex Verify Image](../lab1/resources/imgs/dataplex-access-verify.png)

**Step3** : Monitor the security policy propagation, you have various options to monitor the security access porpation centrally  Use any of the below methods

**Method1:** Using Dataplex UI 

- Go to Dataplex -> Manage sub menu -> Go to "Consumer Banking - Customer Domain" lake --> Click on "Customer Raw Zone" --> Click on the Customer Raw Data Asset
    ![Dataplex Verify Image](/lab1/resources/imgs/dataplex-security-status-ui.png)

**Method2:** Using Dataplex APIs

- Open Cloud Shell and execute the below command: 
    ```bash 
    curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://dataplex.googleapis.com/v1/projects/_project_datgov_/locations/us-central1/lakes/central-operations-domain/zones/operations-data-product-zone/assets/audit-data
    ```
  ![Dataplex Verify Image](/lab1/resources/imgs/dataplex-security-status-api.png)

**Method3:** Check the underlying asset permission

   - ![Dataplex Verify Image](/lab1/resources/imgs/dataplex-security-status-underlying-assets.png)




**Step4**: After the access policies has been propagated by Dataplex, rerun the commands in Step1 and verify the service account is able to access underlying data

- Open Cloud shell and execute the below command which should now execute successfully. 
    ```bash 
    export PROJECT_ID=$(gcloud config get-value project)

    curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com)" -H "Content-Type: application.json"  https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/customer_raw_zone/tables?maxResults=10

    curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com)" -H "Content-Type: application.json"  https://storage.googleapis.com/storage/v1/b/${PROJECT_ID}_customers_raw_data/o

    ```

Now both the commands should execute successfully. 


**Sub Task 2: Zone security pushdown**

Using “Secure View” to provide the credit card analytics consumer domain access to the Customer Data Products 
1. Go to Dataplex in the Google Cloud console.
2. Navigate to the Manage->Secure View.
3. Open the project
4. Expand Consumer Banking -  Customer Domain lake 
5. Click on the "Customer Data Product Zone"
6. Click Add to add a new role 
7. Choose "cc-trans-consumer-sa@<your-project-id>.iam.gserviceaccount.com as the principle
8. Add the Dataplex Data reader roles
9. Click on the Save button 
10. Verify Dataplex Data Reader roles appear for the principal. 

## Task 2: Grant Access to the Central Operations domain(through APIs)
In this lab task we will -
- (Lake->Zone->)Asset Level Security Pushdown: 
Grant all the 4 user managed security accounts/domain service accounts (customer-sa@, cc-trans-consumer-sa@, cc-trans-sa@, merchant-sa@) Dataplex Data Owner role to the Central Operations Domain lake->Data Product zone->DQ Reports asset, specifically
-  (Lake->)Zone Level Security Pushdown:
Grant all the 4 user managed security accounts (customer-sa@, cc-trans-consumer-sa@, cc-trans-sa@, merchant-sa@) Dataplex Data Reader role to the Central Operations Domain lake->Common Utilities zone
-  Create a Cloud Logging Sink for audit data
-  Grant permissions to the Cloud Logging sink’s Google Managed Service Account for the Central Operations Domain lake->Data Product zone->Audit Data asset
-  Grant permissions to the DLP Google Managed Service Account for the Central Operations Domain lake->Data Product zone->DLP Reports  asset


**Step1:** Provide editor access to all the domain service accounts to central managed dq reports. This will allow them to publish the data product dq results centrally.   

```bash 
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

**Step2:**  Define and provide security policy to grant read access to all the domain service accounts to central managed common utilities housed in the gcs bucket e.g. libs, jars, log files etc. As you observe this has been applied at the zone-level.

```bash 
# 1. CREATE POLICY
export central_common_util_policy="{\"policy\":{
\"bindings\": [
   {
     \"role\": \"roles/dataplex.dataReader\",
     \"members\": [
       \"serviceAccount:cc-trans-consumer-sa@${PROJECT_ID}.iam.gserviceaccount.com\",
\"serviceAccount:cc-trans-sa@${PROJECT_ID}.iam.gserviceaccount.com\",   \"serviceAccount:customer-sa@${PROJECT_DATAGOV}.iam.gserviceaccount.com\",    \"serviceAccount:merchant-sa@${PROJECT_DATAGOV}.iam.gserviceaccount.com\"
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

Step4: Create a Cloud logging sink to capture the audit data which we can later query to run and visualize audit reports 
Run the below command

Step 4.1: gcloud logging --project=${PROJECT_DATAGOV} sinks create audits-to-bq bigquery.googleapis.com/projects/${PROJECT_DATAGOV}/datasets/central_audit_data --log-filter='resource.type="audited_resource" AND resource.labels.service="dataplex.googleapis.com" AND protoPayload.serviceName="dataplex.googleapis.com"'


Sample output of the author: 
Created [https://logging.googleapis.com/v2/projects/mbdatagov-05/sinks/audits-to-bq].
Please remember to grant `serviceAccount:p52065135315-549975@gcp-sa-logging.iam.gserviceaccount.com` the BigQuery Data Editor role on the dataset.
More information about sinks can be found at https://cloud.google.com/logging/docs/export/configure_export

Step 4.2. Capture the auto-created Google Managed Cloud Logging Sink Service Account

LOGGING_GMSA=`gcloud logging sinks describe audits-to-bq | grep writerIdentity | grep serviceAccount | cut -d":" -f3`
echo $LOGGING_GMSA

Validate: Go to Cloud Logging -> Logs Router and you should see a sink called “audits-to-bq” as shown below

Step 4.3: Grant the Google Managed Cloud Logging Sink Service Account requisite permissions

curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://dataplex.googleapis.com/v1/projects/${PROJECT_DATAGOV}/locations/us-central1/lakes/central-operations-domain/zones/operations-data-product-zone/assets/audit-data:setIamPolicy -d "{\"policy\":{\"bindings\":[{\"role\":\"roles/dataplex.dataOwner\",\"members\":[\"serviceAccount:$LOGGING_GMSA\"]}]}}" 


Step 5: Run the below commands to grant the above DLP service account access to the DLP datasets 
export PROJECT_NBR=$(gcloud projects list --filter="${PROJECT_DATASTO}" --format="value(PROJECT_NUMBER)")
echo $PROJECT_NBR


curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://dataplex.googleapis.com/v1/projects/${PROJECT_DATAGOV}/locations/us-central1/lakes/central-operations-domain/zones/operations-data-product-zone/assets/dlp-reports:setIamPolicy -d "{\"policy\":{\"bindings\":[{\"role\":\"roles/dataplex.dataOwner\",\"members\":[\"serviceAccount:service-${PROJECT_NBR}@dlp-api.iam.gserviceaccount.com\"]}]}}"

Sample output of the author:

Review the permissions in the Dataplex UI:

### Task 3: Execute the below script to grant all the other access 

```bash 

bash ~/dataplex-labs/lab1/apply-security-policies.sh

```

## Summary 
In this lab you have learned: 
1. How to use Dataplex to manage access control for distributed data
2. How to monitor, audit and troubleshoot the accesss policies  
3. How to apply them in Dataplex UI as well as through command-line.









