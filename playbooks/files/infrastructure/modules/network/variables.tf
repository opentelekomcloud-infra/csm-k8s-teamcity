variable "subnet_cidr" {}
variable "cluster_name" {}
variable "network_name" {}

variable "dns_nameservers" {
  description = "An array of DNS name server names used by hosts in this subnet."
  default     = ["100.125.4.25", "100.125.129.199"]
}

variable "use_neutron" {
  description = "Use neutron"
  default     = 1
}