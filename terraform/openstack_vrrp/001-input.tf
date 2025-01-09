# Define input variables
# Cluster
variable "identifier" {
  type    = string
  default = "oc-virtual-lab"
}
variable "image" {
  type        = string
  description = "Name of image to use for servers"
}
variable "backend_flavor" {
  type    = string
  default = "m1.small"
}
variable "jump_flavor" {
  type    = string
  default = "m1.small"
}

variable "public_network" {
  type    = string
  default = "public"
}
variable "dns_nameservers" {
  type    = list(string)
  default = ["10.172.1.100"]
}

variable "clouds_yaml_file" {
    type = string
    default = "/etc/openstack/clouds.yaml"
}

variable "keepalived_mac_address" {
    type = string
    default = "00:00:5e:00:01:32"
}

variable "keepalived_ip_address" {
    type = string
    default = "192.168.0.10/32"
}

variable "os_cloud_name" {
    type = string
    default = "admin-public"
}

variable "ssh" {
  type = map(string)
  default = {
    user_name        = "ubuntu"
    public_key_file  = "templates/id_rsa.pub"
    private_key_file = "templates/id_rsa"
  }
}
# Controlers
variable "backend_instance_names" {
  type = set(string)
  default = [
    "fw-01",
    "fw-02",
  ]
}
variable "jump_instance_names" {
  type = set(string)
  default = [
    "jump-01",
  ]
}

variable "lcm_network" {
  type        = map(string)
  description = "The details of LCM network"
  default = {
    subnet_name = "subnet-lcm"
    cidr        = "10.10.11.0/24"
  }
}

variable "backend_network" {
  type        = map(string)
  description = "The details of LCM network"
  default = {
    subnet_name = "subnet-backend"
    cidr        = "192.168.0.0/24"
  }
}
