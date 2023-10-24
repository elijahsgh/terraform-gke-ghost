variable "db_instance" {}

variable "db_password" {
  default = null
}

variable "db_ip" {}

variable "mail_password" {}

variable "ghostimage" {}

variable "project" {}

variable "zone" {}

variable "region" {}

variable "prefix" {}

variable "init_container_image" {
  default = ""
}

variable "external_ip" {
  default = ""
}

variable "ghost_envvars" {
  default = {}
}

variable "ingress_annotations" {
  default = {}
}

variable "service_annotations" {
  default = {}
}
