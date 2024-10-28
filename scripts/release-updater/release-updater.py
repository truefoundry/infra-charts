import argparse
import json
import logging
import os
import subprocess
import sys
import time

import requests
import yaml
from requests.exceptions import ConnectionError


def post_payload(url, api_key, payload, retries=3, delay=10):
    headers = {
        "accept": "*/*",
        "Content-Type": "application/json",
        "x-api-key": api_key,
    }
    for i in range(retries):
        try:
            response = requests.post(url, headers=headers, data=json.dumps(payload))
            response.raise_for_status() # If response was successful, no Exception will be raised
            print("Saved release data sucessfully")
            return response
        except ConnectionError as e:
            print(f'Connection error: {e}. Attempt {i+1} of {retries}. Retrying in {delay} seconds...')
            time.sleep(delay)
        except Exception as e:
            print(f'An error occurred: {e}. Attempt {i+1} of {retries}. Retrying in {delay} seconds...')
            time.sleep(delay)
    return None

def get_chart_version(chart):
    chart_yaml_path = f"charts/{chart}/Chart.yaml"
    if os.path.exists(chart_yaml_path):
        try:
            with open(chart_yaml_path, 'r') as file:
                chart_yaml = yaml.safe_load(file)
                return chart_yaml.get('version')
        except yaml.YAMLError:
            print(f"Error: {chart_yaml_path} is not a valid YAML file.")
        except IOError:
            print(f"Error: Unable to read {chart_yaml_path}.")
    else:
        print(f"Skipping {chart_yaml_path}: File does not exist.")
    return None

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Update and save inframold chart information.")
    parser.add_argument("--url", required=True, help="URL to post the payload to")
    parser.add_argument("--api-key", required=True, help="API Key to contact releases server")
    args = parser.parse_args()

    if not args.url:
        print("Error: URL is required. Please provide the URL using the --url argument.")
        sys.exit(1)

    charts = [
        "tfy-k8s-aws-eks-inframold", 
        "tfy-k8s-azure-aks-inframold", 
        "tfy-k8s-gcp-gke-standard-inframold", 
        "tfy-k8s-civo-talos-inframold",
        "tfy-k8s-generic-inframold"
    ]

    for chart in charts:
        version = get_chart_version(chart)
        file_path = f"charts/{chart}/artifacts-manifest.json"
        if os.path.exists(file_path):
            inframold_summary = {
                "inframoldChartName": chart,
                "inframoldChartVersion": version,
                "componentCharts": []
            }
            try:
                with open(file_path, 'r') as file:
                    data = json.load(file)
                    for item in data:
                        if item['type'] == 'helm':
                            inframold_summary["componentCharts"].append({
                                "chartName": item['details']['chart'],
                                "repoUrl": item['details']['repoURL'],
                                "minChartVersion": item['details']['targetRevision'],
                                "maxChartVersion": item['details']['targetRevision']
                            })
                
                # Save the data for releases
                print("Saving the inframold summary to migration-server: ", inframold_summary)
                post_payload(args.url, args.api_key, inframold_summary)

            except json.JSONDecodeError:
                print(f"Error: {file_path} is not a valid JSON file.")
            except IOError:
                print(f"Error: Unable to read {file_path}.")
        else:
            print(f"Skipping {file_path}: File does not exist.")
