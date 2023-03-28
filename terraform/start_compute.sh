export GOOGLE_CLOUD_PROJECT=`gcloud info --format="value(config.project)"`
terraform apply -var="project=${GOOGLE_CLOUD_PROJECT}" -var="compute_status=RUNNING"
user=$(terraform output -raw user)
public_ip=$(terraform output -raw public_ip)
ssh -i .ssh/google_compute_engine ${user}@${public_ip}