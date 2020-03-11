module "network" {
  source = "./modules/network"

  cluster_name = "${var.prefix}_${var.cluster_name}"
  subnet_cidr  = "${var.addr_3_octets}.0/24"
  network_name = var.network_name
}

module "ips" {
  source = "./modules/ips"

  number_of_k8s_masters = var.number_of_k8s_masters
  number_of_k8s_nodes   = var.number_of_k8s_nodes
  floatingip_pool       = var.floatingip_pool
  number_of_bastions    = var.number_of_bastions
  router_id             = module.network.router_id
}

module "compute" {
  source = "./modules/compute"

  ecs_image                          = var.ecs_image
  key_name                           = "${var.prefix}_${var.key_name}"
  public_key                         = var.public_key
  cluster_name                       = "${var.prefix}_${var.cluster_name}"
  master_allowed_remote_ips          = var.master_allowed_remote_ips
  bastion_allowed_remote_ips         = var.bastion_allowed_remote_ips
  k8s_allowed_remote_ips             = var.k8s_allowed_remote_ips
  k8s_allowed_egress_ips             = var.k8s_allowed_egress_ips
  worker_allowed_ports               = var.worker_allowed_ports
  use_server_groups                  = var.use_server_groups
  ecs_flavor                         = var.ecs_flavor
  use_access_ip                      = var.use_access_ip
  bastion_fips                       = module.ips.bastion_fips
  k8s_node_fips                      = module.ips.k8s_node_fips
  k8s_master_fips                    = module.ips.k8s_master_fips
  network_id                         = module.network.router_id
  network_name                       = var.network_name
  availability_zone                  = var.availability_zone
  number_of_bastions                 = var.number_of_bastions
  number_of_etcd                     = var.number_of_etcd
  number_of_k8s_masters              = var.number_of_k8s_masters
  number_of_k8s_nodes                = var.number_of_k8s_nodes
  number_of_k8s_nodes_no_floating_ip = var.number_of_k8s_nodes_no_floating_ip
}

module "postgresql" {
  source = "./modules/postgresql"

  availability_zone = var.availability_zone
  instance_name     = "team_city_psql_db"

  network_id  = module.network.router_id
  subnet_id   = module.network.network_id
  subnet_cidr = "${var.addr_3_octets}.0/24"

  psql_version  = var.psql_version
  psql_port     = var.psql_port
  psql_password = var.psql_password
}

output "db_password" {
  value     = module.postgresql.db_password
  sensitive = true
}
output "db_username" {
  value = module.postgresql.db_username
}
output "db_address" {
  value = module.postgresql.db_address
}

output "private_subnet_id" {
  value = module.network.subnet_id
}

output "floating_network_id" {
  value = module.network.external_network.id
}

output "router_id" {
  value = module.network.router_id
}

output "k8s_master_fips" {
  value = module.ips.k8s_master_fips
}

output "k8s_node_fips" {
  value = module.ips.k8s_node_fips
}

output "bastion_fips" {
  value = module.ips.bastion_fips
}