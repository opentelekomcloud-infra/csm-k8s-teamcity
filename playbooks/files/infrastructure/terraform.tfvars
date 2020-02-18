prefix            = "csm"
addr_3_octets     = "192.168.0"
region            = "eu-de"
availability_zone = "eu-de-03"
ecs_flavor        = "s2.large.2"
ecs_image         = "Standard_Debian_10_latest"

# plsq settings
psql_version = "10"
psql_port    = 8669

# kube settings
cluster_name = "k8s"

# 0|1 bastion nodes
number_of_bastions = 1

# standalone etcds
number_of_etcd = 0

# masters
number_of_k8s_masters = 1

# nodes
number_of_k8s_nodes                = 0
number_of_k8s_nodes_no_floating_ip = 2

# networking
bastion_allowed_remote_ips = ["0.0.0.0/0"]