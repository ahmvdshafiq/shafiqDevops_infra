variable "digitalocean_token" {
  description = "DigitalOcean API token"
  type        = string
}

variable "ssh_fingerprint" {
  description = "SSH key fingerprint"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to use for resources"
  type        = string
}

