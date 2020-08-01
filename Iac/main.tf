###########################Learning about the variables###########################
locals {
  hello        = format("Hello, %s!", "Ander")
  format_list  = formatlist("Hello, %s!", ["Valentina", "Ander", "Olivia", "Sam"])
  hello_titile = title("hello world")
  lookup_type  = lookup({ UKS = "UK South", UKE = "UK East", EUW = "west europe" }, "UKS", "what?")
}

resource "azurerm_resource_group" "platform_rg" {
  name =local.resource_group_name
  location = var.location
}


# An example resource that does nothing.
     resource "null_resource" "example" {
       triggers = {
         value = "A example resource that does nothing!"
       }
     }

output "local_rg_name" {
  value = local.resource_group_name
}

output "outcome_1" {
  value = local.hello
}
output "outcome_lookup_type" {
  value = local.lookup_type
}

###########################Learning about the variables###########################
