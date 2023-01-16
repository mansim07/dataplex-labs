# Cloud Dataplex Self-service labs

## Pre-requisites

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
    - "iam.disableCrossProjectServiceAccountUsage" :false #Only required when you want to setup in a seperate project to your data project 


4. Enable [Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access#config-pga) on the network you plan to use with Dataplex Data Quality tasks. If you don't specify a network or sub-network when creating the Dataplex Data Quality task, Dataplex will use the default subnet, and you will need to enable Private Google Access for the default subnet.

5. Make sure you have the appropriate Dataplex quotas 
    ```
     ## dataplex.googleapis.com/zones in region:us-central1 should be at least 20
     ## dataplex.googleapis.com/lakes in region:us-central1 should be at least 5

    ```
 You can view these settings at https://console.cloud.google.com/iam-admin/quotas and then enter the filters - Metric:dataplex.googleapis.com/zones OR Metric:dataplex.googleapis.com/lakes region:us-central1 


## Setup

1. [![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor)
2. Select the appropriate project 

3. Install the below python libraries 

    ```bash
    pip3 install google-cloud-storage
    pip3 install numpy 
    pip3 install faker_credit_score
    ```

4. Declare variable 
In cloud shell, declare the following variables after substituting with yours.

    ```bash
    echo "export USERNAME=your-email" >> ~/.profile
    echo "export PROJECT_ID=$(gcloud config get-value project)" >> ~/.profile
    ```

You should use your fully qualified email address (e.g. joe.user@gmail.com)
For Argolis, use fully qualified corporate email address

5. To get the currently logged in email address, run: 'gcloud auth list as' below:

    ```bash 
    gcloud auth list
    Credentialed Accounts

    ACTIVE: *
    ACCOUNT: joe.user@jgmail.com
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
    The scrirpt will take about 30-40  minutes to finish.

8. Validate the Dataplex lakes and zones are created with the right number of asserts. Go to Dataplex -> Manage
 
    ![Dataplex Image](/demo_artifacts/imgs/Dataplex-ui.png)

9. Go to Composer… Then Environments…  Click on <your-project-id>-composer link..then click on 'Environment Variables'
    ![Composer Env](/demo_artifacts/imgs/Composer-env.png)


## Labs 

We have a series of labs designed to get hands-on-experience with Dataplex concepts. Please refer to each of the lab specific README for more information on the labs

| Lab# | Lab Title | Description | link to readme |
| ------------- | ------------- | ------------- | ------------- |
| Lab 1  | Dataplex Logical Organization Exploration | In this lab you will explore the Dataplex lakes and zones and understand how the assets has been organized | ReadMe  |
| Lab 2  | Manage Data Security using Dataplex  | ReadMe  |
| Lab 3  | Standardize data using Dataplex built in task | ReadMe  |
| Lab 4  | Move data from GCS to BigQuery using Open-source Dataproc Templates   | ReadMe  |
| Lab 5  | Transform data to built Data Products  | ReadMe  |
| Lab 6 | Tag the ownership info on the Data Products | ReadMe |
| Lab 7 | Data Quality and Tagging| ReadMe |
| Lab 8 |  Data Classification and Tagging  | ReadMe | 
| Lab 9 | Data catalog Search | ReadMe | 


## [Optional] Post Work
Create HMS and attach it to the lake. Follow the instructions here
Create multiple personas/roles in CLoud Indentity and play around with the security policies
Become more creative and share ideas
Don't forget post-survey and feedback

## Clean up
Please make sure you clean up your environment

#Remove lien if any
gcloud alpha resource-manager liens list --project ${PROJECT_ID}
gcloud projects delete ${PROJECT_ID}


## Errors 

1. │ Error: googleapi: Error 400: You can't create a Composer environment due to Organization Policy constraints in the selected project.
│ Policy constraints/compute.vmExternalIpAccess must allow all values when creating Public IP Cloud Composer environments., failedPrecondition