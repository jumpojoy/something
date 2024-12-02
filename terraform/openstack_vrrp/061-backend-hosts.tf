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
    content      = templatefile("templates/backend_init.tpl", {})
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
  port_security_enabled = false
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.backend.id
  }
}

# Create VIP network port
resource "openstack_networking_port_v2" "backend_vip_port" {
  name                  = "backend-vip-port"
  network_id            = openstack_networking_network_v2.backend.id
  admin_state_up        = true
  mac_address           = "00:00:5e:00:01:32"
  port_security_enabled = false
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.backend.id
    ip_address = "192.168.0.10"
  }
  binding {
    host_id = "fakebindinghost"
  }
}
