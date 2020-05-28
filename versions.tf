terraform {
  required_version = "~> 0.12.24"

  required_providers {
    aws        = "~> 2.53"
    sdm        = "~> 1.0"
    kubernetes = "~> 1.11"
  }
}
