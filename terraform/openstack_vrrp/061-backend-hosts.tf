#### Controllers ####

# Render a multi-part cloud-init config
data "cloudinit_config" "backend_config" {
  for_each      = var.backend_instance_names
  gzip          = true
  base64_encode = true
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("templates/init.tpl", {ssh_private_key_base64=base64encode(file(var.ssh["private_key_file"]))})
  }
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("templates/backend_init.tpl", {
        _port_ids    = join(" ", [for name, item in openstack_networking_port_v2.backend: item.id])
        _my_port_id  = openstack_networking_port_v2.backend[each.value].id
        _clouds_yaml = file(var.clouds_yaml_file)
        _keepalived_mac_address = var.keepalived_mac_address
        _keepalived_ip_address = var.keepalived_ip_address
        _os_cloud_name = var.os_cloud_name
    })
  }
}

# Create instance
resource "openstack_compute_instance_v2" "backend" {
  for_each          = var.backend_instance_names
  name              = "${var.identifier}-server-${each.value}"
  image_id          = var.image
  flavor_name       = var.backend_flavor
  key_pair          = openstack_compute_keypair_v2.user_key.name
  user_data         = data.cloudinit_config.backend_config[each.value].rendered
  network {
    port = openstack_networking_port_v2.backend[each.value].id
  }
}

# Create network port
resource "openstack_networking_port_v2" "backend" {
  for_each              = var.backend_instance_names
  name                  = "${var.identifier}-port-${each.value}"
  network_id            = openstack_networking_network_v2.backend.id
  admin_state_up        = true
  port_security_enabled = true
  security_group_ids = [openstack_networking_secgroup_v2.backends_secgroup.id]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.backend.id
  }
#  allowed_address_pairs {
#     mac_address = var.keepalived_mac_address
#     ip_address = var.keepalived_ip_address
#  }
#  allowed_address_pairs {
#     ip_address = "0.0.0.0/0"
#  }
}

resource "openstack_networking_secgroup_v2" "backends_secgroup" {
  name        = "backends_secgroup"
  description = "Security group for backends services"
}

resource "openstack_networking_secgroup_rule_v2" "allow_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.backends_secgroup.id
}
resource "openstack_networking_secgroup_rule_v2" "allow_keepalived_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "112"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.backends_secgroup.id
}
resource "openstack_networking_secgroup_rule_v2" "allow_keepalived_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "112"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.backends_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "allow_icmp_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.backends_secgroup.id
}
