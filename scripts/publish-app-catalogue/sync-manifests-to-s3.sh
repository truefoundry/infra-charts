#!/bin/bash
set -e

# validate arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <inframold_name> <cloud_provider>"
    exit 1
fi

INFRAMOLD_NAME=$1
CLOUD_PROVIDER=$2

copy_to_s3() {
    local directory=$1
    local cloud_provider=$2
    for file in "${directory}"/*; do
        if [ -f "${file}" ]; then
            addon_name=$(basename "${file}" .yaml)
            addon_target_revision=$(yq e '.spec.source.targetRevision' "${file}")
            if [ -z "${addon_target_revision}" ] || [ "${addon_target_revision}" == "null" ]; then
                echo "Addon target revision is null or not defined. Exiting."
                exit 1
            fi
            # Copy the addon file to S3
            aws s3 cp "${file}" "s3://tfy-argo-application-catalogue/${cloud_provider}/addons/${addon_name}/${addon_target_revision}.yaml"
        elif [ -d "${file}" ]; then # if folder, recursively call copy_to_s3
            copy_to_s3 "${file}" "${cloud_provider}"
        fi
    done
}

echo "Rendering ${CLOUD_PROVIDER} k8s manifests..."

additional_options=""
if [ "${CLOUD_PROVIDER}" = "aws-eks" ]; then
    additional_options="--set aws.karpenter.defaultZones={\"\"}"
fi
helm template inframold -n argocd -f "./charts/${INFRAMOLD_NAME}/values-helm.yaml" -f "./charts/${INFRAMOLD_NAME}/values-ocli.yaml" "./charts/${INFRAMOLD_NAME}" ${additional_options} --output-dir catalogues

# Get the version of the truefoundry helm chart
cp_chart_version=$(yq e '.spec.source.targetRevision' "./catalogues/${INFRAMOLD_NAME}/templates/truefoundry.yaml")

# Sync to S3
aws s3 sync "./catalogues/${INFRAMOLD_NAME}/templates" "s3://tfy-argo-application-catalogue/${CLOUD_PROVIDER}/templates" --delete

# Sync to S3 chart version folder
aws s3 sync "./catalogues/${INFRAMOLD_NAME}/templates" "s3://tfy-argo-application-catalogue/${CLOUD_PROVIDER}/${cp_chart_version}/templates" --delete

# Copy to S3 addon version files
copy_to_s3 "./catalogues/${INFRAMOLD_NAME}/templates" "${CLOUD_PROVIDER}"

echo "Synced catalogue for ${CLOUD_PROVIDER} successfully."
