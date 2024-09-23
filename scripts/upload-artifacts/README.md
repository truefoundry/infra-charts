# Uploading artifacts to a private registry

Deploying Inframold charts from a private registry would require having the necessary artifacts required to successfully deploy the chart to be available in the registry. In order to achieve this, we have an artifact-manifest file which details the required artifacts needed for each Truefoundry chart and a script that makes it easy to deploy these artifacts to your own private registry. The [infra-chart ](https://github.com/truefoundry/infra-charts) repo contains a list of 3rd party chart dependencies alongside Truefoundry helm charts that can be deployed, here is a list of Truefoundry Helm Charts that can be deployed depending on the environment you wish to deploy Truefoundry into;

- [AWS EKS (tfy-k8s-aws-eks-inframold)](https://github.com/truefoundry/infra-charts/tree/main/charts/tfy-k8s-aws-eks-inframold)
- [Azure AKS (tfy-k8s-azure-aks-inframold)](https://github.com/truefoundry/infra-charts/tree/main/charts/tfy-k8s-azure-aks-inframold)
- [Civo Talos (tfy-k8s-civo-talos-inframold)](https://github.com/truefoundry/infra-charts/tree/main/charts/tfy-k8s-civo-talos-inframold)
- [GCP GKE Standard (tfy-k8s-gcp-gke-standard-inframold)](https://github.com/truefoundry/infra-charts/tree/main/charts/tfy-k8s-gcp-gke-standard-inframold)
- [Generis Kubernetes Cluster (tfy-k8s-generic-inframold)](https://github.com/truefoundry/infra-charts/tree/main/charts/tfy-k8s-generic-inframold)

## Steps to deploy artifacts to a private registry

1. Get the necessary artifacts-manifest.json file from the [infra-charts](https://github.com/truefoundry/infra-charts/tree/main/charts/) folder depending on the infrastructure you want to deploy to.
2. Install the python dependencies
   ```
   pip install -r requirements.txt
   ```
3. The `upload_artifact.py` is a sample python scripts which handles deployment to JFrog and ECR registries, it takes in the following arguments;
    - `artifact_type` - this takes in the artifact type which can be either `image` or `helm`
    - `file_path `- this is the location of the artifacts-manifest.json file that contains the artifacts' information.
    - `destination_registry` - this is the registry you plan to use in your air-gapped environment.
    - `registry_type` the type of registry. The script currently take ecr for AWS registry and jfrog 
4. Before uploading images or charts to your registry, make sure you're authenticated. When setting up jfrog, you have to create a token the script will use. Follow this [link](https://jfrog.com/help/r/how-to-generate-an-access-token-video/artifactory-creating-access-tokens-in-artifactory) to generate your token. Once you get the token, pass it in as an environment variable - `JFROG_TOKEN` before running the script.
   When deploying to ECR, the following are needed to be passed as environment variables - `AWS_PROFILE` and `AWS_REGION`.
   To update your registry with the required images to a jfrog registry, run the following command
   ```
   python upload_artifacts.py image artifacts-manifest.json <jfrog-registry-tenant>.jfrog.io jfrog
   ```
5. To update your registry with the necessary helm to an ecr registry
   ```
   python upload_artifacts.py helm artifacts-manifest.json <aws-account>.dkr.ecr.<region>.amazonaws.com ecr
   ```
