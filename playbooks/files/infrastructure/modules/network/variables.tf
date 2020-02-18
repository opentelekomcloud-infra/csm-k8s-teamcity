variable "subnet_cidr" {}
variable "cluster_name" {}
variable "network_name" {}
variable "network_dns_domain" {
  description = "dns_domain for the internal network"
  type        = "string"
  default     = null
}

variable "dns_nameservers" {
  description = "An array of DNS name server names used by hosts in this subnet."
  type        = "list"
  default     = []
}

variable "use_neutron" {
  description = "Use neutron"
  default     = 1
}