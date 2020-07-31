# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "~>2.20.0"
  features {}
}

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "BEE-A-LEARNER"
    workspaces {
      name = "LER-TST"
    }
  }
}
