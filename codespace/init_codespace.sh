#!/bin/bash
set -o allexport && source .env && set +o allexport

echo -e "\n"
echo -e "#####################################"
echo -e "# First, let us install the GCP SDK #"
echo -e "#####################################"
sleep 3

#GCP SDK installation
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg
sudo apt-get update && sudo apt-get install google-cloud-cli

#Intialize or login gcloud
cat << EOF
########################################
#                                      #
# Let's log in to gcloud               #
# PS. Paste in codespeace terminal is  #
# both cmd/ctrl+alt+v and cmd/ctrl+v   #
#                                      #
########################################\n
EOF

gcloud auth login

GCP_PROJECT_ID=${GCP_PROJECT_NAME}-${RANDOM}
       
while : ; do
    echo -e "[1] Create a new project (ID: ${GCP_PROJECT_ID})."
    echo -e "[2] Use an existing project. Will take you to GCP interactive mode (gcloud init)."
    echo -e "[q] Quit\n"
    read -r INPUT

    if [[ "${INPUT}" == "q" ]]
    then
        echo -e "Exit\n"
        break
    elif [[ "${INPUT}" == "1" ]]
    then
        echo -e "Project id: ${GCP_PROJECT_ID}"
        echo -e "Project name: ${GCP_PROJECT_NAME}\n"
        gcloud projects create "${GCP_PROJECT_ID}" --name="${GCP_PROJECT_NAME}" --verbosity=none --set-as-default
        if [ $? -eq 0 ] 
        then
            echo -e "Successfully created project\n" 
            break
        else 
            echo -e "Unsuccessfull\n"
        fi
    elif [[ "${INPUT}" == "2" ]]
    then
        gcloud init
        GCP_PROJECT_ID=$(gcloud config get project)
        echo -e "Current project is ${GCP_PROJECT_ID}"
    else
        echo -e "Try again.\n"
    fi
done

echo -e "Writing GCP_PROJECT_ID, GCP_PROJECT_NR and BILLING_ID to .env\n"
sleep 2

line=$(grep -n "GCP_PROJECT_ID=" .env | cut -d: -f1)
sed -i "${line}s/$/${GCP_PROJECT_ID}/" .env

BILLING_ID=$(gcloud beta billing accounts list | grep -Eo '.{6}-.{6}-.{6}')
line=$(grep -n "GCP_BILLING_ID=" .env | cut -d: -f1)
sed -i "${line}s/$/${BILLING_ID}/" .env

PROJECT_NR=$(gcloud projects list \
--filter="$(gcloud config get-value project)" \
--format="value(PROJECT_NUMBER)")
line=$(grep -n "GCP_PROJECT_NR=" .env | cut -d: -f1)
sed -i "${line}s/$/${PROJECT_NR}/" .env


echo Install Terraform
sleep 2
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

echo -e "Terraform module for setting up GCP project,"
echo -e "service accounts, credential keys and APIs.\n"
sleep 2

cd terraform_gcp_project
terraform init
terraform apply -var="project=${GCP_PROJECT_ID}" #-auto-approve

echo -e "Terraform module for setting up GCP project resources"
echo -e "such as compute instance, BigQuery and GCS.\n"
sleep 2

cd ../terraform_gcp_resources
terraform init
terraform apply -var="project=${GCP_PROJECT_ID}" #-auto-approve
