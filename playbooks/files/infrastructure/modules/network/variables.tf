variable "subnet_cidr" {}
variable "cluster_name" {}
variable "network_name" {}

variable "dns_nameservers" {
  description = "An array of DNS name server names used by hosts in this subnet."
  default     = []
}

variable "use_neutron" {
  description = "Use neutron"
  default     = 1
}