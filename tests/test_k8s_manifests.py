import os
import yaml
import pytest

def get_manifests():
    k8s_dir = os.path.join(os.path.dirname(__file__), '..', 'k8s')
    deployments_path = os.path.join(k8s_dir, 'deployments.yaml')
    
    with open(deployments_path, 'r') as f:
        # Load all documents from the YAML file
        return list(yaml.safe_load_all(f))

def test_deployments_have_service_accounts():
    manifests = get_manifests()
    deployments = [m for m in manifests if m and m.get('kind') == 'Deployment']
    service_accounts = [m for m in manifests if m and m.get('kind') == 'ServiceAccount']
    
    sa_names = {sa['metadata']['name'] for sa in service_accounts}
    
    assert len(deployments) > 0, "No deployments found in manifests"
    
    for dep in deployments:
        sa_name = dep['spec']['template']['spec'].get('serviceAccountName')
        assert sa_name is not None, f"Deployment {dep['metadata']['name']} is missing a serviceAccountName"
        assert sa_name in sa_names, f"Deployment {dep['metadata']['name']} references unknown SA: {sa_name}"

def test_frontend_backend_exist():
    manifests = get_manifests()
    deployments = {m['metadata']['name'] for m in manifests if m and m.get('kind') == 'Deployment'}
    
    assert 'frontend' in deployments
    assert 'backend' in deployments
