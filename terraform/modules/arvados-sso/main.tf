variable "flavour" {}
variable "domain" {}
variable "network_id" {}
variable "arvados_cluster_id" {}

variable "security_group_ids" {
  type    = "map"
  default = {}
}

variable "key_pair_ids" {
  type    = "map"
  default = {}
}

variable "image" {
  type    = "map"
  default = {}
}

variable "bastion" {
  type    = "map"
  default = {}
}

variable "extra_ansible_groups" {
  type    = "list"
  default = []
}

locals {
  ansible_groups = [
    "arvados-ssos",
    "arvados-cluster-${var.arvados_cluster_id}",
    "consul-agents",
    "hgi-credentials",
  ]
}

resource "openstack_networking_floatingip_v2" "arvados-sso" {
  provider = "openstack"
  pool     = "nova"
}

resource "openstack_compute_instance_v2" "arvados-sso" {
  provider    = "openstack"
  count       = 1
  name        = "arvados-sso-${var.arvados_cluster_id}"
  image_name  = "${var.image["name"]}"
  flavor_name = "${var.flavour}"
  key_pair    = "${var.key_pair_ids["mercury"]}"

  security_groups = [
    "${var.security_group_ids["ping"]}",
    "${var.security_group_ids["ssh"]}",
    "${var.security_group_ids["https"]}",
    "${var.security_group_ids["consul-client"]}",
  ]

  network {
    uuid           = "${var.network_id}"
    access_network = true
  }

  user_data = "#cloud-config\nhostname: arvados-sso-${var.arvados_cluster_id}\nfqdn: arvados-sso-${var.arvados_cluster_id}.${var.domain}"

  metadata = {
    ansible_groups = "${join(" ", distinct(concat(local.ansible_groups, var.extra_ansible_groups)))}"
    user           = "${var.image["user"]}"
    bastion_host   = "${var.bastion["host"]}"
    bastion_user   = "${var.bastion["user"]}"
  }

  # wait for host to be available via ssh
  provisioner "remote-exec" {
    inline = [
      "hostname",
    ]

    connection {
      type         = "ssh"
      user         = "${var.image["user"]}"
      agent        = "true"
      timeout      = "2m"
      bastion_host = "${var.bastion["host"]}"
      bastion_user = "${var.bastion["user"]}"
    }
  }
}

resource "openstack_compute_floatingip_associate_v2" "arvados-sso" {
  provider    = "openstack"
  floating_ip = "${openstack_networking_floatingip_v2.arvados-sso.address}"
  instance_id = "${openstack_compute_instance_v2.arvados-sso.id}"
}

resource "infoblox_record" "arvados-sso" {
  value  = "${openstack_networking_floatingip_v2.arvados-sso.address}"
  name   = "arvados-sso-${var.arvados_cluster_id}"
  domain = "${var.domain}"
  type   = "A"
  ttl    = 600
  view   = "internal"
}

resource "openstack_blockstorage_volume_v2" "arvados-sso-volume" {
  name = "arvados-sso-${var.arvados_cluster_id}-volume"
  size = 10
}

resource "openstack_compute_volume_attach_v2" "arvados-sso-volume-attach" {
  volume_id   = "${openstack_blockstorage_volume_v2.arvados-sso-volume.id}"
  instance_id = "${openstack_compute_instance_v2.arvados-sso.id}"
}

output "ip" {
  value = "${openstack_networking_floatingip_v2.arvados-sso.address}"
}
