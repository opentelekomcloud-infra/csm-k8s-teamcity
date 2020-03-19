# K8s cluster in Open Telekom Cloud infrastructure
based on https://github.com/kubernetes-sigs/kubespray

T-Systems solution for building ready to use cluster in Open Telekom Cloud infrastructure and running Teamcity server in cluster as example

This repository contains:
 - playbook and terraform scripts for creating/destroying cluster infrastructure
 - playbook for cluster configuration
 - playbook for run teamcity server in cluster with bastion as loadbalancer server pointed to teamcity_service pod

### Requirements
Existing scripts were checked to be working with:
 - Terraform 0.12
 - Ansible 2.8 (Python 3.7)

### Build
Review and change parameters under ``inventory/prod/group_vars``
cat inventory/mycluster/group_vars/all/all.yml
cat inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml

Also need to change cluster parameters``playbooks/files/infrastructure/terraform.tfvars``

Infrastructure build can be triggered using `ansible-playbook -i inventory/prod/ playbooks/build_k8s_infrastructure.yml`
This playbook installs all required roles, packages and prepares inventory files.

Then deploy kubernetes with Ansible Playbook `ansible-playbook -i inventory/prod/ playbooks/cluster.yml`

**!NB** Terraform is using OBS for storing remote state
Following variables have to be set: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

Also terrafor using next variables for build:
```
export AWS_ACCESS_KEY_ID=my_key
export AWS_SECRET_ACCESS_KEY=my_secret
export TF_VAR_tenant_name=my_tenant
export TF_VAR_domain_name=my_domain
export TF_VAR_username=my_username
export TF_VAR_password=my_password
export TF_VAR_psql_password=psql_password
```
### Teamcity server with agent
For example of using kubernetes you can run `ansible-playbook -i inventory/prod/ playbooks/teamcity-k8s.yml`
This playbook creates server pod, agent pod and expose server with service. Then configures bastion server as loadbalancer server pointed to exposed port. After that you can access teamcity server through bastion elastic ip.

