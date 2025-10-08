# Cloning Images to Your Registry (ECR)

This guide will help you pull a list of all TrueFoundry images used in the Helm chart, create ECR repositories in your AWS account, and copy the images to your registry.

## Prerequisites

### Required Tools
- AWS CLI
- Docker CLI
- [Skopeo CLI](https://github.com/containers/skopeo/blob/main/install.md)

### Authentication
- AWS credentials for the destination account that allow AWS ECR commands
- Access to the TrueFoundry Artifactory (JFrog) registry
    ```bash
    docker login tfy.jfrog.io
    # Use previously shared credentials
    ```

## Steps

### 1. Extract Images from Helm Chart

Get the list of images for TrueFoundry installation:

```bash
export TRUEFOUNDRY_HELM_CHART_VERSION=0.88.2
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/extract_images_from_helm_chart.sh | bash -s -- --repo oci://tfy.jfrog.io/tfy-helm --chart truefoundry --version $TRUEFOUNDRY_HELM_CHART_VERSION --values truefoundry-values.yaml
```

### 2. Clone Images to Your Registry

This script will use the extracted images from step 1 to determine the necessary ECR repositories to create and then copy the images.

```bash
export TRUEFOUNDRY_HELM_CHART_VERSION=0.88.2
export DEST_REGISTRY=<YOUR_ECR_REGISTRY>
export DEST_PREFIX=<ECR_REPO_PREFIX>

# Dry-Run 
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/refs/heads/aws-ecr/scripts/clone_images_to_your_registry.sh | bash -s -- --input truefoundry-images-$TRUEFOUNDRY_HELM_CHART_VERSION --dest-registry $DEST_REGISTRY --dest-prefix $DEST_PREFIX --dry-run

# Run
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/refs/heads/aws-ecr/scripts/clone_images_to_your_registry.sh | bash -s -- --input truefoundry-images-$TRUEFOUNDRY_HELM_CHART_VERSION --dest-registry $DEST_REGISTRY --dest-prefix $DEST_PREFIX
```

## Variables

- `DEST_REGISTRY`: Your AWS ECR registry URL (e.g., `123456789012.dkr.ecr.us-west-2.amazonaws.com`)
- `DEST_PREFIX`: ECR repository prefix (e.g., `truefoundry` will create repositories like `truefoundry/<image-name>`)