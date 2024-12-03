# Define ssh to inject in instance
resource "openstack_compute_keypair_v2" "user_key" {
  name       = "${var.identifier}-key"
  public_key = file(var.ssh["public_key_file"])
}
