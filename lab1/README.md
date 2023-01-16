# Manage Data Security through Dataplex 

## Introduction

[Cloud Dataplex](https://cloud.google.com/dataplex/docs/lake-security) provides a single control plane for managing data security for distribued data. It translates and propagates  data roles to the underlying storage resource, setting the correct roles for each storage resource. The benefit is that you can grant a single Dataplex data role at the lake hierarchy (for example, a lake), and Dataplex maintains the specified access to data on all resources connected to that lake (for example, Cloud Storage buckets and BigQuery datasets are referred to by assets in the underlying zones). You can specify data roles at lake, zone and asset level. 

In this lab we will grant data roles to the service accounts created by terraform to own and manage the data. 

![Dataplex Security](lab1/resources/imgs/dataplex-security-lab.png)


## Instructions 

### Task 1: Manage security policies for Customer Source Domain
In this lab task, we will apply the following IAM permissions lake "Customer Source Domain":
1. Lake Level security pushdown: 
We will grant the customer (user managed) service account (customer-sa@) auto-created by Terraform, the Dataplex Owner role for the "Customer Source Domain" (lake)
2. Zone Level security pushdown:
We will grant the credit card transaction consumer (user managed) service account (cc-trans-consumer-sa@) Dataplex Data Reader role for the Customer Data Product Zone

#### 1. Lake Level security pushdown

Step1: Pre-verify access. Make sure your active account has the Service Account Token Creator role for impersonization 

Open Cloud Shell and execute the below command. 

```bash 

export PROJECT_ID=$(gcloud config get-value project)

curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com)" -H "Content-Type: application.json"  https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/customer_raw_zon/tables?maxResults=10
```

The above commans will fail with authorization issue. Now let's look at how we can grant access through Dataplex.  

Step2: In Dataplex, let's grant the customer user managed service account, access to the “Consumer Banking - Customer Domain” (lake) 

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
11. Verify Dataplex Data Owner roles appear.

![Dataplex Verify Image](lab1/resources/imgs/dataplex-access-verify.png)

Step3: Monitor the security policy propagation, you have various options to monitor the security access porpation. Use any of the below methods

Method1: 

Step4: Verify access by rerunning the command in step#1 

```bash 
export PROJECT_ID=$(gcloud config get-value project)

curl -X GET -H "Authorization: Bearer $(gcloud auth print-access-token --impersonate-service-account=customer-sa@${PROJECT_ID}.iam.gserviceaccount.com)" -H "Content-Type: application.json"  https://bigquery.googleapis.com/bigquery/v2/projects/${PROJECT_ID}/datasets/customer_raw_zon/tables?maxResults=10
```

#### 2. Zone security pushdown


### Task 2: Grant Access to the Central Operations domain(through APIs)

2.1 Let's setup cloud logging to capture the audit logs

2.2. Grant access 


### Task 3: Execute the below script to grant all the other access 

```bash 

bash ~/dataplex-labs/lab1/apply-security-policies.sh

```

## Summary 
In this lab you have learned: 
1. How to use Dataplex to manage access control for distributed data
2. How to monitor, audit and troubleshoot the accesss policies  
3. How to apply them in Dataplex UI as well as through command-line.









