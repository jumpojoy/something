provider "openstack" {
  use_octavia = "true"
  cloud = "admin"
  insecure = "true"
  region = "CustomRegion"
}

# Define OpenStack provider
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}
