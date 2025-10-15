# Cloning Images to Your Registry

This guide will help you pull a list of all TrueFoundry images used in the Helm chart and copy them to your destination registry. For AWS ECR destinations, it will also create the necessary ECR repositories in your AWS account.

## Prerequisites

### Required Tools
- Docker CLI
- [Skopeo CLI](https://github.com/containers/skopeo/blob/main/install.md)
- AWS CLI (only required for AWS ECR destinations)

### Authentication
- **Source Registry**: Access to the TrueFoundry Artifactory (JFrog) registry (required for all destinations)
    ```bash
    # Using Docker CLI
    docker login tfy.jfrog.io
    # Use previously shared credentials
    
    # Or using Skopeo directly
    skopeo login tfy.jfrog.io
    # Use previously shared credentials
    ```
- **Destination Registry**: Authentication to your destination registry
  - For AWS ECR: AWS credentials and ECR authentication
  - For other registries: Appropriate authentication for your registry

### AWS ECR Authentication (Optional)
If using AWS ECR as your destination, ensure you are authenticated:

```bash
# Using Docker CLI
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <your-ecr-registry>

# Or using Skopeo directly
aws ecr get-login-password --region <region> | skopeo login --username AWS --password-stdin <your-ecr-registry>

# Example for specific registry
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com
```

## Steps

### Clone Images to Your Registry

This script will:
1. Extract images from the TrueFoundry Helm chart
2. Verify your destination registry authentication using skopeo
3. For AWS ECR destinations: determine and create necessary ECR repositories
4. Copy the images to your destination registry

```bash
export TRUEFOUNDRY_HELM_CHART_VERSION=0.90.0
export DEST_REGISTRY=<YOUR_DESTINATION_REGISTRY>
export DEST_PREFIX=<REPO_PREFIX>  # Only required for AWS ECR

# For AWS ECR destinations
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/refs/heads/aws-ecr/scripts/clone_images_to_your_registry.sh | bash -s -- --helm-chart truefoundry --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION --dest-registry $DEST_REGISTRY --dest-prefix $DEST_PREFIX --dry-run

# For other registries (Docker Hub, etc.)
# Option 1: Using pre-authenticated sessions (recommended)
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/refs/heads/aws-ecr/scripts/clone_images_to_your_registry.sh | bash -s -- --helm-chart truefoundry --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION --dest-registry $DEST_REGISTRY --dry-run

# Option 2: Passing credentials as flags
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/refs/heads/aws-ecr/scripts/clone_images_to_your_registry.sh | bash -s -- --helm-chart truefoundry --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION --dest-registry $DEST_REGISTRY --dest-user $DEST_USERNAME --dest-pass $DEST_PASSWORD --dry-run
```

### Registry-Specific Examples

#### Docker Hub
```bash
# Using credentials as flags
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/refs/heads/aws-ecr/scripts/clone_images_to_your_registry.sh | bash -s -- \
  --helm-chart truefoundry \
  --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION \
  --dest-registry docker.io \
  --dest-user your-dockerhub-username \
  --dest-pass your-dockerhub-token
```

#### Generic Private Registry
```bash
# Using credentials as flags
curl -s https://raw.githubusercontent.com/truefoundry/infra-charts/refs/heads/aws-ecr/scripts/clone_images_to_your_registry.sh | bash -s -- \
  --helm-chart truefoundry \
  --helm-version $TRUEFOUNDRY_HELM_CHART_VERSION \
  --dest-registry your-registry.com \
  --dest-user your-username \
  --dest-pass your-password
```

## Variables

- `DEST_REGISTRY`: Your destination registry URL
  - AWS ECR: `123456789012.dkr.ecr.us-west-2.amazonaws.com`
  - Docker Hub: `docker.io` or `docker.io/your-username`
  - Other registries: `your-registry.com`
- `DEST_PREFIX`: Repository prefix (only required for AWS ECR)
  - ECR: `truefoundry` will create repositories like `truefoundry/<image-name>`
  - Other registries: Images will be copied directly without prefix
- `DEST_USERNAME`: Destination registry username (optional, for credential-based authentication)
- `DEST_PASSWORD`: Destination registry password/token (optional, for credential-based authentication)

## Troubleshooting

### Authentication Issues

If you encounter authentication errors, ensure you are properly authenticated:

#### Source Registry (JFrog) Authentication
```bash
# Using Docker CLI
docker login tfy.jfrog.io
# Use previously shared credentials

# Or using Skopeo directly
skopeo login tfy.jfrog.io
# Use previously shared credentials
```

#### AWS ECR Authentication
```bash
# Check your current AWS authentication
aws sts get-caller-identity

# Re-authenticate to ECR if needed
# Using Docker CLI
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <your-ecr-registry>

# Or using Skopeo directly
aws ecr get-login-password --region <region> | skopeo login --username AWS --password-stdin <your-ecr-registry>

# Verify ECR access manually
skopeo inspect docker://<your-ecr-registry>/<test-image>
```

#### Other Registry Authentication
```bash
# Using Docker CLI
docker login <your-registry>

# Or using Skopeo directly
skopeo login <your-registry>

# Verify access manually
skopeo inspect docker://<your-registry>/<test-image>
```

