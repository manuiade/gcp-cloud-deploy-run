#!/bin/bash

gcloud iam service-accounts create $TEST_SA_RUN
gcloud iam service-accounts create $PROD_SA_RUN
gcloud iam service-accounts create $CD_SA


# Create the artifact registry repo for the source code
gcloud artifacts repositories create $ACR \
    --repository-format=docker \
    --location=$REGION

# Create the staging bucket for Cloud Deploy
gsutil mb -l $REGION gs://$PROJECT_ID-cd-test 
gsutil mb -l $REGION gs://$PROJECT_ID-cd-prod


# IAM

gcloud artifacts repositories add-iam-policy-binding $ACR \
    --location $REGION \
    --member=serviceAccount:$TEST_SA_RUN@$PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/artifactregistry.reader

gcloud artifacts repositories add-iam-policy-binding $ACR \
    --location $REGION \
    --member=serviceAccount:$PROD_SA_RUN@$PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/artifactregistry.reader


gcloud artifacts repositories add-iam-policy-binding $ACR \
    --location $REGION \
    --member=serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/artifactregistry.writer

gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
    --member=serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com\
    --role=roles/logging.logWriter

gsutil iam ch serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com:objectViewer gs://$PROJECT_ID-cd-test 
gsutil iam ch serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com:objectCreator gs://$PROJECT_ID-cd-test 
gsutil iam ch serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com:objectViewer gs://$PROJECT_ID-cd-prod 
gsutil iam ch serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com:objectCreator gs://$PROJECT_ID-cd-prod 

gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
    --member=serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/run.developer

gcloud iam service-accounts add-iam-policy-binding $TEST_SA_RUN@$PROJECT_ID.iam.gserviceaccount.com \
    --member=serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser

gcloud iam service-accounts add-iam-policy-binding $PROD_SA_RUN@$PROJECT_ID.iam.gserviceaccount.com \
    --member=serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser

gcloud auth configure-docker $REGION-docker.pkg.dev


cd demo-app

skaffold build -f skaffold.yaml --interactive=false \
  --default-repo $REGION-docker.pkg.dev/$PROJECT_ID/$ACR/demo-app \
  --file-output artifacts.json

cd ..

# Create Pub/Sub notification topics
gcloud pubsub topics create clouddeploy-resources
gcloud pubsub topics create clouddeploy-operations
gcloud pubsub topics create clouddeploy-approvals
gcloud pubsub topics create clouddeploy-advances

gcloud functions deploy clouddeploy-resources \
    --region $REGION \
    --entry-point clouddeploy_resources \
    --runtime python310 \
    --source ./ggchat-notifications \
    --set-env-vars=GGCHAT_URL="$GGCHAT_URL" \
    --max-instances 5 \
    --min-instances 0 \
    --trigger-topic clouddeploy-resources 

gcloud functions deploy clouddeploy-operations \
    --region $REGION \
    --entry-point clouddeploy_operations \
    --runtime python310 \
    --source ./ggchat-notifications \
    --set-env-vars=GGCHAT_URL="$GGCHAT_URL" \
    --max-instances 5 \
    --min-instances 0 \
    --trigger-topic clouddeploy-operations

gcloud functions deploy clouddeploy-approvals \
    --region $REGION \
    --entry-point clouddeploy_approvals \
    --runtime python310 \
    --source ./ggchat-notifications \
    --set-env-vars=GGCHAT_URL="$GGCHAT_URL" \
    --max-instances 5 \
    --min-instances 0 \
    --trigger-topic clouddeploy-approvals

gcloud functions deploy clouddeploy-advances \
    --region $REGION \
    --entry-point clouddeploy_advances \
    --runtime python310 \
    --source ./ggchat-notifications \
    --set-env-vars=GGCHAT_URL="$GGCHAT_URL" \
    --max-instances 5 \
    --min-instances 0 \
    --trigger-topic clouddeploy-advances