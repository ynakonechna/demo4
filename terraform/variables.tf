variable "tags" {
  default = {
    Env = "test"
  }
}

variable "public_subnets" {
  type = list(string)
  default = [ "10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnets" {
  type = list(string)
  default = [ "10.0.5.0/24", "10.0.6.0/24"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "db_name" {
  default = "nuwmhostels"
}

variable "db_username" {
  default = "admin"
}

variable "domain" {
  default = "app.demo2.yulia1.pp.ua"
}