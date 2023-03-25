# Configure the Azure Provider
provider "azurerm" {
  subscription_id = "85cd2292-82e3-4c72-a2d7-1ba724a25176"
  tenant_id = "120709b9-1cde-4a68-944a-f6fb5b566111"
  client_id = "80519e20-919b-4d81-a8d9-405d697d2644"
  client_secret  = var.client_secret
  features {}
}

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "SmithaOrg"
    workspaces {
      name = "wsp-PaC"
    }   
  }
}
