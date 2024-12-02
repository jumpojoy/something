#### NETWORK CONFIGURATION ####

# =================== Floating network =====================
#                                        |
#            (FIP:                       |
#              <Jump VM>           <Generic Router>
#                  |                     |
#                  |                     |
# =========  APP/LCM Network ===============================
#                  |
#                  |
#              ( Backend Router )
#                  |
#                  |
# =========== Backend Network ==============================
#    |                            |
#    |                            |
#   <Vm>                         <VM>
#
# VIP:

# Router creation
data "openstack_networking_network_v2" "public" {
  name = var.public_network
}

resource "openstack_networking_router_v2" "generic" {
  name                = "${var.identifier}-router"
  external_network_id = data.openstack_networking_network_v2.public.id
}

#### APP NETWORK ####
resource "openstack_networking_network_v2" "lcm" {
  name = "${var.identifier}-network-lcm"
}
# Subnet lcm network
resource "openstack_networking_subnet_v2" "lcm" {
  name            = join("-", [var.identifier, var.lcm_network["subnet_name"]])
  network_id      = openstack_networking_network_v2.lcm.id
  cidr            = var.lcm_network["cidr"]
  dns_nameservers = var.dns_nameservers
}

resource "openstack_networking_subnet_route_v2" "route-lcm-to-backend" {
  subnet_id        = openstack_networking_subnet_v2.lcm.id
  destination_cidr = var.backend_network["cidr"]
  next_hop         = openstack_networking_port_v2.backend-lcm-port.all_fixed_ips[0]
}

# Router interface configuration
resource "openstack_networking_router_interface_v2" "lcm" {
  router_id = openstack_networking_router_v2.generic.id
  subnet_id = openstack_networking_subnet_v2.lcm.id
}


#### Backend network ####

resource "openstack_networking_router_v2" "backend" {
  name                = "${var.identifier}-backend-router"
  external_network_id = data.openstack_networking_network_v2.public.id
}

resource "openstack_networking_network_v2" "backend" {
  name = "${var.identifier}-network-backend"
}
# Subnet lcm network
resource "openstack_networking_subnet_v2" "backend" {
  name            = join("-", [var.identifier, var.backend_network["subnet_name"]])
  network_id      = openstack_networking_network_v2.backend.id
  cidr            = var.backend_network["cidr"]
  dns_nameservers = var.dns_nameservers
}

# Router interface configuration
# Create network port
resource "openstack_networking_port_v2" "backend-lcm-port" {
  name                  = "backend-lcm-port"
  network_id            = openstack_networking_network_v2.lcm.id
  admin_state_up        = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.lcm.id
  }
}
resource "openstack_networking_router_interface_v2" "backend" {
  router_id = openstack_networking_router_v2.backend.id
  subnet_id = openstack_networking_subnet_v2.backend.id
}
resource "openstack_networking_router_interface_v2" "backend-to-lcm" {
  router_id = openstack_networking_router_v2.backend.id
  port_id = openstack_networking_port_v2.backend-lcm-port.id
}
