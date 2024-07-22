terraform {
  required_version = "~> 1.3"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

resource "docker_image" "f_one_scrape_image" {
  name = var.image_name

  build {
    context = var.path_to_src
    tag     = ["${var.ecr_repo}:latest"]

    build_arg = {
      platform = var.platform
    }
  }

  keep_locally = false
}

resource "docker_registry_image" "f_one_scrape_image_registry" {
  name = "${var.ecr_repo}:latest"

  depends_on = [docker_image.f_one_scrape_image]
}