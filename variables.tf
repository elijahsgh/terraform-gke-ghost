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

variable "ghost_envvars" {
  default = {}
}