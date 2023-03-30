export GOOGLE_CLOUD_PROJECT=`gcloud info --format="value(config.project)"`
terraform apply -var="project=${GCP_PROJECT_ID}" -var="compute_status=TERMINATED"