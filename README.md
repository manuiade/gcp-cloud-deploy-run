# Cloud Deploy experiments with Cloud Run Targets

## Requirements

- GCP Project
- GCP User with enough IAM roles on project (Owner for testing purposes)
- Webhook endpoint (Google Chat used in this example)

## Set env vars

```
export PROJECT_ID=<PROJECT_ID>
export PROJECT_NUMBER="$(gcloud projects describe $PROJECT_ID --format='get(projectNumber)')"
export REGION=europe-west1

export TEST_SA_RUN=test-sa
export PROD_SA_RUN=prod-sa

export CD_SA=cloud-deploy-sa

export ACR=run-acr

export CD_AUTO=demo-app-auto
export CD_CUSTOM=demo-app-custom

gcloud config set project $PROJECT_ID
gcloud config set run/region $REGION
```

## Set Webhook url to receive notification about cloud deploy operations

```
export GGCHAT_URL=<GGCHAT_URL>
```

## Substitute variables in YAML files

```
sed -i "s/TEST_SA_RUN/$TEST_SA_RUN/g" demo-app/demo-app/kubernetes/overlays/test/target.yaml
sed -i "s/PROJECT_ID/$PROJECT_ID/g" demo-app/demo-app/kubernetes/overlays/test/target.yaml

sed -i "s/PROD_SA_RUN/$PROD_SA_RUN/g" demo-app/demo-app/kubernetes/overlays/prod/target.yaml
sed -i "s/PROJECT_ID/$PROJECT_ID/g" demo-app/demo-app/kubernetes/overlays/prod/target.yaml

sed -i "s/PROJECT_ID/$PROJECT_ID/g" clouddeploy.yaml
sed -i "s/REGION/$REGION/g" clouddeploy.yaml
sed -i "s/CD_SA/$CD_SA/g" clouddeploy.yaml

sed -i "s/PROJECT_ID/$PROJECT_ID/g" demo-app/skaffold.yaml
sed -i "s/REGION/$REGION/g" demo-app/skaffold.yaml
```

## Setup
```
./setup.sh
```

## Test Cloud Deploy

### Register the Cloud Deploy Delivery Pipeline
```
gcloud deploy apply \
    --file clouddeploy.yaml --region=$REGION
  
gcloud deploy delivery-pipelines describe $CD_AUTO --region=$REGION
```

```
gcloud deploy releases create release-1 \
    --delivery-pipeline $CD_AUTO \
    --region $REGION \
    --build-artifacts demo-app/artifacts.json \
    --source demo-app/ \
    --gcs-source-staging-dir gs://$PROJECT_ID-cd-test/source
```

### Get status of releases and rollouts
```
gcloud deploy releases describe release-1 \
  --delivery-pipeline $CD_AUTO   \
  --region $REGION

gcloud deploy rollouts list \
  --delivery-pipeline $CD_AUTO \
  --release release-1 \
  --region $REGION

gcloud deploy rollouts describe release-1-to-run-qstest-0001 \
    --delivery-pipeline $CD_AUTO \
    --region $REGION \
    --release release-1
```

### Test
```
./test-call.sh test
```

### Promote to prod

```
gcloud deploy releases promote \
    --release release-1 \
    --delivery-pipeline $CD_AUTO \
    --region $REGION \
    --to-target run-qsprod
```

### Advance rollout to next phase (first deploy skips to stable phase)
```
gcloud beta deploy rollouts advance release-1-to-run-qsprod-0001 \
    --release release-1 \
    --delivery-pipeline=$CD_AUTO \
    --region $REGION \
    --phase-id=stable
```

### Test
```
./test-call.sh prod
```

### Modify code (kustomize target env value BLUE|GREEN), add verification step (clouddeploy.yaml line 19) and create a new release

```
gcloud deploy apply \
    --file clouddeploy.yaml --region=$REGION

gcloud deploy releases create release-2 \
    --delivery-pipeline $CD_AUTO \
    --region $REGION \
    --build-artifacts demo-app/artifacts.json \
    --source demo-app/ \
    --gcs-source-staging-dir gs://$PROJECT_ID-cd-test/source
```

### Test profile will be already stable (no rollout phases)
```
./test-call.sh test
```

### Promote to prod

```
gcloud beta deploy releases promote \
    --release release-2 \
    --delivery-pipeline $CD_AUTO \
    --region $REGION \
    --to-target run-qsprod 
```

### Prod profile will be in canary-25
```
./test-call.sh prod
```

### Advance to canary-50

```
gcloud beta deploy rollouts advance release-2-to-run-qsprod-0001 \
    --release release-2 \
    --delivery-pipeline=$CD_AUTO \
    --region $REGION \
    --phase-id=canary-50

./test-call.sh prod
```

### Advance to stable

```
gcloud beta deploy rollouts advance release-2-to-run-qsprod-0001 \
    --release release-2 \
    --delivery-pipeline=$CD_AUTO \
    --region $REGION \
    --phase-id=stable

./test-call.sh prod
```


### Roll back to previous release (deploy directly the stable phase)

```
gcloud deploy rollouts list \
  --delivery-pipeline $CD_AUTO \
  --release release-1 \
  --region $REGION

gcloud deploy targets rollback run-qsprod  \
   --delivery-pipeline=$CD_AUTO  \
   --region $REGION
   # --release=$RELEASE_1

./test-call.sh prod
```


## Reset variables in YAML files

```
sed -i "s/$TEST_SA_RUN/TEST_SA_RUN/g" demo-app/demo-app/kubernetes/overlays/test/target.yaml
sed -i "s/$PROJECT_ID/PROJECT_ID/g" demo-app/demo-app/kubernetes/overlays/test/target.yaml

sed -i "s/$PROD_SA_RUN/PROD_SA_RUN/g" demo-app/demo-app/kubernetes/overlays/prod/target.yaml
sed -i "s/$PROJECT_ID/PROJECT_ID/g" demo-app/demo-app/kubernetes/overlays/prod/target.yaml

sed -i "s/$PROJECT_ID/PROJECT_ID/g" clouddeploy.yaml
sed -i "s/$REGION/REGION/g" clouddeploy.yaml
sed -i "s/$CD_SA/CD_SA/g" clouddeploy.yaml

sed -i "s/$PROJECT_ID/PROJECT_ID/g" demo-app/skaffold.yaml
sed -i "s/$REGION/REGION/g" demo-app/skaffold.yaml
```

## Cleanup

```
delete.sh
```