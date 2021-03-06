variable "env" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "base_image_name" {
  type = "string"
}

variable "base_image_user" {
  type    = "string"
  default = "ubuntu"
}

variable docker_image_name {
  type = "string"
}

variable docker_image_user {
  type    = "string"
  default = "ubuntu"
}

variable arvados_compute_node_image_name {
  type = "string"
}

variable arvados_compute_node_image_user {
  type    = "string"
  default = "debian"
}

variable freebsd_base_image_name {
  type = "string"
}

variable freebsd_base_image_user {
  type    = "string"
  default = "beastie"
}

variable consul_template_token {
  type = "string"
}
