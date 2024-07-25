# Output the IP address
output "web_ips" {
  value = digitalocean_droplet.web.*.ipv4_address
}

output "db_ip" {
  value = digitalocean_droplet.db.ipv4_address
}