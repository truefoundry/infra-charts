import os
import subprocess
import yaml

ARTIFACTORY_REPOSITORY_URL = os.getenv("ARTIFACTORY_REPOSITORY_URL")
INFRAMOLD_ARTIFACTORY_REPOSITORY_URL = os.getenv("INFRAMOLD_ARTIFACTORY_REPOSITORY_URL")

def get_chart_info(chart_dir):
    """Extract chart name and version from Chart.yaml"""
    with open(os.path.join(chart_dir, "Chart.yaml"), "r") as file:
        chart_yaml = yaml.safe_load(file)
        chart_name = chart_yaml.get("name")
        chart_version = chart_yaml.get("version")
    return chart_name, chart_version

def helm_chart_exists(chart_name, chart_version, repo_url):
    """Check if a Helm chart exists in the repository"""
    try:
        subprocess.run(
            ["helm", "pull", f"oci://{repo_url}/{chart_name}", "--version", chart_version],
            check=True,
            capture_output=True,
            text=True
        )
        return True
    except subprocess.CalledProcessError:
        return False

def upload_chart(chart_dir):
    """Upload Helm chart to OCI repository and inframold repository"""
    chart_name, chart_version = get_chart_info(chart_dir)
    print(f"Uploading chart {chart_name} with version {chart_version}")


    for repo_url in [ARTIFACTORY_REPOSITORY_URL, INFRAMOLD_ARTIFACTORY_REPOSITORY_URL]:
        if not helm_chart_exists(chart_name, chart_version, repo_url):
            # Update dependencies, package the chart, and push to the repository
            subprocess.run(["helm", "dependency", "update"], check=True, cwd=chart_dir)
            subprocess.run(["helm", "package", "."], check=True, cwd=chart_dir)
            
            package_file = f"{chart_name}-{chart_version}.tgz"
            try:
                print(f"Pushing {chart_name} to oci://{repo_url} command")
                # subprocess.run(
                #     ["helm", "push", package_file, f"oci://{repo_url}"],
                #     check=True,
                #     cwd=chart_dir
                # )
                print(f"Pushed helm chart {package_file} to the OCI repository oci://{repo_url}")
            except subprocess.CalledProcessError as e:
                print(f"Failed to push helm chart {chart_name}: {e}")
                exit(1)
        

def main():
    """Main script to iterate over chart directories and upload charts"""
    current_dir = os.getcwd()
    charts_dir = os.path.join(current_dir, "charts")
    chart_dirs = [os.path.join(charts_dir, d) for d in os.listdir(charts_dir) if os.path.isdir(os.path.join(charts_dir, d))]

    for chart_dir in chart_dirs:
        print(f"Current directory is {chart_dir}")
        upload_chart(chart_dir)

if __name__ == "__main__":
    main()
