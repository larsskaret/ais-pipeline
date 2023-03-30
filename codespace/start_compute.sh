#export GOOGLE_CLOUD_PROJECT=`gcloud info --format="value(config.project)"`
terraform apply -var="project=${GCP_PROJECT_ID}" -var="compute_status=RUNNING" #-auto-approve

#user=$(terraform output -raw user)
#public_ip=$(terraform output -raw public_ip)

#sleep 2

#ssh -i .ssh/google_compute_engine ${user}@${public_ip}