#!/bin/bash
set -e

# validate arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <inframold_name> <cluster_type> <aws_s3_bucket>"
    exit 1
fi

INFRAMOLD_NAME=$1
CLUSTER_TYPE=$2
AWS_S3_BUCKET=$3

validate_target_revision() {
    local addon_target_revision=$1
    if [ -z "${addon_target_revision}" ] || [ "${addon_target_revision}" == "null" ]; then
        echo "Addon target revision is null or not defined. Exiting."
        exit 1
    fi
}

copy_addon_manifest_to_s3() {
    local directory=$1
    local cluster_type=$2
    for file in $(find "${directory}" -type f); do
        addon_name=$(basename "${file}" .yaml)
        addon_target_revision=$(yq e '.spec.source.targetRevision' "${file}")
        validate_target_revision "${addon_target_revision}"
        # Copy the addon manifest to S3
        aws s3 cp "${file}" "s3://${AWS_S3_BUCKET}/addons/${cluster_type}/addons/${addon_name}/versions/${addon_target_revision}/manifest.yaml"
    done
}

copy_control_plane_addon_version_to_s3() {
    local directory=$1
    local cluster_type=$2
    local cp_chart_version=$3
    local target_addon_version_file_path="/tmp/cp_addon_versions/targetAddonVersion.yaml"
    mkdir -p "/tmp/cp_addon_versions"
    touch ${target_addon_version_file_path}
    for file in $(find "${directory}" -type f); do
        addon_name=$(basename "${file}" .yaml)
        addon_target_revision=$(yq e '.spec.source.targetRevision' "${file}")
        validate_target_revision "${addon_target_revision}"
        yq e ".${addon_name} = ${addon_target_revision}" -i ${target_addon_version_file_path}
    done
    # Copy the target version map to S3
    aws s3 cp "${target_addon_version_file_path}" "s3://${AWS_S3_BUCKET}/addons/${cluster_type}/control-planes/${cp_chart_version}/targetAddonVersion.yaml"
    rm -rf "/tmp/cp_addon_versions"
}

echo "Rendering ${CLUSTER_TYPE} k8s manifests..."

additional_options=""
if [ "${CLUSTER_TYPE}" = "aws-eks" ]; then
    additional_options="--set aws.karpenter.defaultZones={\"\"}"
fi
helm template inframold -n argocd -f "./charts/${INFRAMOLD_NAME}/values-helm.yaml" -f "./charts/${INFRAMOLD_NAME}/values-ocli.yaml" "./charts/${INFRAMOLD_NAME}" ${additional_options} --output-dir catalogues

# Get the version of the truefoundry helm chart
cp_chart_version=$(yq e '.spec.source.targetRevision' "./catalogues/${INFRAMOLD_NAME}/templates/truefoundry.yaml")

# Preview version for devtest
cp_preview_version="preview"

# Sync to S3
aws s3 sync "./catalogues/${INFRAMOLD_NAME}/templates" "s3://${AWS_S3_BUCKET}/${CLUSTER_TYPE}/templates" --delete

# Sync to S3 chart version folder
aws s3 sync "./catalogues/${INFRAMOLD_NAME}/templates" "s3://${AWS_S3_BUCKET}/${CLUSTER_TYPE}/${cp_chart_version}/templates" --delete

# Sync to S3 preview version folder
aws s3 sync "./catalogues/${INFRAMOLD_NAME}/templates" "s3://${AWS_S3_BUCKET}/${CLUSTER_TYPE}/${cp_preview_version}/templates" --delete

# Copy addon version manifests to S3
copy_addon_manifest_to_s3 "./catalogues/${INFRAMOLD_NAME}/templates" "${CLUSTER_TYPE}"

# Copy control plane addon version map to S3
copy_control_plane_addon_version_to_s3 "./catalogues/${INFRAMOLD_NAME}/templates" "${CLUSTER_TYPE}" "${cp_chart_version}"

echo "Synced catalogue for ${CLUSTER_TYPE} successfully."
