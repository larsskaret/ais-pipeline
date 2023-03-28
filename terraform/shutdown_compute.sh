export GOOGLE_CLOUD_PROJECT=`gcloud info --format="value(config.project)"`
terraform apply -var="project=${GOOGLE_CLOUD_PROJECT}" -var="compute_status=TERMINATED"