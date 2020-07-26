################################################################################
################################################################################
# Task 2: Create production VPC using Deployment Manager

gsutil cp -r gs://cloud-training/gsp321/dm .

# Update file

gcloud deployment-manager deployments create griffin-dev-vpc \
    --config dm/prod-network.yaml

################################################################################
################################################################################
# Task 4: Create and configure Cloud SQL Instance

CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO "wp_user"@"%" IDENTIFIED BY "stormwind_rules";
FLUSH PRIVILEGES;

################################################################################
################################################################################
# Task 6: Prepare the Kubernetes cluster

gsutil cp -r gs://cloud-training/gsp321/wp-k8s .

# Update files

gcloud iam service-accounts keys create key.json \
    --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
kubectl create secret generic cloudsql-instance-credentials \
    --from-file key.json

kubectl create -f wp-k8s/wp-env.yaml
kubectl create -f wp-k8s/wp-deployment.yaml
kubectl create -f wp-k8s/wp-service.yaml

################################################################################
