# Cloning Images to Your Registry

This guide will help you pull a list of all TrueFoundry images used in the Helm chart and copy them to your destination registry. For AWS ECR destinations, it will also create the necessary ECR repositories in your AWS account.

**Important**: The script performs actual operations by default. Use the `--dry-run` flag to preview what would be done without making any changes.

## Prerequisites

### Required Tools
- [Skopeo CLI](https://github.com/containers/skopeo/blob/main/install.md)
- AWS CLI (only required for AWS ECR destinations)

### Authentication

#### Source Registry: Access to the TrueFoundry Artifactory (JFrog) registry (required for all destinations)
```bash
# Using Skopeo CLI
skopeo login tfy.jfrog.io
# Use previously shared credentials
```
#### Destination Registry: Authentication to your destination registry
- **Method 1 (Recommended)**: Use `skopeo login` before running the script
  ```bash
  # For AWS ECR
  aws ecr get-login-password --region <region> | skopeo login --username AWS --password-stdin <your-ecr-registry>
  
  # For other registries
  skopeo login <your-registry>
  ```
- **Method 2**: Pass credentials as command-line flags (`--dest-user` and `--dest-pass`)
  ```bash
  # Example with flags
  --dest-user your-username --dest-pass your-password
  ```

### AWS ECR Authentication (Optional)
If using AWS ECR as your destination, ensure you are authenticated:

```bash
# Using Skopeo CLI
aws ecr get-login-password --region <region> | skopeo login --username AWS --password-stdin <your-ecr-registry>

# Example for specific registry
aws ecr get-login-password --region us-west-2 | skopeo login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com
```

## Steps

### Add TrueFoundry Helm Repository

First, add the TrueFoundry Helm repository and get a list of available versions:

```bash
# Add the TrueFoundry Helm repository
helm repo add truefoundry https://truefoundry.github.io/infra-charts

# Update the repository to get the latest chart information
helm repo update

# List available versions of the TrueFoundry chart
helm search repo truefoundry --versions

# Example output:
# NAME                    CHART VERSION   APP VERSION     DESCRIPTION
# truefoundry/truefoundry 0.90.0         0.90.0         TrueFoundry platform deployment chart
# truefoundry/truefoundry 0.89.4         0.89.4         TrueFoundry platform deployment chart
# truefoundry/truefoundry 0.89.3         0.89.3         TrueFoundry platform deployment chart
```

### Clone Images to Your Registry

This script will:
1. Extract images from the TrueFoundry Helm chart
2. Create ECR repositories (AWS ECR destinations only)
3. Check destination registry authentication
4. Check if images already exist in destination registry
5. Copy images to your destination registry
6. Display operation summary

```bash
export TRUEFOUNDRY_HELM_CHART_VERSION=0.90.0
export DEST_REGISTRY=<YOUR_DESTINATION_REGISTRY>  # Can include optional prefix like: registry.com/prefix

# Preview mode - shows what would be done without making changes
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- --helm-chart truefoundry --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION --dest-registry $DEST_REGISTRY --dry-run

# Live mode (default) - actually performs the operations
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- --helm-chart truefoundry --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION --dest-registry $DEST_REGISTRY

# For other registries (Docker Hub, etc.)
# Method 1: Using pre-authenticated sessions (recommended)
# First authenticate with skopeo login, then run without credentials
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- --helm-chart truefoundry --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION --dest-registry $DEST_REGISTRY

# Method 2: Passing credentials as command-line flags
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- --helm-chart truefoundry --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION --dest-registry $DEST_REGISTRY --dest-user $DEST_USERNAME --dest-pass $DEST_PASSWORD
```

### Registry-Specific Examples

#### Docker Hub
```bash
# Method 1: Using skopeo login (recommended)
# First authenticate
skopeo login docker.io

# Then run without credentials
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- \
  --helm-chart truefoundry \
  --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION \
  --dest-registry docker.io

# Method 2: Using command-line flags
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- \
  --helm-chart truefoundry \
  --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION \
  --dest-registry docker.io \
  --dest-user your-dockerhub-username \
  --dest-pass your-dockerhub-token
```

#### AWS ECR
```bash
# Method 1: Using skopeo login with AWS_PROFILE (recommended)
# Set your AWS profile
export AWS_PROFILE=your-aws-profile

# Authenticate to ECR using the profile
aws ecr get-login-password --region us-west-2 | skopeo login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com

# Then run without credentials (prefix included in registry URL)
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- \
  --helm-chart truefoundry \
  --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION \
  --dest-registry 123456789012.dkr.ecr.us-west-2.amazonaws.com/truefoundry

# Method 2: Using command-line flags with AWS_PROFILE
export AWS_PROFILE=your-aws-profile
export ECR_PASSWORD=$(aws ecr get-login-password --region us-west-2)

curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- \
  --helm-chart truefoundry \
  --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION \
  --dest-registry 123456789012.dkr.ecr.us-west-2.amazonaws.com/truefoundry \
  --dest-user AWS \
  --dest-pass $ECR_PASSWORD
```

#### Generic Private Registry
```bash
# Method 1: Using skopeo login (recommended)
# First authenticate
skopeo login your-registry.com

# Then run without credentials
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- \
  --helm-chart truefoundry \
  --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION \
  --dest-registry your-registry.com

# Method 2: Using command-line flags
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/main/scripts/clone_images_to_your_registry.sh | bash -s -- \
  --helm-chart truefoundry \
  --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION \
  --dest-registry your-registry.com \
  --dest-user your-username \
  --dest-pass your-password
```

## Command Line Flags

- `--dry-run`: Preview mode - shows what would be done without performing any operations (default is to perform operations)
- `--force-copy`: Skip checking if images exist and force copy
- `--helm-chart`: Helm chart name (default: truefoundry)
- `--helm-version`: Helm chart version (required)
- `--dest-registry`: Destination registry URL with optional path prefix (required)
  - Examples: `my-registry.com` or `my-registry.com/myapp`
- `--dest-user`: Destination registry username (optional)
- `--dest-pass`: Destination registry password/token (optional)
- `--source-user`: Source registry username (optional)
- `--source-pass`: Source registry password/token (optional)

## Variables

- `DEST_REGISTRY`: Your destination registry URL with optional path prefix
  - AWS ECR without prefix: `123456789012.dkr.ecr.us-west-2.amazonaws.com`
  - AWS ECR with prefix: `123456789012.dkr.ecr.us-west-2.amazonaws.com/truefoundry`
  - Docker Hub: `docker.io` or `docker.io/your-username`
  - Other registries without prefix: `your-registry.com`
  - Other registries with prefix: `your-registry.com/myapp`
  - With prefix: Images will be copied to `registry.com/prefix/<image-name>`
  - Without prefix: Images will be copied directly to `registry.com/<image-name>`
- `DEST_USERNAME`: Destination registry username (optional, for credential-based authentication)
- `DEST_PASSWORD`: Destination registry password/token (optional, for credential-based authentication)

## Example Output
```
Processing image: tfy.jfrog.io/nginx:1.21
----------------------------------------
Checking if image exists: my-registry.com/myapp/nginx:1.21
✗ Image does not exist. Proceeding with copy...
Copying image: my-registry.com/myapp/nginx:1.21
Running command: skopeo copy --multi-arch all docker://tfy.jfrog.io/nginx:1.21 docker://my-registry.com/myapp/nginx:1.21

Getting image source signatures
Copying blob sha256:abc123... done
Copying blob sha256:def456... done
Copying config sha256:ghi789... done
Writing manifest to image destination
Storing signatures
✓ Successfully copied image: my-registry.com/myapp/nginx:1.21

========================================
Image cloning process complete.
========================================

Summary:
  Total images processed: 5
  Images skipped (already exist): 2
  Images successfully copied: 3
  Images failed to copy: 0

Exit code: 0 (all operations completed successfully)
```

## Troubleshooting

### Authentication Issues

If you encounter authentication errors, ensure you are properly authenticated:

#### Source Registry (JFrog) Authentication
```bash
# Using Skopeo CLI
skopeo login tfy.jfrog.io
# Use previously shared credentials
```

#### AWS ECR Authentication
```bash
# Check your current AWS authentication
aws sts get-caller-identity

# Re-authenticate to ECR if needed
aws ecr get-login-password --region <region> | skopeo login --username AWS --password-stdin <your-ecr-registry>

# Verify ECR access manually
skopeo inspect docker://<your-ecr-registry>/<test-image>
```

#### Other Registry Authentication
```bash
# Using Skopeo CLI
skopeo login <your-registry>

# Verify access manually
skopeo inspect docker://<your-registry>/<test-image>
```

