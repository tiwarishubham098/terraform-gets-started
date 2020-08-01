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
    token = "EsV6Il3gXoLGag.atlasv1.rVYclUQzBGY4NYndPECz21o2J3AOjSfjBJd6BmObnAsaEbfw3Ad0RDykzhMK9FSYpyI"
    workspaces {
      name = "LER-TST"
    }
  }
}
