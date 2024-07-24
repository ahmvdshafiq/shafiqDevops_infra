# Output the IP address of the combined droplet
output "combined_ip" {
  value = digitalocean_droplet.combined.ipv4_address
}
