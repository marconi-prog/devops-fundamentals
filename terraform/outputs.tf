output "postgres_container" {
  description = "PostgreSQL container name"
  value       = docker_container.postgres.name
}

output "docker_network" {
  description = "Docker network name"
  value       = docker_network.app_network.name
}