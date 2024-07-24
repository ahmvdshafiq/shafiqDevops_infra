terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"  # Use the latest version compatible with your setup
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

# Create a single droplet for both web server and database
resource "digitalocean_droplet" "combined" {
  image  = "ubuntu-20-04-x64"
  name   = "combined-droplet"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]

  tags = ["web", "db"]
}

# Load Balancer (if needed)
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
}