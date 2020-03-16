resource "opentelekomcloud_networking_secgroup_v2" "k8s_master" {
  name                 = "${var.cluster_name}-master"
  description          = "${var.cluster_name} - Kubernetes Master"
  delete_default_rules = true
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "k8s_master" {
  count             = length(var.master_allowed_remote_ips)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "6443"
  port_range_max    = "6443"
  remote_ip_prefix  = var.master_allowed_remote_ips[count.index]
  security_group_id = opentelekomcloud_networking_secgroup_v2.k8s_master.id
}

resource "opentelekomcloud_networking_secgroup_v2" "bastion" {
  name                 = "${var.cluster_name}-bastion"
  count                = var.number_of_bastions != "" ? 1 : 0
  description          = "${var.cluster_name} - Bastion Server"
  delete_default_rules = true
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "bastion" {
  count             = var.number_of_bastions != "" ? length(var.bastion_allowed_remote_ips) : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "22"
  port_range_max    = "22"
  remote_ip_prefix  = var.bastion_allowed_remote_ips[count.index]
  security_group_id = opentelekomcloud_networking_secgroup_v2.bastion[0].id
}

resource "opentelekomcloud_networking_secgroup_v2" "web" {
  name                 = "${var.cluster_name}-web"
  count                = var.number_of_bastions != "" ? 1 : 0
  description          = "${var.cluster_name} - Web Server"
  delete_default_rules = true
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "web" {
  count             = var.number_of_bastions != "" ? length(var.bastion_allowed_remote_ips) : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "80"
  port_range_max    = "80"
  remote_ip_prefix  = var.bastion_allowed_remote_ips[count.index]
  security_group_id = opentelekomcloud_networking_secgroup_v2.web[0].id
}

resource "opentelekomcloud_networking_secgroup_v2" "k8s" {
  name                 = "${var.cluster_name}-kuber"
  description          = "${var.cluster_name} - Kubernetes"
  delete_default_rules = true
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "k8s" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = opentelekomcloud_networking_secgroup_v2.k8s.id
  security_group_id = opentelekomcloud_networking_secgroup_v2.k8s.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "k8s_allowed_remote_ips" {
  count             = length(var.k8s_allowed_remote_ips)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "22"
  port_range_max    = "22"
  remote_ip_prefix  = var.k8s_allowed_remote_ips[count.index]
  security_group_id = opentelekomcloud_networking_secgroup_v2.k8s.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "egress" {
  count             = length(var.k8s_allowed_egress_ips)
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = var.k8s_allowed_egress_ips[count.index]
  security_group_id = opentelekomcloud_networking_secgroup_v2.k8s.id
}

resource "opentelekomcloud_networking_secgroup_v2" "worker" {
  name                 = "${var.cluster_name}-worker"
  description          = "${var.cluster_name} - Kubernetes worker nodes"
  delete_default_rules = true
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "worker" {
  count             = length(var.worker_allowed_ports)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = lookup(var.worker_allowed_ports[count.index], "protocol", "tcp")
  port_range_min    = lookup(var.worker_allowed_ports[count.index], "port_range_min")
  port_range_max    = lookup(var.worker_allowed_ports[count.index], "port_range_max")
  remote_ip_prefix  = lookup(var.worker_allowed_ports[count.index], "remote_ip_prefix", "0.0.0.0/0")
  security_group_id = opentelekomcloud_networking_secgroup_v2.worker.id
}

resource "opentelekomcloud_compute_servergroup_v2" "k8s_master" {
  count    = "%{if var.use_server_groups}1%{else}0%{endif}"
  name     = "k8s-master-srvgrp"
  policies = ["anti-affinity"]
}

resource "opentelekomcloud_compute_servergroup_v2" "k8s_node" {
  count    = "%{if var.use_server_groups}1%{else}0%{endif}"
  name     = "k8s-node-srvgrp"
  policies = ["anti-affinity"]
}

resource "opentelekomcloud_compute_servergroup_v2" "k8s_etcd" {
  count    = "%{if var.use_server_groups}1%{else}0%{endif}"
  name     = "k8s-etcd-srvgrp"
  policies = ["anti-affinity"]
}