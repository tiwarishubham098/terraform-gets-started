
#-------------------------------------------------------------------------------------------------------------------------------------
#@@@@@@@@@@@@@@  Policy sets are nothing but initiatives, if you need to combine the policy you can create set of it and use it. @@@@@
#------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_policy_set_definition" "tag_governance" {

  name         = "tag_governance"
  policy_type  = "Custom"
  display_name = "Tag Governance"
  description  = "Contains common Tag Governance policies"

  metadata = jsonencode({
    "category": var.policyset_definition_category
    })

  dynamic "policy_definition_reference" {
    for_each = azurerm_policy_definition.addTagToRG
    content {
      policy_definition_id = policy_definition_reference.value.id
      reference_id         = policy_definition_reference.value.id
    }
  }
}

resource "azurerm_policy_set_definition" "add_tag_to_resoures" {

  name         = "azdefinition-wl-eus-tagging"
  policy_type  = "Custom"
  display_name = "azdefinition-wl-eus-tagging"
  description  = "Defines required tags on resources"

  metadata = jsonencode({
    "category": var.policyset_definition_category
    })

  dynamic "policy_definition_reference" {
    for_each = azurerm_policy_definition.add_tag_to_resoures
    content {
      policy_definition_id = policy_definition_reference.value.id
      reference_id         = policy_definition_reference.value.id
    }
  }
}


resource "azurerm_policy_set_definition" "inherit_tag_from_resoure_group" {

  name         = "inherit_tag_from_resoure_group"
  policy_type  = "Custom"
  display_name = "inherit tag from resoure group"
  description  = "Defines required tags on resources"

  metadata = jsonencode({
    "category": var.policyset_definition_category
    })

  dynamic "policy_definition_reference" {
    for_each = azurerm_policy_definition.inherit_tag_from_resoure_group
    content {
      policy_definition_id = policy_definition_reference.value.id
      reference_id         = policy_definition_reference.value.id
    }
  }
}




#-----------------------------------------------------------------------------------------------------------------------
#********************** Core networking restrictions ******************** 
# This include both Network-interfaces-should-not-have-public-IPs  and management-ports-should-be-closed
##----------------------------------------------------------------------------------------------------------------------


resource "azurerm_policy_set_definition" "core_networking_restrictions" {

  name         = "azdefinition-wl-eus-corenetworking"
  policy_type  = "Custom"
  display_name = "Core networking restrictions"
  description  = "Core networking restrictions"

  metadata = jsonencode(
    {
    "category": "Network"
    })

  policy_definition_reference {
      policy_definition_id = azurerm_policy_definition.network_interfaces_should_not_have_public_ip.id
      reference_id         = azurerm_policy_definition.network_interfaces_should_not_have_public_ip.id
  }

  policy_definition_reference {
      policy_definition_id = azurerm_policy_definition.management_ports_should_be_closed.id
      reference_id         = azurerm_policy_definition.management_ports_should_be_closed.id
  }
}

#-----------------------------------------------------------------------------------------------------------------------
#**********************  azdefinition-wl-eus-blockedresources ******************** 
# Defines restrictions on blocked Azure resources and Defines restrictions on blocked Azure resources
##----------------------------------------------------------------------------------------------------------------------


resource "azurerm_policy_set_definition" "azdefinition-wl-eus-blockedresources" {

  name         = "azdefinition-wl-eus-blockedresources"
  policy_type  = "Custom"
  display_name = "Defines restrictions on blocked Azure resources"
  description  = "Defines restrictions on blocked Azure resources"

   metadata = jsonencode({
    "category": var.policyset_definition_category
    })
  
  parameters =jsonencode({
        "listOfResourceTypesNotAllowed": {
            "type": "Array",
            "metadata": {
                "description": "The list of resource types that can NOT be deployed.",
                "displayName": "resource types not allowed",
                "strongType": "resourceTypes"
            }
        },
        "listOfAllowedSKUs": {
            "type": "Array",
            "metadata": {
                  "description": "This policy enables you to specify a set of virtual machine size SKUs that your organization can deploy.",
                  "displayName": "Allowed Size SKUs",
                  "strongType": "VMSKUs"
            }
        },
    })

  policy_definition_reference {
      policy_definition_id = azurerm_policy_definition.not_allowed_resource_types.id
      reference_id         = azurerm_policy_definition.not_allowed_resource_types.id
      parameter_values     =jsonencode({
      "listOfResourceTypesNotAllowed": {"value": "[parameters('listOfResourceTypesNotAllowed')]"}
    })
  }

  policy_definition_reference {
      policy_definition_id = azurerm_policy_definition.allowed_vm_sku_policy.id
      reference_id         = azurerm_policy_definition.allowed_vm_sku_policy.id
      parameter_values     =jsonencode({
      "listOfAllowedSKUs": {"value": "[parameters('listOfAllowedSKUs')]"}
    })
  }
}

#-----------------------------------------------------------------------------------------------------------------------
#********************** Core networking restrictions ******************** 
# This include both Network-interfaces-should-not-have-public-IPs  and management-ports-should-be-closed
##----------------------------------------------------------------------------------------------------------------------


resource "azurerm_policy_set_definition" "azdefinition-wl-eus-loganalytics" {

  name         = "azdefinition-wl-eus-loganalytics"
  policy_type  = "Custom"
  display_name = "Deploys Log Analytics to VM resources"
  description  = "Deploys Log Analytics to VM resources"

  metadata = jsonencode(
    {
    "category": "Monitoring"
    })

parameters =jsonencode({
        "logAnalytics_name": {
        "type": "String",
        "metadata": {
          "displayName": "Log Analytics workspace",
          "description": "Select Log Analytics workspace from dropdown list. If this workspace is outside of the scope of the assignment you must manually grant 'Log Analytics Contributor' permissions (or similar) to the policy assignment's principal ID.",
          "strongType": "omsWorkspace",
          "assignPermissions": true
        }
      }})

  policy_definition_reference {
      policy_definition_id = azurerm_policy_definition.log_analytics_on_windows_vm.id
      reference_id         = azurerm_policy_definition.log_analytics_on_windows_vm.id
       parameter_values     =jsonencode({
      "logAnalytics": {"value": "[parameters('logAnalytics_name')]"}
    })
  }

  policy_definition_reference {
      policy_definition_id = azurerm_policy_definition.log_analytics_on_linux_vm.id
      reference_id         = azurerm_policy_definition.log_analytics_on_linux_vm.id
       parameter_values     =jsonencode({
      "logAnalytics": {"value": "[parameters('logAnalytics_name')]"}
    })
  }

  policy_definition_reference {
      policy_definition_id = azurerm_policy_definition.log_analytics_on_windows_vm_scaleset.id
      reference_id         = azurerm_policy_definition.log_analytics_on_windows_vm_scaleset.id
       parameter_values     =jsonencode({
      "logAnalytics": {"value": "[parameters('logAnalytics_name')]"}
    })
  }
}

#--------------------------------------------------------------------------------------------------------------------
#          **************************** Allowed location Policy **************************** 
##--------------------------------------------------------------------------------------------------------------------

# resource "azurerm_policy_set_definition" "allowed_location_policy_set" {

#   name         = "azdefinition-wl-eus-allowedregions"
#   policy_type  = "Custom"
#   display_name = "allowed location"
#   description  = "Defines allowed regions"

#   metadata = <<METADATA
#     {
#     "category": var.policyset_definition_category
#     }
# METADATA

#   policy_definition_reference {
#       policy_definition_id = azurerm_policy_definition.allowed_location_policy.id
#       reference_id         = azurerm_policy_definition.allowed_location_policy.id
#     }
# }
