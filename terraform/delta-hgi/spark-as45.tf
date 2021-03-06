module "spark-master-as45" {
  source = "../modules/spark-master"
  count  = 0

  image = {
    name = "${var.base_image_name}"
    user = "${var.base_image_user}"
  }

  flavour            = "m1.large"
  domain             = "hgi.sanger.ac.uk"
  security_group_ids = "${module.openstack.security_group_ids}"
  key_pair_ids       = "${module.openstack.key_pair_ids}"
  network_id         = "${module.openstack.network_id}"

  bastion = {
    host = "${module.ssh-gateway.host}"
    user = "${module.ssh-gateway.user}"
  }

  extra_ansible_groups = ["consul-cluster-delta-hgi"]
  spark_cluster_id     = "as45"
}

module "spark-compute-as45" {
  source = "../modules/spark-compute"
  count  = 0

  image = {
    name = "${var.base_image_name}"
    user = "${var.base_image_user}"
  }

  flavour            = "m1.large"
  domain             = "hgi.sanger.ac.uk"
  security_group_ids = "${module.openstack.security_group_ids}"
  key_pair_ids       = "${module.openstack.key_pair_ids}"
  network_id         = "${module.openstack.network_id}"

  bastion = {
    host = "${module.ssh-gateway.host}"
    user = "${module.ssh-gateway.user}"
  }

  extra_ansible_groups = ["consul-cluster-delta-hgi"]
  spark_cluster_id     = "as45"
}
