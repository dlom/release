#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

infra_name=${NAMESPACE}-${UNIQUE_HASH}
export GCP_SHARED_CREDENTIALS_FILE=${CLUSTER_PROFILE_DIR}/gce.json
export GOOGLE_APPLICATION_CREDENTIALS="${GCP_SHARED_CREDENTIALS_FILE}"
PROJECT="$(< ${CLUSTER_PROFILE_DIR}/openshift_gcp_project)"

echo "RELEASE_IMAGE_LATEST: ${RELEASE_IMAGE_LATEST}"
echo "RELEASE_IMAGE_LATEST_FROM_BUILD_FARM: ${RELEASE_IMAGE_LATEST_FROM_BUILD_FARM}"

# The CredentialsRequests are required for cleaning up resources in GCP and since
# the step registry does not support passing sub-directories within the ${SHARED_DIR},
# we re-extract the CredentialsRequests from the release image to /tmp/credrequests
# for deprovision.
# https://docs.ci.openshift.org/docs/architecture/step-registry/#sharing-data-between-steps
echo "> Extract gcp credentials requests from the release image"
oc adm release extract --credentials-requests --cloud=gcp --to="/tmp/credrequests" "${RELEASE_IMAGE_LATEST_FROM_BUILD_FARM}"

echo "> Output gcp credentials requests to directory: /tmp/credrequests"
ls "/tmp/credrequests"

echo "> Delete credentials infrastructure created by oidc-creds-provision-provision configure step"
export GOOGLE_APPLICATION_CREDENTIALS="${GCP_SHARED_CREDENTIALS_FILE}"
ccoctl gcp delete --name="${infra_name}" --project="${PROJECT}" --credentials-requests-dir="/tmp/credrequests"
