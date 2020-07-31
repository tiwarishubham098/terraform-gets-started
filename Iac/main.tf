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

output "local_rg_name" {
  value = local.resource_group_name
}

output "outcome_1" {
  value = local.hello
}
output "outcome_lookup_type" {
  value = local.lookup_type
}
# output "list_type_var_output" {
#   value = var.list_type_var
# }
# output "tags_output" {
#   value = var.tags
# }
# output "requires_approval" {
#   value = var.requires_approval
# }
# output "number_value" {
#   value = var.number_value
# }

# output "car_model" {
#   value = var.car_model
# }

###########################Learning about the variables###########################
