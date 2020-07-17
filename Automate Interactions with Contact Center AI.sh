################################################################################
export PROJECT=$(gcloud info --format='value(config.project)')
# Task 1: Create a Cloud Storage Bucket for Audio Upload
gsutil mb -p ${PROJECT} -l  us-central1 gs://${PROJECT}-a
################################################################################
git clone https://github.com/GoogleCloudPlatform/dataflow-contact-center-speech-analysis.git

# Task 2: Create a Cloud Function
gcloud functions deploy safLongRunJobFunc \
  --region us-central1 \
  --trigger-resource gs://${PROJECT}-a \
  --trigger-event google.storage.object.finalize \
  --stage-bucket gs://${PROJECT}-a \
  --source dataflow-contact-center-speech-analysis/saf-longrun-job-func \
  --runtime nodejs10

################################################################################
# Task 3: Create a BigQuery Dataset
bq mk helpdesk
################################################################################
# Task 4: Create Cloud Pub/Sub Topic
gcloud pubsub topics create helpdesk
################################################################################
# Task 5: Create a Cloud Storage Bucket for Staging Contents
gsutil mb -p ${PROJECT} -l  us-central1 gs://${PROJECT}-t
mkdir DFaudio
touch DFaudio/test
gsutil cp -r DFaudio gs://${PROJECT}-t
################################################################################
# Task 6: Deploy a Cloud Dataflow Pipeline
python -m virtualenv env -p python3
source env/bin/activate
pip install apache-beam[gcp]
pip install dateparser
pip install Cython

cd dataflow-contact-center-speech-analysis/saf-longrun-job-dataflow/
export PROJECT=$(gcloud info --format='value(config.project)')
python3 saflongrunjobdataflow.py \
    --project ${PROJECT} \
    --runner DataflowRunner \
    --region us-central1 \
    --temp_location gs://${PROJECT}-t/tmp \
    --input_topic projects/${PROJECT}/topics/helpdesk \
    --output_bigquery ${PROJECT}:helpdesk.realtime \
    --requirements_file "requirements.txt"

gcloud dataflow jobs list --region=us-central1
################################################################################
# Task 7: Upload Sample Audio Files for Processing
# mono flac audio sample
gsutil -h x-goog-meta-callid:1234567 -h x-goog-meta-stereo:false -h x-goog-meta-pubsubtopicname:helpdesk -h x-goog-meta-year:2019 -h x-goog-meta-month:11 -h x-goog-meta-day:06 -h x-goog-meta-starttime:1116 cp gs://qwiklabs-bucket-gsp311/speech_commercial_mono.flac gs://${PROJECT}-a

# stereo wav audio sample
gsutil -h x-goog-meta-callid:1234567 -h x-goog-meta-stereo:true -h x-goog-meta-pubsubtopicname:helpdesk -h x-goog-meta-year:2019 -h x-goog-meta-month:11 -h x-goog-meta-day:06 -h x-goog-meta-starttime:1116 cp gs://qwiklabs-bucket-gsp311/speech_commercial_stereo.wav gs://${PROJECT}-a
################################################################################
# Task 8: Run a Data Loss Prevention Job

# See on my channel at youtube
