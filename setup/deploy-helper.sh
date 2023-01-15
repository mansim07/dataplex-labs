#!/bin/bash
#set -x
if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    echo "Usage: ./deploy_helper.sh <project-d> <ldap>"
    echo "Example: ./deploy_helper.sh my-datastore my-datagov jayoleary 123"
    exit 1
fi
GCP_PROJECT_ID=$1
GCP_LDAP=$2

echo "${GCP_PROJECT_ID}"
cd ~/dataplex-labs/setup/org_policy
gcloud config set project ${GCP_PROJECT_ID}
terraform init
terraform apply -auto-approve -var project_id=${GCP_PROJECT_ID} 
status=$?
[ $status -eq 0 ] && echo "command successful" || exit 1

rm terraform*

cd ~/dataplex-labs/setup/terraform
gcloud config set project ${GCP_PROJECT_ID}
terraform init
terraform apply -auto-approve -var project_id=${GCP_PROJECT_ID}
status=$?
[ $status -eq 0 ] && echo "command successful" || exit 1

#gcloud config set project ${GCP_PROJECT_ID}
#terraform init

#terraform apply -auto-approve -var project_id=${GCP_PROJECT_ID}  -var ldap=${GCP_LDAP} -var user_ip_range=10.6.0.0/24

#status=$?
#[ $status -eq 0 ] && echo "command successful" || exit 1
