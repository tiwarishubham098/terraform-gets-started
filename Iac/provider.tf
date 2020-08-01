# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "~>2.20.0"
  subscription_id = "2a04288a-8136-4880-b526-c6070e59f004"
  tenant_id = "37d20c78-05e3-416d-83ab-cdbc21fed22a"
  client_id = "ecc4be67-51ce-4780-a17a-75426c4b8a7a"
  client_secret  = "s~p93kYHx296yIxG.f--aC0y4NwR5E_h-G"
  features {}
}

# terraform {
#   backend "remote" {
#     hostname = "app.terraform.io"
#     organization = "BEE-A-LEARNER"
#     workspaces {
#       name = "LER-TST"
#     }
#   }
# }
