module "studentportal" {
  source = "../modules/studentportal"
  count  = 1

  image = {
    name = "${var.base_image_name}"
    user = "${var.base_image_user}"
  }

  flavour            = "m1.medium"
  domain             = "hgi.sanger.ac.uk"
  security_group_ids = "${module.openstack.security_group_ids}"
  key_pair_ids       = "${module.openstack.key_pair_ids}"
  network_id         = "${module.openstack.network_id}"

  bastion = {
    host = "${module.ssh-gateway.host}"
    user = "${module.ssh-gateway.user}"
  }
}