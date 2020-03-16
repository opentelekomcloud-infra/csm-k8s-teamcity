data "opentelekomcloud_images_image_v2" "vm_image" {
  name        = var.ecs_image
  most_recent = true
}

resource "opentelekomcloud_compute_keypair_v2" "k8s" {
  name       = var.key_name
  public_key = var.public_key
}

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name              = "${var.cluster_name}-bastion-${count.index + 1}"
  count             = var.bastion_root_volume_size_in_gb > 0 ? var.number_of_bastions : 0
  availability_zone = var.availability_zone
  image_name        = var.ecs_image
  flavor_id         = var.ecs_flavor
  key_pair          = opentelekomcloud_compute_keypair_v2.k8s.name
  user_data         = file("${path.module}/first_boot.sh")

  block_device {
    uuid                  = data.opentelekomcloud_images_image_v2.vm_image.id
    source_type           = "image"
    volume_size           = var.master_root_volume_size_in_gb
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = var.network_name
  }

  security_groups = [
    opentelekomcloud_networking_secgroup_v2.k8s.name,
    element(opentelekomcloud_networking_secgroup_v2.bastion.*.name, count.index),
    element(opentelekomcloud_networking_secgroup_v2.web.*.name, count.index),
  ]

  metadata = {
    ssh_user         = var.ssh_user
    kubespray_groups = "bastion"
    depends_on       = var.network_id
    use_access_ip    = var.use_access_ip
  }

  provisioner "local-exec" {
    command = "sed s/USER/${var.ssh_user}/ ./bastion_template.txt | sed s/BASTION_ADDRESS/${var.bastion_fips[0]}/ > no-floating.yml"
  }
}

resource "opentelekomcloud_compute_instance_v2" "k8s_master" {
  name              = "${var.cluster_name}-master-${count.index + 1}"
  count             = var.master_root_volume_size_in_gb > 0 ? var.number_of_k8s_masters : 0
  availability_zone = var.availability_zone
  image_name        = var.ecs_image
  flavor_id         = var.ecs_flavor
  key_pair          = opentelekomcloud_compute_keypair_v2.k8s.name
  user_data         = file("${path.module}/first_boot.sh")

  block_device {
    uuid                  = data.opentelekomcloud_images_image_v2.vm_image.id
    source_type           = "image"
    volume_size           = var.master_root_volume_size_in_gb
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = var.network_name
  }

  security_groups = [
    opentelekomcloud_networking_secgroup_v2.k8s_master.name,
    opentelekomcloud_networking_secgroup_v2.k8s.name,
  ]

  dynamic "scheduler_hints" {
    for_each = var.use_server_groups ? [opentelekomcloud_compute_servergroup_v2.k8s_master[0]] : []
    content {
      group = opentelekomcloud_compute_servergroup_v2.k8s_master[0].id
    }
  }

  metadata = {
    ssh_user         = var.ssh_user
    kubespray_groups = "etcd,kube-master,${var.supplementary_master_groups},k8s-cluster,vault"
    depends_on       = var.network_id
    use_access_ip    = var.use_access_ip
  }

  provisioner "local-exec" {
    command = "sed s/USER/${var.ssh_user}/ ./bastion_template.txt | sed s/BASTION_ADDRESS/${element(concat(var.bastion_fips, var.k8s_master_fips), 0)}/ > no-floating.yml"
  }
}

resource "opentelekomcloud_compute_instance_v2" "k8s_node_no_floating_ip" {
  name              = "${var.cluster_name}-node-nf-${count.index + 1}"
  count             = var.node_root_volume_size_in_gb > 0 ? var.number_of_k8s_nodes_no_floating_ip : 0
  availability_zone = var.availability_zone
  image_name        = var.ecs_image
  flavor_id         = var.ecs_flavor
  key_pair          = opentelekomcloud_compute_keypair_v2.k8s.name
  user_data         = file("${path.module}/first_boot.sh")

  block_device {
    uuid                  = data.opentelekomcloud_images_image_v2.vm_image.id
    source_type           = "image"
    volume_size           = var.node_root_volume_size_in_gb
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = var.network_name
  }

  security_groups = [
    opentelekomcloud_networking_secgroup_v2.k8s.name,
    opentelekomcloud_networking_secgroup_v2.worker.name,
  ]

  dynamic "scheduler_hints" {
    for_each = var.use_server_groups ? [opentelekomcloud_compute_servergroup_v2.k8s_node[0]] : []
    content {
      group = opentelekomcloud_compute_servergroup_v2.k8s_node[0].id
    }
  }

  metadata = {
    ssh_user         = var.ssh_user
    kubespray_groups = "kube-node,k8s-cluster,no-floating,${var.supplementary_node_groups}"
    depends_on       = var.network_id
    use_access_ip    = var.use_access_ip
  }
}

resource "opentelekomcloud_compute_instance_v2" "etcd" {
  name              = "${var.cluster_name}-etcd-${count.index + 1}"
  count             = var.etcd_root_volume_size_in_gb > 0 ? var.number_of_etcd : 0
  availability_zone = var.availability_zone
  image_name        = var.ecs_image
  flavor_id         = var.ecs_flavor
  key_pair          = opentelekomcloud_compute_keypair_v2.k8s.name
  user_data         = file("${path.module}/first_boot.sh")

  block_device {
    uuid                  = data.opentelekomcloud_images_image_v2.vm_image.id
    source_type           = "image"
    volume_size           = var.etcd_root_volume_size_in_gb
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = var.network_name
  }

  security_groups = [
  opentelekomcloud_networking_secgroup_v2.k8s.name]

  dynamic "scheduler_hints" {
    for_each = var.use_server_groups ? [opentelekomcloud_compute_servergroup_v2.k8s_etcd[0]] : []
    content {
      group = opentelekomcloud_compute_servergroup_v2.k8s_etcd[0].id
    }
  }

  metadata = {
    ssh_user         = var.ssh_user
    kubespray_groups = "etcd,vault,no-floating"
    depends_on       = var.network_id
    use_access_ip    = var.use_access_ip
  }
}

resource "opentelekomcloud_compute_instance_v2" "k8s_node" {
  name              = "${var.cluster_name}-node-${count.index + 1}"
  count             = var.node_root_volume_size_in_gb > 0 ? var.number_of_k8s_nodes : 0
  availability_zone = var.availability_zone
  image_name        = var.ecs_image
  flavor_id         = var.ecs_flavor
  key_pair          = opentelekomcloud_compute_keypair_v2.k8s.name
  user_data         = file("${path.module}/first_boot.sh")

  block_device {
    uuid                  = data.opentelekomcloud_images_image_v2.vm_image.id
    source_type           = "image"
    volume_size           = var.node_root_volume_size_in_gb
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = var.network_name
  }

  security_groups = [
    opentelekomcloud_networking_secgroup_v2.k8s.name,
    opentelekomcloud_networking_secgroup_v2.worker.name,
  ]

  dynamic "scheduler_hints" {
    for_each = var.use_server_groups ? [opentelekomcloud_compute_servergroup_v2.k8s_node[0]] : []
    content {
      group = opentelekomcloud_compute_servergroup_v2.k8s_node[0].id
    }
  }

  metadata = {
    ssh_user         = var.ssh_user
    kubespray_groups = "kube-node,k8s-cluster,${var.supplementary_node_groups}"
    depends_on       = var.network_id
    use_access_ip    = var.use_access_ip
  }

  provisioner "local-exec" {
    command = "sed s/USER/${var.ssh_user}/ ./infrastructure/bastion_template.txt | sed s/BASTION_ADDRESS/${element(concat(var.bastion_fips, var.k8s_node_fips), 0)}/ > no-floating.yml"
  }
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "bastion" {
  count       = var.bastion_root_volume_size_in_gb > 0 ? var.number_of_bastions : 0
  floating_ip = var.bastion_fips[count.index]
  instance_id = element(opentelekomcloud_compute_instance_v2.bastion.*.id, count.index)
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "k8s_master" {
  count       = var.master_root_volume_size_in_gb > 0 ? var.number_of_k8s_masters : 0
  instance_id = element(opentelekomcloud_compute_instance_v2.k8s_master.*.id, count.index)
  floating_ip = var.k8s_master_fips[count.index]
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "k8s_node" {
  count       = var.node_root_volume_size_in_gb == 0 ? var.number_of_k8s_nodes : 0
  floating_ip = var.k8s_node_fips[count.index]
  instance_id = element(opentelekomcloud_compute_instance_v2.k8s_node.*.id, count.index)
}
