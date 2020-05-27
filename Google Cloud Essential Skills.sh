export PROJECT_ID=$(gcloud info --format='value(config.project)')
gsutil mb gs://$PROJECT_ID/

#create script file
echo '#!/bin/bash
apt-get update
apt-get install -y apache2' > resources-install-web.sh

#copy startup script to bucket
gsutil cp resources-install-web.sh gs://$PROJECT_ID

#create virtual machine
gcloud compute instances create apache \
	--zone=us-central1-a \
	--tags=http-server \
	--machine-type=n1-standard-1 \
	--metadata=startup-script-url=gs://$PROJECT_ID/resources-install-web.sh

#Create firewall rule that exposes the virtual machine
gcloud compute firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server
