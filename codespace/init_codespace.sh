#!/bin/bash
set -o allexport && source .env && set +o allexport
mkdir ../compute_engine/.secrets
mkdir .secrets


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
# Note! You have to log in twice, for  #
# two different functionalities.       # 
#                                      #
########################################

EOF



#gcloud auth application-default login

cat << EOF

################
#              #
# Second login # 
#              #
################

EOF


#gcloud auth login

GCP_PROJECT_ID=${GCP_PROJECT_NAME}-${RANDOM}
 
echo -e "Writing GCP_PROJECT_ID and BILLING_ID to .env\n"
echo -e "Assumes there is only one billing account!"
sleep 2

line=$(grep -n "GCP_PROJECT_ID=" .env | cut -d: -f1)
sed -i "${line}s/$/${GCP_PROJECT_ID}/" .env

BILLING_ID=$(gcloud beta billing accounts list | grep -Eo '.{6}-.{6}-.{6}')
line=$(grep -n "GCP_BILLING_ID=" .env | cut -d: -f1)
sed -i "${line}s/$/${BILLING_ID}/" .env

#PROJECT_NR=$(gcloud projects list \
#--filter="$(gcloud config get-value project)" \
#--format="value(PROJECT_NUMBER)")
#line=$(grep -n "GCP_PROJECT_NR=" .env | cut -d: -f1)
#sed -i "${line}s/$/${PROJECT_NR}/" .env

cat << EOF

#############################
#                           #
# Let's create ssh key pair #
#                           #
#############################

EOF

mkdir .ssh
ssh-keygen -t rsa -f ./${GCP_SSH_KEY_LOCATION} -C ${GCP_COMPUTE_USERNAME} -b 2048

chmod 600 ./${GCP_SSH_KEY_LOCATION}
chmod 600 ./${GCP_SSH_KEY_LOCATION}.pub

set -o allexport && source .env && set +o allexport

echo Install Terraform
sleep 2
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform



cat << EOF

################################################
#                                              #
# Terraform module for setting up GCP project, #
# service accounts, credential keys and APIs.  #
#                                              #
################################################

EOF
sleep 2
cp .env ../compute_engine/.env

cd terraform_gcp_project
terraform init
terraform apply #-auto-approve

cat << EOF

#########################################################
#                                                       #
# Terraform module for setting up GCP project resources #
# such as compute instance, BigQuery and GCS.           #
#                                                       #
#########################################################

EOF
sleep 2

cd ../terraform_gcp_resources
terraform init
terraform apply #-auto-approve

cd ..
set -o allexport && source .env && set +o allexport
