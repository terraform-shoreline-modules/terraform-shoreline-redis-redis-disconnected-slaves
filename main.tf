terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "redis_disconnected_slaves_incident" {
  source    = "./modules/redis_disconnected_slaves_incident"

  providers = {
    shoreline = shoreline
  }
}