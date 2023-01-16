# Manage Data Security through Dataplex 

## Introduction





## Instructions 


## Task 1: Manage security policies for Customer Source Domain
In this lab task, we will apply the following IAM permissions in the Data Governance project, lake "Customer Source Domain":
1. Lake Level security pushdown: 
We will grant the customer (user managed) service account (customer-sa@) auto-created by Terraform, the Dataplex Owner role for the "Customer Source Domain" (lake)
2. Zone Level security pushdown:
We will grant the credit card transaction consumer (user managed) service account (cc-trans-consumer-sa@) Dataplex Data Reader role for the Customer Data Product Zone

Step1: Pre-verify access 

```bash 
curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com)" -H "Content-Type: application.json"  https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/customer_raw_zone/tables/customers_data/data?maxResults=10
```


Step2: In Dataplex, let's grant the customer user managed service account, access to the “Consumer Banking - Customer Domain” (lake) 

1. Go to Dataplex in the Google Cloud console.
2. On the left navigation bar, click on Manage Lakes view.
3. Click on the  Secure sub-menu item.
4. Click on the “Customer - Source” Domain lake.
5. Select the Data Permissions tab.
6. Click the View By Roles tab.
7. Click Add to add a new role. 
8. Choose “customer-sa@<your-project-id>.iam.gserviceaccount.com” as principal
9. Add the Dataplex Data Owner role.
10. Click the Save button
11. Verify Dataplex Data Owner roles appear.

 ![Dataplex Verify Image](/resources/imgs/dataplex-access-verify.png)

Step3: Monitor the security policy propagation, you have various options to monitor the security access porpation. Use any ofthe below methods


## Task 2: Grant Access to the Central Operations domain 

2.1 Let's setup cloud logging to capture the audit logs 





