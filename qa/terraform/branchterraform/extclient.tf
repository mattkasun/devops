resource "digitalocean_droplet" "extclient" {
  image  = "ubuntu-22-10-x64"
  name   = var.extclient
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  ipv6   = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  tags = [var.extclient, var.branch]
  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install wireguard for extclient to work
      "pwd",
      "apt-get -y update",
      "apt-get -y update",
      "apt install -y wireguard-tools",
      "apt install -y wireguard-tools",
    ]
  }
}

data "digitalocean_droplet" "extserverip" {
  name       = var.extclient
  depends_on = [digitalocean_droplet.extclient]
}

resource "local_file" "extipaddresses" {
  depends_on = [data.digitalocean_droplet.extserverip]
  content    = data.digitalocean_droplet.extserverip.ipv4_address
  filename   = "ipaddress${var.extclient}.txt"

}