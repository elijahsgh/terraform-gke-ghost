variable "db_instance" {}

variable "db_password" {}

variable "db_ip" {}

variable "mail_password" {}

variable "ghostimage" {}

variable "project" {}

variable "zone" {}

variable "region" {}

variable "prefix" {}

variable "backend_service_name" {}

variable "init_container_image" {
  default = ""
}

variable "external_ip" {
  default = ""
}

variable "ghost_envvars" {
  default = {}
}

variable "create_load_balancer" {
  default = true
}

variable "ingress_annotations" {
  default = {}
}