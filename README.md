# Cloud Dataplex Self-service labs

## Pre-requisites


- For Argolis Account
    1. Use "admin@" account 
    2. Create a new Argolis project for this lab 
    3. Make sure "admin@" user has the below privileges
        - Owner
        - ServiceAccountTokenCreator
        - Organization Admin 
        ![Admin Roles](/setup/resources/code_artifacts/imgs/admin_roles.png)
    4. Make sure you have enough of disk space(1.5 GB - 2 GB) in your gCloud shell for the terraform setup 

- For Non-Argolis Account 
    1.  Create a GCP Project 
        1.1. Create a new GCP project and follow the guidelines [here](https://cloud.google.com/dataplex/docs/best-practices#choose_project). 
    
        1.2. The project must belong to the same [VPC Service Control perimeter](https://cloud.google.com/vpc-service-controls/docs/service-perimeters) as the data destined to be in the lake. Refer to this link to use or [add Dataplex to VPC-SC](https://cloud.google.com/dataplex/docs/vpc-sc). 
         
    2. Make sure both data and Dataplex regions are available in one of the Dataplex [supported regions](https://cloud.google.com/dataplex/docs/locations?hl=en_US)
    3. Organization Policies: 
        The org policies should be set to below:

        - "compute.requireOsLogin" : false,
        - "compute.disableSerialPortLogging" : false,
        - "compute.requireShieldedVm" : false
        - "compute.vmCanIpForward" : true,
        - "compute.vmExternalIpAccess" : true,
        - "compute.restrictVpcPeering" : true
        - "compute.trustedImageProjects" : true,
        - "iam.disableCrossProjectServiceAccountUsage" :false #Only required when you want to set up in a separate project to your data project


    4. Enable [Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access#config-pga) on the network you plan to use with Dataplex Data Quality tasks. If you don't specify a network or sub-network when creating the Dataplex Data Quality task, Dataplex will use the default subnet, and you will need to enable Private Google Access for the default subnet.

    5. Make sure you have the appropriate Dataplex quotas 
        ```
        ## dataplex.googleapis.com/zones in region:us-central1 should be at least 20
        ## dataplex.googleapis.com/lakes in region:us-central1 should be at least 5

        ```
        You can view these settings at https://console.cloud.google.com/iam-admin/quotas and then enter the filters - Metric:dataplex.googleapis.com/zones OR Metric:dataplex.googleapis.com/lakes region:us-central1 
    6. Make sure you have enough of disk space(1.5 GB - 2 GB)  for the terraform setup 

## Setup

1. [![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor)

2. Select the appropriate project. Make sure you are in the right project before you proceed. 

3. Install the below python libraries 

    ```bash
    pip3 install google-cloud-storage
    pip3 install numpy 
    pip3 install faker_credit_score
    ```

4. Declare variable 
- In cloud shell, declare the following variables after substituting with yours. 
- For Argolis, use fully qualified corporate email address - ldap@fgoogle.com otherwise use your fully qualified email address (e.g. joe.user@gmail.com) as the USERNAME

    ```bash
    echo "export USERNAME=your-email" >> ~/.profile
    echo "export PROJECT_ID=$(gcloud config get-value project)" >> ~/.profile
    ```
    ![profile_validate](/setup/resources/code_artifacts/imgs/profile-validate.png)


5. To get the currently logged in email address, run: 'gcloud auth list as' below:

    ```bash 
    gcloud auth list
    Credentialed Accounts

    ACTIVE: *
    ACCOUNT: joe.user@jgmail.com or admin@(for Argolis)
    ```

6. Clone this repository in Cloud Shell
   ```bash 
   git clone https://github.com/mansim07/dataplex-labs.git
   ```

7. Trigger the terraform script to setup the infrastructure 

    ```bash 
    cd ~/dataplex-labs/setup/
    source ~/.profile
    bash deploy-helper.sh ${PROJECT_ID} ${USERNAME}
    ```
     The script will take about 30-40 minutes to finish.

8. Validate the Dataplex lakes and zones are created with the right number of asserts as shown below. Go to Dataplex -> Manage
 
    ![Dataplex Image](setup/resources/code_artifacts/imgs/Dataplex-ui.png)

9. Go to Composer… Then Environments…  Click on <your-project-id>-composer link..then click on 'Environment Variables'
    ![Composer Env](setup/resources/code_artifacts/imgs/Composer-env.png)


## Labs 

We have a series of labs designed to get hands-on-experience with Dataplex concepts. Please refer to each of the lab specific README for more information on the labs.

| Lab# | Lab Title | Description | link to readme |
| ------------- | ------------- | ------------- | ------------- |
| Lab 1  | Manage Data Security using Dataplex  | Managing Data Security is the main goal of this lab. You will learn how to design and manage security policies using Dataplex's UI and REST API as part of the lab. The purpose of the lab is to learn how to handle distributed data security more effectively across data domains| [ReadMe](https://github.com/mansim07/dataplex-labs/blob/main/lab1/README.md)  |
| Lab 2  | Standardize data using Dataplex built in task | You will discover how to leverage common Dataplex templates to curate raw data and translate it into standardized formats like parquet and Avro in the Data Curation lane. This demonstrates how domain teams may quickly process data in a serverless manner and begin consuming it for testing purposes.|[ReadMe](https://github.com/mansim07/dataplex-labs/tree/main/lab2)  |
| Lab 3  | Build Data Products | Serverless Dataplex tasks offer with open, simple APIs that make it easier to integrate them with already-existing Data pipelines, which makes them complementary in nature. In this lab, you will discover how to integrate Dataplex functionalities with your data product engineering pipeline.  We will use  [Configuration-driven Serverless Dataproc Templates](https://github.com/GoogleCloudPlatform/dataproc-templates) for incremental data using from GCS to BQ, incorporate a Dataplex's data quality task to verify the raw data and then transform data use for building data products. | [ReadMe](https://github.com/mansim07/dataplex-labs/blob/main/lab3/README.md)  |
| Lab 4 | Data Classification using DLP | You will use DLP Data Profiler in this lab so that it can automatically classify the BQ data, which will then be used by a Dataplex for building data classification tags. | [ReadMe](https://github.com/mansim07/dataplex-labs/tree/main/lab4) |
| Lab5 | Data Quality |  in this lab you will learn how to execute an end-to-end data quality process, including how to define **DQ rules**, assess and **analyze** DQ findings, build an dq analysis **dashboard**, manage DQ **incidents**, and finally publish DQ score **tags** to the catalog.  |[ReadMe](https://github.com/mansim07/dataplex-labs/tree/main/lab5#readme) |
| Lab 6(TBD) | Tag template and bulk tagging | In this lab, you will learn how to create business metadata tags on the Dataplex Data Product entity at scale across domains using custom utilities and Composer. |[ReadMe](https://github.com/mansim07/dataplex-labs/tree/main/lab6#readme) | 
| Lab 7(TBD) | Data catalog Search and Data Lineage| You will learn how to find data using the logical structure, perform advanced data discovery, provide additional(wiki-style) product overview and look at Data lineage | [ReadMe](https://github.com/mansim07/dataplex-labs/tree/main/lab7) | 


## [Optional] Post Work
Create HMS and attach it to the lake. Follow the instructions here
Create multiple personas/roles in Cloud Indentity and play around with the security policies
Become more creative and share ideas
Don't forget post-survey and feedback

## Clean up
Please make sure you clean up your environment

gcloud projects delete ${PROJECT_ID}