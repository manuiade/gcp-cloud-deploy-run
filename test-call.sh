gcurl() {
  curl -H "Authorization: Bearer ${1}" "${2}"
}

gcurl-quiet() {
  curl -S -s -o /dev/null -H "Authorization: Bearer ${1}" "${2}"
}

warm-gcurl() {
  for i in {1..20} ; do gcurl-quiet ${1} ${2}; done
}

multi-gcurl() {
  for i in {1..10} ; do printf "%2d. " ${i} && gcurl ${1} ${2}; sleep 1; done
}

if [ "$#" -ne 1 ]; then
  echo "Usage: ${0} <TARGET_NAME>"
  exit 1
fi

SVC=${1}
TOKEN=$(gcloud auth print-identity-token)
URL=$(gcloud run services describe demo-app-${SVC} --format='value(status.url)')

warm-gcurl ${TOKEN} ${URL}
sleep 1
multi-gcurl ${TOKEN} ${URL}