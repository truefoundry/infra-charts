#!/usr/bin/env python3
"""
Script to calculate total CPU, memory, ephemeral storage, and PVC from Kubernetes manifests.
Usage: python3 scripts/calculate-resources.py <path-to-yaml-file> [--detailed|--verbose]

Flags:
  --detailed  Show per-container breakdown
  --verbose   Show per-component/service aggregation with resource usage
"""

import sys
import re
from collections import defaultdict
from pathlib import Path


def parse_cpu(quantity):
    """Parse CPU quantity to millicores."""
    if not quantity:
        return 0
    quantity = str(quantity).strip()
    if quantity.endswith('m'):
        return int(quantity[:-1])
    elif quantity.endswith('n'):
        return int(quantity[:-1]) / 1000000
    elif quantity.endswith('u'):
        return int(quantity[:-1]) / 1000
    else:
        try:
            return float(quantity) * 1000
        except ValueError:
            return 0


def parse_storage(quantity):
    """Parse storage/memory quantity to GiB."""
    if not quantity:
        return 0
    quantity = str(quantity).strip()
    if quantity.endswith('Ki'):
        return int(quantity[:-2]) / (1024 * 1024)
    elif quantity.endswith('Mi'):
        return int(quantity[:-2]) / 1024
    elif quantity.endswith('Gi'):
        return int(quantity[:-2])
    elif quantity.endswith('Ti'):
        return int(quantity[:-2]) * 1024
    elif quantity.endswith('K'):
        return int(quantity[:-1]) / (1024 * 1024)
    elif quantity.endswith('M'):
        return int(quantity[:-1]) / 1024
    elif quantity.endswith('G'):
        return int(quantity[:-1])
    elif quantity.endswith('T'):
        return int(quantity[:-1]) * 1024
    else:
        try:
            return int(quantity) / (1024 * 1024 * 1024)
        except ValueError:
            return 0


def parse_quantity(quantity):
    """
    Parse Kubernetes resource quantity to millicores (for CPU) or MiB (for memory).
    Returns (cpu_millicores, memory_mib)
    """
    if not quantity:
        return 0, 0
    
    quantity = str(quantity).strip()
    
    # CPU parsing (convert to millicores)
    cpu_millicores = 0
    if quantity.endswith('m'):
        cpu_millicores = int(quantity[:-1])
    elif quantity.endswith('n'):
        # nancores - very small, convert to millicores
        cpu_millicores = int(quantity[:-1]) / 1000000
    elif quantity.endswith('u'):
        # microcores
        cpu_millicores = int(quantity[:-1]) / 1000
    else:
        # Assume cores (no suffix)
        try:
            cpu_millicores = float(quantity) * 1000
        except ValueError:
            cpu_millicores = 0
    
    # Memory parsing (convert to MiB)
    memory_mib = 0
    if quantity.endswith('Ki'):
        memory_mib = int(quantity[:-2]) / 1024
    elif quantity.endswith('Mi'):
        memory_mib = int(quantity[:-2])
    elif quantity.endswith('Gi'):
        memory_mib = int(quantity[:-2]) * 1024
    elif quantity.endswith('Ti'):
        memory_mib = int(quantity[:-2]) * 1024 * 1024
    elif quantity.endswith('K'):
        memory_mib = int(quantity[:-1]) / 1024
    elif quantity.endswith('M'):
        memory_mib = int(quantity[:-1])
    elif quantity.endswith('G'):
        memory_mib = int(quantity[:-1]) * 1024
    elif quantity.endswith('T'):
        memory_mib = int(quantity[:-1]) * 1024 * 1024
    else:
        # Assume bytes
        try:
            memory_mib = int(quantity) / (1024 * 1024)
        except ValueError:
            memory_mib = 0
    
    return cpu_millicores, memory_mib


def get_indent_level(line):
    """Get indentation level (number of leading spaces)."""
    return len(line) - len(line.lstrip())


def process_yaml_file(file_path):
    """Process YAML file and calculate total resources."""
    totals = defaultdict(float)
    resource_details = []
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Check for new document
        if line.strip() == '---' or (i == 0 and line.strip()):
            # Parse document
            doc_start = i
            if line.strip() == '---':
                i += 1
            
            # Find document end
            doc_end = i
            while doc_end < len(lines) and lines[doc_end].strip() != '---':
                doc_end += 1
            
            # Extract document metadata
            kind = None
            name = None
            namespace = 'default'
            replicas = 1
            
            for j in range(i, min(doc_end, len(lines))):
                l = lines[j]
                if l.startswith('kind:'):
                    kind = l.split(':', 1)[1].strip()
                elif l.startswith('  name:'):
                    name = l.split(':', 1)[1].strip()
                elif l.startswith('  namespace:'):
                    namespace = l.split(':', 1)[1].strip()
                elif l.startswith('  replicas:'):
                    try:
                        replicas = int(l.split(':', 1)[1].strip())
                    except ValueError:
                        replicas = 1
            
            # Process containers in this document
            if kind in ['Deployment', 'StatefulSet', 'DaemonSet', 'Job']:
                in_containers = False
                in_resources = False
                in_requests = False
                in_limits = False
                in_env = False
                in_ports = False
                in_volumes = False
                in_volume_claim_templates = False
                container_name = None
                container_cpu_req = 0
                container_mem_req = 0
                container_cpu_lim = 0
                container_mem_lim = 0
                container_ephemeral_req = 0
                container_ephemeral_lim = 0
                pvc_storage = 0
                resources_indent = 0
                containers_indent = 0
                current_section_indent = 0
                vct_indent = 0
                
                for j in range(i, min(doc_end, len(lines))):
                    l = lines[j]
                    indent = get_indent_level(l)
                    stripped = l.strip()
                    
                    # Track containers section
                    if 'containers:' in stripped and not in_containers:
                        in_containers = True
                        containers_indent = indent
                        continue
                    
                    # Track when we enter/exit container subsections (env, ports, volumes, etc.)
                    if in_containers:
                        # Check if we're entering a subsection
                        if stripped in ['env:', 'ports:', 'volumeMounts:', 'volumes:', 'resources:']:
                            if stripped == 'env:':
                                in_env = True
                                current_section_indent = indent
                            elif stripped == 'ports:':
                                in_ports = True
                                current_section_indent = indent
                            elif stripped == 'volumeMounts:' or stripped == 'volumes:':
                                in_volumes = True
                                current_section_indent = indent
                            elif stripped == 'resources:':
                                in_resources = True
                                resources_indent = indent
                            continue
                        
                        # Check if we've exited a subsection (indentation went back up)
                        if in_env and indent <= current_section_indent and stripped not in ['env:', '- name:']:
                            in_env = False
                        if in_ports and indent <= current_section_indent and stripped not in ['ports:', '- name:']:
                            in_ports = False
                        if in_volumes and indent <= current_section_indent and stripped not in ['volumeMounts:', 'volumes:', '- name:']:
                            in_volumes = False
                    
                    # Track volumeClaimTemplates for PVC storage
                    if stripped == 'volumeClaimTemplates:':
                        in_volume_claim_templates = True
                        vct_indent = indent
                        continue
                    
                    # Parse PVC storage from volumeClaimTemplates
                    if in_volume_claim_templates:
                        if indent <= vct_indent and stripped and not stripped.startswith('-'):
                            in_volume_claim_templates = False
                        elif stripped.startswith('storage:'):
                            val = stripped.split(':', 1)[1].strip()
                            if val:
                                pvc_storage += parse_storage(val) * replicas
                    
                    # Track container name - only match at the container item level, not in env/ports/volumes
                    # Container items are at containers_indent + 2 spaces
                    if in_containers and stripped.startswith('- name:') and not in_env and not in_ports and not in_volumes:
                        expected_container_indent = containers_indent + 2
                        # Container name should be at the expected indent level
                        if indent == expected_container_indent or (indent >= expected_container_indent and indent < expected_container_indent + 4):
                            # Save previous container if exists
                            if container_name and (container_cpu_req or container_mem_req or container_cpu_lim or container_mem_lim or container_ephemeral_req or container_ephemeral_lim):
                                resource_details.append({
                                    'kind': kind,
                                    'name': name or 'unknown',
                                    'namespace': namespace,
                                    'container': container_name,
                                    'replicas': replicas,
                                    'cpu_request': container_cpu_req * replicas,
                                    'cpu_limit': container_cpu_lim * replicas,
                                    'memory_request': container_mem_req * replicas,
                                    'memory_limit': container_mem_lim * replicas,
                                    'ephemeral_request': container_ephemeral_req * replicas,
                                    'ephemeral_limit': container_ephemeral_lim * replicas,
                                    'pvc_storage': 0,  # PVC is at component level, not container
                                })
                                totals['cpu_request'] += container_cpu_req * replicas
                                totals['cpu_limit'] += container_cpu_lim * replicas
                                totals['memory_request'] += container_mem_req * replicas
                                totals['memory_limit'] += container_mem_lim * replicas
                                totals['ephemeral_request'] += container_ephemeral_req * replicas
                                totals['ephemeral_limit'] += container_ephemeral_lim * replicas
                            
                            # Extract container name (remove quotes if present)
                            container_name_raw = stripped.split(':', 1)[1].strip()
                            container_name = container_name_raw.strip('"\'')
                            container_cpu_req = 0
                            container_mem_req = 0
                            container_cpu_lim = 0
                            container_mem_lim = 0
                            container_ephemeral_req = 0
                            container_ephemeral_lim = 0
                            in_resources = False
                            in_requests = False
                            in_limits = False
                            continue
                    
                    # Track resources section - handle both "resources:" and "resources:            " (with trailing spaces)
                    if in_containers and stripped.startswith('resources:'):
                        in_resources = True
                        resources_indent = indent
                        continue
                    
                    # Track requests/limits
                    if in_resources:
                        if indent <= resources_indent:
                            in_resources = False
                            in_requests = False
                            in_limits = False
                        elif stripped == 'requests:':
                            in_requests = True
                            in_limits = False
                            continue
                        elif stripped == 'limits:':
                            in_limits = True
                            in_requests = False
                            continue
                        elif in_requests or in_limits:
                            if stripped.startswith('cpu:'):
                                val = stripped.split(':', 1)[1].strip()
                                cpu_val, _ = parse_quantity(val)
                                if in_requests:
                                    container_cpu_req = cpu_val
                                else:
                                    container_cpu_lim = cpu_val
                            elif stripped.startswith('memory:'):
                                val = stripped.split(':', 1)[1].strip()
                                _, mem_val = parse_quantity(val)
                                if in_requests:
                                    container_mem_req = mem_val
                                else:
                                    container_mem_lim = mem_val
                            elif stripped.startswith('ephemeral-storage:'):
                                val = stripped.split(':', 1)[1].strip()
                                eph_val = parse_storage(val)
                                if in_requests:
                                    container_ephemeral_req = eph_val
                                else:
                                    container_ephemeral_lim = eph_val
                
                # Save last container
                if container_name and (container_cpu_req or container_mem_req or container_cpu_lim or container_mem_lim or container_ephemeral_req or container_ephemeral_lim):
                    resource_details.append({
                        'kind': kind,
                        'name': name or 'unknown',
                        'namespace': namespace,
                        'container': container_name,
                        'replicas': replicas,
                        'cpu_request': container_cpu_req * replicas,
                        'cpu_limit': container_cpu_lim * replicas,
                        'memory_request': container_mem_req * replicas,
                        'memory_limit': container_mem_lim * replicas,
                        'ephemeral_request': container_ephemeral_req * replicas,
                        'ephemeral_limit': container_ephemeral_lim * replicas,
                        'pvc_storage': pvc_storage,  # Add PVC storage at component level
                    })
                    totals['cpu_request'] += container_cpu_req * replicas
                    totals['cpu_limit'] += container_cpu_lim * replicas
                    totals['memory_request'] += container_mem_req * replicas
                    totals['memory_limit'] += container_mem_lim * replicas
                    totals['ephemeral_request'] += container_ephemeral_req * replicas
                    totals['ephemeral_limit'] += container_ephemeral_lim * replicas
                    totals['pvc_storage'] += pvc_storage
            
            # Handle CronJob separately
            elif kind == 'CronJob':
                # Similar logic but look for jobTemplate.spec.template.spec.containers
                in_job_template = False
                in_containers = False
                in_resources = False
                in_requests = False
                in_limits = False
                container_name = None
                container_cpu_req = 0
                container_mem_req = 0
                container_cpu_lim = 0
                container_mem_lim = 0
                container_ephemeral_req = 0
                container_ephemeral_lim = 0
                resources_indent = 0
                
                for j in range(i, min(doc_end, len(lines))):
                    l = lines[j]
                    indent = get_indent_level(l)
                    stripped = l.strip()
                    
                    if 'jobTemplate:' in stripped:
                        in_job_template = True
                        continue
                    
                    if in_job_template and 'containers:' in stripped:
                        in_containers = True
                        containers_indent = indent
                        continue
                    
                    if in_containers and stripped.startswith('- name:'):
                        expected_container_indent = containers_indent + 2
                        if indent == expected_container_indent or (indent >= expected_container_indent and indent < expected_container_indent + 4):
                            if container_name and (container_cpu_req or container_mem_req or container_cpu_lim or container_mem_lim or container_ephemeral_req or container_ephemeral_lim):
                                resource_details.append({
                                    'kind': kind,
                                    'name': name or 'unknown',
                                    'namespace': namespace,
                                    'container': container_name,
                                    'replicas': 1,  # CronJob runs one at a time
                                    'cpu_request': container_cpu_req,
                                    'cpu_limit': container_cpu_lim,
                                    'memory_request': container_mem_req,
                                    'memory_limit': container_mem_lim,
                                    'ephemeral_request': container_ephemeral_req,
                                    'ephemeral_limit': container_ephemeral_lim,
                                    'pvc_storage': 0,
                                })
                                totals['cpu_request'] += container_cpu_req
                                totals['cpu_limit'] += container_cpu_lim
                                totals['memory_request'] += container_mem_req
                                totals['memory_limit'] += container_mem_lim
                                totals['ephemeral_request'] += container_ephemeral_req
                                totals['ephemeral_limit'] += container_ephemeral_lim
                            
                            container_name_raw = stripped.split(':', 1)[1].strip()
                            container_name = container_name_raw.strip('"\'')
                            container_cpu_req = 0
                            container_mem_req = 0
                            container_cpu_lim = 0
                            container_mem_lim = 0
                            container_ephemeral_req = 0
                            container_ephemeral_lim = 0
                            in_resources = False
                            in_requests = False
                            in_limits = False
                        continue
                    
                    if in_containers and stripped.startswith('resources:'):
                        in_resources = True
                        resources_indent = indent
                        continue
                    
                    if in_resources:
                        if indent <= resources_indent:
                            in_resources = False
                            in_requests = False
                            in_limits = False
                        elif stripped == 'requests:':
                            in_requests = True
                            in_limits = False
                            continue
                        elif stripped == 'limits:':
                            in_limits = True
                            in_requests = False
                            continue
                        elif in_requests or in_limits:
                            if stripped.startswith('cpu:'):
                                val = stripped.split(':', 1)[1].strip()
                                cpu_val, _ = parse_quantity(val)
                                if in_requests:
                                    container_cpu_req = cpu_val
                                else:
                                    container_cpu_lim = cpu_val
                            elif stripped.startswith('memory:'):
                                val = stripped.split(':', 1)[1].strip()
                                _, mem_val = parse_quantity(val)
                                if in_requests:
                                    container_mem_req = mem_val
                                else:
                                    container_mem_lim = mem_val
                            elif stripped.startswith('ephemeral-storage:'):
                                val = stripped.split(':', 1)[1].strip()
                                eph_val = parse_storage(val)
                                if in_requests:
                                    container_ephemeral_req = eph_val
                                else:
                                    container_ephemeral_lim = eph_val
                
                if container_name and (container_cpu_req or container_mem_req or container_cpu_lim or container_mem_lim or container_ephemeral_req or container_ephemeral_lim):
                    resource_details.append({
                        'kind': kind,
                        'name': name or 'unknown',
                        'namespace': namespace,
                        'container': container_name,
                        'replicas': 1,
                        'cpu_request': container_cpu_req,
                        'cpu_limit': container_cpu_lim,
                        'memory_request': container_mem_req,
                        'memory_limit': container_mem_lim,
                        'ephemeral_request': container_ephemeral_req,
                        'ephemeral_limit': container_ephemeral_lim,
                        'pvc_storage': 0,
                    })
                    totals['cpu_request'] += container_cpu_req
                    totals['cpu_limit'] += container_cpu_lim
                    totals['memory_request'] += container_mem_req
                    totals['memory_limit'] += container_mem_lim
                    totals['ephemeral_request'] += container_ephemeral_req
                    totals['ephemeral_limit'] += container_ephemeral_lim
            
            i = doc_end
        else:
            i += 1
    
    return totals, resource_details


def format_cpu(millicores):
    """Format CPU millicores to readable format."""
    if millicores >= 1000:
        return f"{millicores / 1000:.2f} cores"
    return f"{millicores:.0f}m"


def format_memory(mib):
    """Format memory MiB to readable format."""
    if mib >= 1024:
        return f"{mib / 1024:.2f} GiB"
    return f"{mib:.0f} MiB"


def format_storage(gib):
    """Format storage GiB to readable format."""
    if gib == 0:
        return "-"
    if gib >= 1:
        return f"{gib:.2f} GiB"
    return f"{gib * 1024:.0f} MiB"


def aggregate_by_component(details):
    """Aggregate resources by component/service name."""
    component_totals = defaultdict(lambda: {
        'cpu_request': 0,
        'cpu_limit': 0,
        'memory_request': 0,
        'memory_limit': 0,
        'ephemeral_request': 0,
        'ephemeral_limit': 0,
        'pvc_storage': 0,
        'replicas': set(),
        'kinds': set(),
        'containers': []
    })
    
    for detail in details:
        # Extract component name (remove release name prefix if present)
        name = detail['name']
        # Try to extract meaningful component name
        component_name = name
        if 'truefoundry-' in name:
            component_name = name.replace('truefoundry-', '')
        
        comp = component_totals[component_name]
        comp['cpu_request'] += detail['cpu_request']
        comp['cpu_limit'] += detail['cpu_limit']
        comp['memory_request'] += detail['memory_request']
        comp['memory_limit'] += detail['memory_limit']
        comp['ephemeral_request'] += detail.get('ephemeral_request', 0)
        comp['ephemeral_limit'] += detail.get('ephemeral_limit', 0)
        comp['pvc_storage'] += detail.get('pvc_storage', 0)
        comp['replicas'].add(detail['replicas'])
        comp['kinds'].add(detail['kind'])
        comp['containers'].append({
            'name': detail['container'],
            'replicas': detail['replicas'],
            'cpu_request': detail['cpu_request'],
            'cpu_limit': detail['cpu_limit'],
            'memory_request': detail['memory_request'],
            'memory_limit': detail['memory_limit'],
            'ephemeral_request': detail.get('ephemeral_request', 0),
            'ephemeral_limit': detail.get('ephemeral_limit', 0),
        })
    
    # Convert sets to sorted lists for display
    result = {}
    for name, comp in component_totals.items():
        result[name] = {
            'cpu_request': comp['cpu_request'],
            'cpu_limit': comp['cpu_limit'],
            'memory_request': comp['memory_request'],
            'memory_limit': comp['memory_limit'],
            'ephemeral_request': comp['ephemeral_request'],
            'ephemeral_limit': comp['ephemeral_limit'],
            'pvc_storage': comp['pvc_storage'],
            'replicas': sorted(comp['replicas']),
            'kinds': sorted(comp['kinds']),
            'containers': comp['containers'],
        }
    
    return result


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/calculate-resources.py <path-to-yaml-file> [--detailed|--verbose|--markdown]")
        print("\nFlags:")
        print("  --detailed  Show per-container breakdown")
        print("  --verbose   Show per-component/service aggregation")
        print("  --markdown  Output as markdown table (for documentation)")
        sys.exit(1)
    
    file_path = sys.argv[1]
    show_detailed = '--detailed' in sys.argv
    show_verbose = '--verbose' in sys.argv
    show_markdown = '--markdown' in sys.argv
    
    if not Path(file_path).exists():
        print(f"Error: File not found: {file_path}")
        sys.exit(1)
    
    totals, details = process_yaml_file(file_path)
    
    # Markdown output mode
    if show_markdown:
        components = aggregate_by_component(details)
        
        # Print component table
        print("| Component | Kind | Replicas | CPU Req | CPU Lim | Mem Req | Mem Lim | Eph Req | Eph Lim | PVC |")
        print("|-----------|------|----------|---------|---------|---------|---------|---------|---------|-----|")
        
        for comp_name in sorted(components.keys()):
            comp = components[comp_name]
            kinds_str = '/'.join(comp['kinds'])
            replicas_str = '/'.join(str(r) for r in comp['replicas'])
            print(f"| {comp_name} | {kinds_str} | {replicas_str} | "
                  f"{format_cpu(comp['cpu_request'])} | {format_cpu(comp['cpu_limit'])} | "
                  f"{format_memory(comp['memory_request'])} | {format_memory(comp['memory_limit'])} | "
                  f"{format_storage(comp['ephemeral_request'])} | {format_storage(comp['ephemeral_limit'])} | "
                  f"{format_storage(comp['pvc_storage'])} |")
        
        # Print totals row
        print(f"| **TOTAL** | - | - | "
              f"**{format_cpu(totals['cpu_request'])}** | **{format_cpu(totals['cpu_limit'])}** | "
              f"**{format_memory(totals['memory_request'])}** | **{format_memory(totals['memory_limit'])}** | "
              f"**{format_storage(totals['ephemeral_request'])}** | **{format_storage(totals['ephemeral_limit'])}** | "
              f"**{format_storage(totals['pvc_storage'])}** |")
        return
    
    print(f"Analyzing resources from: {file_path}\n")
    
    # Print summary
    print("=" * 100)
    print("RESOURCE SUMMARY")
    print("=" * 100)
    print(f"\nCPU Requests:           {format_cpu(totals['cpu_request']):>15} ({totals['cpu_request']:.0f}m)")
    print(f"CPU Limits:             {format_cpu(totals['cpu_limit']):>15} ({totals['cpu_limit']:.0f}m)")
    print(f"Memory Requests:        {format_memory(totals['memory_request']):>15} ({totals['memory_request']:.0f} MiB)")
    print(f"Memory Limits:          {format_memory(totals['memory_limit']):>15} ({totals['memory_limit']:.0f} MiB)")
    print(f"Ephemeral Storage Req:  {format_storage(totals['ephemeral_request']):>15}")
    print(f"Ephemeral Storage Lim:  {format_storage(totals['ephemeral_limit']):>15}")
    print(f"PVC Storage:            {format_storage(totals['pvc_storage']):>15}")
    
    # Print verbose component breakdown
    if show_verbose:
        components = aggregate_by_component(details)
        print("\n" + "=" * 180)
        print("COMPONENT/SERVICE BREAKDOWN (Total = per-pod × replicas)")
        print("=" * 180)
        print(f"\n{'Component':<30} {'Kind(s)':<12} {'Repl':<6} {'CPU Req':<11} {'CPU Lim':<11} {'Mem Req':<11} {'Mem Lim':<11} {'Eph Req':<11} {'Eph Lim':<11} {'PVC':<11}")
        print("-" * 180)
        
        for comp_name in sorted(components.keys()):
            comp = components[comp_name]
            kinds_str = ', '.join(comp['kinds'])
            # Format replicas - show the count(s)
            replicas_str = ', '.join(str(r) for r in comp['replicas'])
            print(f"{comp_name:<30} {kinds_str:<12} {replicas_str:<6} "
                  f"{format_cpu(comp['cpu_request']):<11} {format_cpu(comp['cpu_limit']):<11} "
                  f"{format_memory(comp['memory_request']):<11} {format_memory(comp['memory_limit']):<11} "
                  f"{format_storage(comp['ephemeral_request']):<11} {format_storage(comp['ephemeral_limit']):<11} "
                  f"{format_storage(comp['pvc_storage']):<11}")
            
            # Show container details for this component
            if len(comp['containers']) > 1:
                for container in comp['containers']:
                    print(f"  └─ {container['name']:<26} {'':<12} {container['replicas']:<6} "
                          f"{format_cpu(container['cpu_request']):<11} {format_cpu(container['cpu_limit']):<11} "
                          f"{format_memory(container['memory_request']):<11} {format_memory(container['memory_limit']):<11} "
                          f"{format_storage(container['ephemeral_request']):<11} {format_storage(container['ephemeral_limit']):<11} "
                          f"{'':<11}")
    
    # Print detailed breakdown
    if show_detailed:
        print("\n" + "=" * 180)
        print("DETAILED BREAKDOWN (Per Container)")
        print("=" * 180)
        print(f"\n{'Kind':<12} {'Name':<35} {'Container':<20} {'Repl':<6} {'CPU Req':<11} {'CPU Lim':<11} {'Mem Req':<11} {'Mem Lim':<11} {'Eph Req':<11} {'Eph Lim':<11} {'PVC':<11}")
        print("-" * 180)
        
        for detail in sorted(details, key=lambda x: (x['kind'], x['name'], x['container'])):
            print(f"{detail['kind']:<12} {detail['name']:<35} {detail['container']:<20} {detail['replicas']:<6} "
                  f"{format_cpu(detail['cpu_request']):<11} {format_cpu(detail['cpu_limit']):<11} "
                  f"{format_memory(detail['memory_request']):<11} {format_memory(detail['memory_limit']):<11} "
                  f"{format_storage(detail.get('ephemeral_request', 0)):<11} {format_storage(detail.get('ephemeral_limit', 0)):<11} "
                  f"{format_storage(detail.get('pvc_storage', 0)):<11}")
    
    print("\n" + "=" * 100)


if __name__ == '__main__':
    main()
