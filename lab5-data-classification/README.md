# Data Classification using DLP 

You will use DLP Data Profiler in this lab so that it can automatically classify the BQ data, which will then be used by a Dataplex  to provide business tags/annotations.

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