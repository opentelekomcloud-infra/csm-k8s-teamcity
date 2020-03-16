#!/usr/bin/env python3
import json
import os
import sys
from argparse import ArgumentParser

import yaml

__version__ = '0.4'


def parse_params():
    default_root = os.environ.get('TERRAFORM_STATE_ROOT',
                                  os.path.abspath(os.path.join(os.path.dirname(__file__),
                                                               '..', '..', )))

    parser = ArgumentParser(description='Create Ansible inventory from Terraform state for OpenTelekomCloud')
    parser.add_argument('--name', default='cluster')
    parser.add_argument('--version', '-v', action='store_true', help='Show version')
    parser.add_argument('--root',
                        default=default_root,
                        help='custom root to search for `.tfstate`s in')
    args = parser.parse_args()
    if args.name is None:
        args.name = args.state
    return args

def read_state(state_file) -> dict:
    """Load Terraform state from tfstate file to dict"""
    with open(state_file) as s_file:
        return json.load(s_file)


def main():
    args = parse_params()
    if args.version:
        print(__version__)
        sys.exit(0)
    generate_inventory(args)
    generate_variables(args)

def tfstate(root=None):
    root = root or os.getcwd()
    for dirpath, _, filenames in os.walk(root):
        for name in filenames:
            if os.path.splitext(name)[-1] == '.tfstate':
                return dirpath + '/' + name

def generate_inventory(args):
    inv_output = {
        'all': {
            'hosts': {},
            'children': {}
        }
    }
    hosts = inv_output['all']['hosts']
    children = inv_output['all']['children']
    for name, attributes in get_ecs_instances(args.root):
        hosts[name] = attributes
    if hosts:
        root_path = args.root
        path = f'{root_path}/inventory/prod/{args.name}.yml'
        with open(path, 'w+') as file:
            file.write(yaml.safe_dump(inv_output, default_flow_style=False))
        print(f'File written to: {path}')
    else:
        print('Nothing to write')

def generate_variables(args):
    group_vars = get_variables(args.root)
    output = {
        'db_address': group_vars['db_address']['value'],
        'db_password': group_vars['db_password']['value'],
        'db_username': group_vars['db_username']['value'],
        'master_fips': group_vars['k8s_master_fips']['value'],
        'bastion_fips': group_vars['bastion_fips']['value']
    }
    root_path = args.root
    path = f'{root_path}/inventory/prod/group_vars/all/additional.yml'
    with open(path, 'w+') as file:
        file.write(yaml.safe_dump(output, default_flow_style=False))
    print(f'File written to: {path}')

def get_variables(root):
    tf_state = read_state(tfstate(root))
    return tf_state['outputs']

def get_ecs_instances(root):
    name = ''
    m_count = 1
    n_count = 1
    tf_state = read_state(tfstate(root))
    for resource in tf_state['resources']:
        if resource['type'] == 'opentelekomcloud_compute_instance_v2' and 'bastion' not in resource['name']:
            for instance in resource['instances']:
                tf_attrib = instance['attributes']
                if 'node' in tf_attrib['name']:
                    name = 'node' + str(n_count)
                    n_count += 1
                elif 'master' in tf_attrib['name']:
                    name = 'master' + str(m_count)
                    m_count += 1
                else:
                    name = tf_attrib['name']
                attributes = {
                    'ansible_host': tf_attrib['access_ip_v4'],
                    'ansible_ssh_user': 'linux',
                }

                yield name, attributes

    yield 'bastion1',  {
        'ansible_host': tf_state['outputs']['bastion_fips']['value'][0],
        'ansible_ssh_user': 'linux'
    }

if __name__ == '__main__':
    main()
