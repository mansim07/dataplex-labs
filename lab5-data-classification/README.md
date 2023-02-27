# Data Classification using DLP 

## 1. About
You will use DLP Data Profiler in this lab so that it can automatically classify the BQ data, which will then be used by a Dataplex  to provide business tags/annotations.

### 1.1. Prerequisites
Lab2-data-security successfully completed.

### 1.2. Duration
~40 mins

### 1.3 Concepts
None

### 1.4. Scope of this lab

In this lab,  will focus on building Data products for all the source and consumer oriented domains. 
1. We will use Open Source Spark-serverless based Dataproc Templates to move the data incrementally from GC(raw/curated buckets) to BigQuery(refined datasets)
2. We will use Dataplex DQ to validate the incoming data quality 
3. Use BQ SQL to transform the data and populate the final data products. We can also take necessary actions based on the DQ results(will be added to lab in future)
4. We will use Dataplex catalog to search for the data products based on technical metadata
5. We will use Composer to orchestrate the workflows for Merchants, Credit card analytics and transactions domains.  

### 1.5. Note
None

### 1.6. Documentation
None

## Lab Instructions 

Follow the below instructions to setup the DLP Auto profiler job. 

- **Step1**: Add IAM permissions for DLP Service Account 

    Open Cloud Shell and run the below command: 

    ```bash
     export PROJECT_ID=$(gcloud config get-value project)

     export project_num=$(gcloud projects list --filter="${PROJECT_ID}" --format="value(PROJECT_NUMBER)")

    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:service-${project_num}@dlp-api.iam.gserviceaccount.com" --role="roles/dlp.admin"
    ```
- **Step2**: Go to "Data Loss Prevention" service under Security
- **Step3**: Click on "SCAN CONFIGURATIONS" tab 
- **Step4**: Click on +CREATE CONFIGURATION 
- **Step5**: For **select resource to scan** select **Scan the entire project**
- **Step6**: Click Continue 
- **Step7**: Under Manage Schedules (Optional)
    - Click on Edit Schedule, Choose “Reprofile daily” for both When Schema Changes and When Table Changes
    ![dlp options](/lab5-data-classification/resources/imgs/dlp_options.png)
    - Click “Done” and hit continue
- **Step8**: Under Select inspection template
    - Choose “Select existing inspection template” and provide this value 
    
        **template name**: projects/${PROJECT_ID}/inspectTemplates/marsbank_dlp_template

        **location**: global
    then click "Continue"
- **Step9**: Under “Add Actions”
    - Choose Save data profile copies to BigQuery and provide these values
		Project id: ${PROJECT_ID}
		Dataset id: central_dlp_data
		Table id: dlp_data_profiles

       ![dlp_bq_specs](/lab5-data-classification/resources/imgs/dlp_bq_profile.png)
    - Click continue

- **Step10**: Under Set location to store configuration
    **Resource location**: Iowa (us-central1)
   Click continue

- **Step11**: Leave "Review and Create" at default and click Create
- **Step12**: Make sure configuration has been successfully created 

     ![scan config](/lab5-data-classification/resources/imgs/dlp_scan_configuration.png)
- **Step13** After a few minutes check to make sure the data profile is available in the "DATA PROFILE" tab, choose the Iowa region and the central_dlp_table dataset has been poupulated in Bigquery. Meanwhile feel free to move to the next lab. 

   ![dlp profile](/lab5-data-classification/resources/imgs/dlp_profile.png)

In a later lab, we will use these results to annotate the Data products with the Data classification info. 

Note: Individual DLP jobs can also be triggered to automatically publish the Classification Data to Dataplex. 