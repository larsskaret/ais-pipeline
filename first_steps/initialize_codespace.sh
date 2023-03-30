#!/bin/bash
set -o allexport && source .env && set +o allexport

echo -e "\n"
echo -e "#####################################"
echo -e "# First, let us install the GCP SDK #
echo -e "#####################################\n"
sleep 3

#GCP SDK installation
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg
sudo apt-get update && sudo apt-get install google-cloud-cli

#Intialize or login gcloud
echo -e """
########################################
#                                      #
# Let's log in to gcloud               #
# PS. Paste in codespeace terminal is  #
# both cmd/ctrl+alt+v and ctrl+v       #
#                                      #
########################################\n"""

gcloud auth login --no-launch-browser

GCP_PROJECT_ID=$GCP_PROJECT_NAME-$RANDOM
       
while : ; do
    echo -e "[1] Create a new project (ID: ${GCP_PROJECT_ID})."
    echo -e "[2] Use an existing project. Will take you to GCP interactive mode (gcloud init)."
    echo -e "[q] Quit\n"
    read -r INPUT

    if [[ "$INPUT" == "q" ]]
    then
        echo -e "Exit\n"
        break
    elif [[ "$INPUT" == "1" ]] 
    then
        echo -e "Project id: ${GCP_PROJECT_ID}"
        echo -e "Project name: ${GCP_PROJECT_NAME}\n"
        gcloud projects create $GCP_PROJECT_ID --name="$GCP_PROJECT_NAME" --verbosity=none --set-as-default
        if [ $? -eq 0 ] 
        then
            echo -e "Successfully created project\n" 
            break
        else 
            echo -e "Unsuccessfull\n"
        fi
    elif [[ "$INPUT" == "2" ]] 
    then
        gcloud init
        GCP_PROJECT_ID=$(gcloud config get project)
        echo -e "Current project is ${GCP_PROJECT_ID}"
    else
        echo -e "Try again.\n"
    fi
done

line=$(grep -n "GCP_PROJECT_ID=" ../env | cut -d: -f1)
sed -i "${line}s/$/${GCP_PROJECT_ID}/" ../env

#Create a json file Prefect can use
echo "Configuring a Prefect service account with these roles:"
echo "Create a gcp_prefect.json file for authentication."
sleep 2

gcloud iam service-accounts create prefect \
    --description="Prefect Service Account" \
    --display-name="$GCP_PREFECT_SERVICE_ACCOUNT_NAME"

GCP_PREFECT_SERVICE_ACCOUNT_EMAIL=`gcloud iam service-accounts list --format="value(email)"  --filter=description:"Prefect Service Account"` 

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:$GCP_PREFECT_SERVICE_ACCOUNT_EMAIL" \
    --role="roles/viewer"
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:$GCP_PREFECT_SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin"
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:$GCP_PREFECT_SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.objectAdmin"
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:$GCP_PREFECT_SERVICE_ACCOUNT_EMAIL" \
    --role="roles/bigquery.admin"

gcloud iam service-accounts keys create ../$GCP_PREFECT_JSON_LOCATION  \
  --iam-account=$GCP_PREFECT_SERVICE_ACCOUNT_EMAIL

#Create a json file Terraform can use
echo "Configuring a Terrafom service account with editor role."
echo "Create a gcp_terraform.json file for authentication."
sleep 2

gcloud iam service-accounts create terraform \
    --description="Terraform Service Account" \
    --display-name="$GCP_TERRAFORM_SERVICE_ACCOUNT_NAME"

GCP_TERRAFORM_SERVICE_ACCOUNT_EMAIL=`gcloud iam service-accounts list --format="value(email)"  --filter=description:"Terraform Service Account"` 

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:$GCP_TERRAFORM_SERVICE_ACCOUNT_EMAIL" \
    --role="roles/editor" 

gcloud iam service-accounts keys create ../$GCP_TERRAFORM_JSON_LOCATION  \
  --iam-account=$GCP_TERRAFORM_SERVICE_ACCOUNT 

echo Activate billing for the project
sleep 2
BILL=$(gcloud beta billing accounts list | grep -Eo '.{6}-.{6}-.{6}')
gcloud billing projects link $GCP_PROJECT_ID --billing-account $BILL


echo "Activating API to allow terraform to actiate APIs..."
sleep 2
#Do we need all? Remove TODO
gcloud services enable cloudresourcemanager.googleapis.com
#TODO how long to wait before becomes active?
#gcloud services enable cloudbilling.googleapis.com
#gcloud services enable iam.googleapis.com
#gcloud services enable serviceusage.googleapis.com


echo Install Terraform
sleep 2
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

echo -e "Terraform will:"
echo -e "-Set up BigQuery, data lake bucket and a compute engine."
echo -e "-Set up an ssh connection to the compute engine"
echo -e "with a permament extarnal IP-address\n"
sleep 2

cd terraform
terraform init
terraform apply -var="project=${GCP_PROJECT_ID}" #-auto-approve?

PUBLIC_IP=$(terraform output -raw public_ip)
line=$(grep -n "GCP_COMPUTE_IP=" ../env | cut -d: -f1)
sed -i "${line}s/$/${PUBLIC_IP}/" ../env

set -o allexport && source .env && set +o allexport

echo "Let us ssh into the compute instance, and then you can continue from there."
echo "Use this command:"
echo -e "ssh -i .ssh/google_compute_engine ${GCP_COMPUTE_USERNAME}@${GCP_COMPUTE_IP}"
#Alternative gcloud compute ssh ${MACHINE-NAME}
