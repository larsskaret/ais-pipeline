#!/bin/bash
echo -e "\n#####################################
# First, let us install the GCP SDK #
#####################################\n"
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
#gcloud init

PROJECT_ID=ais-project-$RANDOM
       
while : ; do
    echo -e "[1] Create a new project (ID: ${PROJECT_ID})."
    echo -e "[2] Use an existing project. Will take you to GCP interactive mode (gcloud init)."
    echo -e "[q] Quit\n"
    read -r INPUT

    if [[ "$INPUT" == "q" ]]
    then
        echo -e "Exit\n"
        break
    elif [[ "$INPUT" == "1" ]] 
    then
        echo -e "Project id: ${PROJECT_ID}"
        echo -e "Project name: ais-project\n"
        gcloud projects create $PROJECT_ID --name="ais-project" --verbosity=none --set-as-default
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
        PROJECT_ID=$(gcloud config get-value project)
        echo -e "Current project is ${PROJECT_ID}"
    else
        echo -e "Try again.\n"
    fi
done

#Create a json file Terraform can use
echo "Configuring a Terrafom service account with editor role."
echo "Create a terraform.json file for authentication."

gcloud iam service-accounts create terraform \
    --description="Terraform Service Account" \
    --display-name="terraform"


export GOOGLE_SERVICE_ACCOUNT=`gcloud iam service-accounts list --format="value(email)"  --filter=description:"Terraform Service Account"` 
export GOOGLE_CLOUD_PROJECT=`gcloud info --format="value(config.project)"`

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
    --member="serviceAccount:$GOOGLE_SERVICE_ACCOUNT" \
    --role="roles/editor" 

gcloud iam service-accounts keys create "../secrets/terraform.json"  \
  --iam-account=$GOOGLE_SERVICE_ACCOUNT 


echo "Activating API to allow terraform to actiate APIs..."
#Do we need all? Remove TODO
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable serviceusage.googleapis.com


echo Let us install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
#terraform -install-autocomplete #don't need this?

echo -e "Terraform will:"
echo -e "-Set up BigQuery, data lake bucket and a compute engine."
echo -e "-Run the installation and startup script compute_engine.sh"
echo -e "on the compute_engine."
echo -e "-Set up an ssh connection to the compute engine\n"
sleep 2
cd terraform
terraform init
terraform apply -var="project=${GOOGLE_CLOUD_PROJECT}" #-auto-approve
terraform output -raw

echo "Let us ssh into the compute instance, and then you can continue from there."

ssh -i .ssh/google_compute_engine ${user}@${public_ip}
#Alternative gcloud compute ssh ${MACHINE-NAME}
