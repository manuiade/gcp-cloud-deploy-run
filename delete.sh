#!/bin/bash

gcloud run services delete demo-app-test --region $REGION --quiet
gcloud run services delete demo-app-prod --region $REGION --quiet

gcloud functions delete clouddeploy-advances --region $REGION --quiet

gcloud functions delete clouddeploy-approvals --region $REGION --quiet

gcloud functions delete clouddeploy-operations --region $REGION --quiet

gcloud functions delete clouddeploy-resources --region $REGION --quiet

gcloud pubsub topics delete clouddeploy-advances  --quiet

gcloud pubsub topics delete clouddeploy-approvals --quiet

gcloud pubsub topics delete clouddeploy-operations --quiet

gcloud pubsub topics delete clouddeploy-resources --quiet

sed -i "s/$TEST_SA_RUN/TEST_SA_RUN/g" demo-app/demo-app/kubernetes/overlays/test/target.yaml
sed -i "s/$PROJECT_ID/PROJECT_ID/g" demo-app/demo-app/kubernetes/overlays/test/target.yaml

sed -i "s/$PROD_SA_RUN/PROD_SA_RUN/g" demo-app/demo-app/kubernetes/overlays/prod/target.yaml
sed -i "s/$PROJECT_ID/PROJECT_ID/g" demo-app/demo-app/kubernetes/overlays/prod/target.yaml

rm demo-app/artifacts.json

gcloud deploy delivery-pipelines delete $CD_AUTO \
    --force \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet

gcloud projects remove-iam-policy-binding ${PROJECT_NUMBER} \
    --member=serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/run.developer

gcloud projects remove-iam-policy-binding ${PROJECT_NUMBER} \
    --member=serviceAccount:$CD_SA@$PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/logging.logWriter

gsutil rm -rf gs://$PROJECT_ID-cd-test 

gsutil rm -rf gs://$PROJECT_ID-cd-prod

gcloud artifacts repositories delete $ACR \
    --location=$REGION --quiet

gcloud iam service-accounts delete $TEST_SA_RUN@$PROJECT_ID.iam.gserviceaccount.com --quiet
gcloud iam service-accounts delete $PROD_SA_RUN@$PROJECT_ID.iam.gserviceaccount.com --quiet
gcloud iam service-accounts delete $CD_SA@$PROJECT_ID.iam.gserviceaccount.com --quiet