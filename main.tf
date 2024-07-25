terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

resource "digitalocean_droplet" "web" {
  count  = 2
  image  = "ubuntu-20-04-x64"
  name   = "web-${count.index}"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]
  vpc_uuid = var.vpc_id 

  tags = ["web"]
}

resource "digitalocean_droplet" "db" {
  image  = "ubuntu-20-04-x64"
  name   = "db"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]
  vpc_uuid = var.vpc_id 

  tags = ["db"]
}

resource "digitalocean_firewall" "web_and_db" {
  name = "web-and-db-firewall"

  inbound_rule {
    protocol       = "tcp"
    port_range     = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol       = "icmp"
    port_range     = "0"
    source_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol       = "tcp"
    port_range     = "0"
    destination_addresses = ["0.0.0.0/0"]
  }

  # Flatten the list of droplet IDs
  droplet_ids = flatten([
    digitalocean_droplet.web[*].id,
    [digitalocean_droplet.db.id],
  ])
}

resource "digitalocean_loadbalancer" "lb" {
  name      = "web-lb"
  region    = "nyc3"
  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"
    target_port    = 80
    target_protocol = "http"
  }

  healthcheck {
    port     = 80
    protocol = "http"
    path     = "/"
    check_interval_seconds = 10
    response_timeout_seconds = 5
    healthy_threshold = 5
    unhealthy_threshold = 3
  }

  droplet_tag = "web"
  vpc_uuid = var.vpc_id 
}
