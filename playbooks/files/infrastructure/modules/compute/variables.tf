variable "ecs_image" {}

variable "key_name" {}

variable "public_key" {}

variable "cluster_name" {}

variable "master_allowed_remote_ips" {}

variable "number_of_bastions" {}

variable "number_of_k8s_masters" {}

variable "number_of_k8s_nodes_no_floating_ip" {}

variable "number_of_etcd" {}

variable "number_of_k8s_nodes" {}

variable "bastion_allowed_remote_ips" {}

variable "k8s_allowed_remote_ips" {}

variable "k8s_allowed_egress_ips" {}

variable "worker_allowed_ports" {}

variable "use_server_groups" {}

variable "ecs_flavor" {}

variable "network_id" {}

variable "network_name" {}

variable "use_access_ip" {}

variable "availability_zone" {}

variable "bastion_fips" {}

variable "k8s_node_fips" {}

variable "k8s_master_fips" {}

variable "bastion_root_volume_size_in_gb" {
  default = 5
}
variable "master_root_volume_size_in_gb" {
  default = 5
}
variable "node_root_volume_size_in_gb" {
  default = 5
}
variable "etcd_root_volume_size_in_gb" {
  default = 5
}
variable "ssh_user" {
  default = "linux"
}
variable "ecs_image_gfs" {
  default = ""
}
variable "supplementary_master_groups" {
  default = ""
}
variable "supplementary_node_groups" {
  default = ""
}
