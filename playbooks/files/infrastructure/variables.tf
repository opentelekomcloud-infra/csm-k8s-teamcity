variable "username" {}
variable "password" {}
variable "domain_name" {}
variable "tenant_name" {}
variable "prefix" {
  default = "cluster"
}
variable "addr_3_octets" {
  default = "192.168.0"
}
variable "region" {
  default = "eu-de"
}
variable "ecs_flavor" {
  default = "s2.large.2"
}
variable "ecs_image" {
  default = "Standard_Debian_10_latest"
}
variable "availability_zone" {
  default = "eu-de-03"
}
variable "psql_version" {
  default = "10"
}
variable "psql_port" {
  default = "8669"
}
variable "psql_password" {
  default = "qwerty12345!"
}
variable "key_name" {
  default = "key"
}
variable "public_key" {
  default = ""
}

# kube settings
variable "cluster_name" {}

# 0|1 bastion nodes
variable "number_of_bastions" {}

# standalone etcds
variable "number_of_etcd" {}

# masters
variable "number_of_k8s_masters" {}

# nodes
variable "number_of_k8s_nodes" {}

variable "number_of_k8s_nodes_no_floating_ip" {}

# networking

variable "bastion_allowed_remote_ips" {
  description = "An array of CIDRs allowed to SSH to hosts"
  default     = ["0.0.0.0/0"]
}

variable "master_allowed_remote_ips" {
  description = "An array of CIDRs allowed to access API of masters"
  default     = ["0.0.0.0/0"]
}

variable "k8s_allowed_remote_ips" {
  description = "An array of CIDRs allowed to SSH to hosts"
  default     = ["0.0.0.0/0"]
}

variable "k8s_allowed_egress_ips" {
  description = "An array of CIDRs allowed for egress traffic"
  default     = ["0.0.0.0/0"]
}

variable "worker_allowed_ports" {
  default = [
    {
      protocol         = "tcp"
      port_range_min   = 30000
      port_range_max   = 32767
      remote_ip_prefix = "0.0.0.0/0"
    },
  ]
}

variable "use_access_ip" {
  default = 1
}

variable "use_server_groups" {
  default = false
}

variable "floatingip_pool" {
  description = "name of the floating ip pool to use"
  default     = "admin_external_net"
}

variable "network_name" {
  description = "name of the internal network to use"
  default     = "internal"
}