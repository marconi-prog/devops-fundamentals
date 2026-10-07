terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "devops-fundamentals-network"
}

resource "docker_image" "postgres" {
  name         = var.postgres_image
  keep_locally = true
}

resource "docker_container" "postgres" {
  name  = "devops-fundamentals-db"
  image = docker_image.postgres.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

  env = [
    "POSTGRES_DB=${var.postgres_db}",
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}"
  ]

  volumes {
    volume_name    = "devops-fundamentals-postgres-data"
    container_path = "/var/lib/postgresql/data"
  }
}

resource "docker_image" "api" {
  name = "devops-fundamentals:latest"

  build {
    context    = ".."
    dockerfile = "Dockerfile"
  }

  keep_locally = true
}

resource "docker_container" "api" {
  name  = "devops-fundamentals-api"
  image = docker_image.api.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

  env = [
    "SPRING_DATASOURCE_URL=jdbc:postgresql://devops-fundamentals-db:5432/${var.postgres_db}",
    "SPRING_DATASOURCE_USERNAME=${var.postgres_user}",
    "SPRING_DATASOURCE_PASSWORD=${var.postgres_password}"
  ]

  depends_on = [
    docker_container.postgres
  ]
}