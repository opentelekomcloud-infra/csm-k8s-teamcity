variable "number_of_k8s_masters" {}

variable "number_of_k8s_masters_no_etcd" {}

variable "number_of_k8s_nodes" {}

variable "floatingip_pool" {}

variable "number_of_bastions" {}

variable "router_id" {
  default = ""
}