export PROJECT_ID=$(gcloud info --format='value(config.project)')
#---------------STEP 1----------------------------------------------------------
gsutil mb gs://$PROJECT_ID/

#create script file
echo '#!/bin/bash
apt-get update
apt-get install -y apache2' > resources-install-web.sh

#copy startup script to bucket
gsutil  cp resources-install-web.sh gs://$PROJECT_ID

#---------------STEP 2----------------------------------------------------------
gcloud compute instances create myinstance \
	--zone=us-central1-a \
	--tags=http \
	--metadata=startup-script-url=gs://$PROJECT_ID/resources-install-web.sh \
	--scopes=https://www.googleapis.com/auth/devstorage.read_only

#---------------STEP 3----------------------------------------------------------
#Create firewall rule that exposes the virtual machine
gcloud compute firewall-rules create default-allow-http \
	--direction=INGRESS \
	--priority=1000 \
	--network=default \
	--action=ALLOW \
	--rules=tcp:80 \
	--source-ranges=0.0.0.0/0 \
	--target-tags=http
