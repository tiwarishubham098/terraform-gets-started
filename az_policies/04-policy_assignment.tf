
data "azurerm_subscription" "current" {}

resource "azurerm_policy_assignment" "tag_governance" {
  name                 = "tag_governance"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.tag_governance.id
  description          = "Assignment of the Tag Governance initiative to subscription."
  display_name         = "Tag Governance"
  location             = "eastus"
  identity { type = "SystemAssigned" }

  enforcement_mode = false
}

#--------------------------------------------------------------------------------------------------------------------
#          **************************** Add Tag to resources  **************************** 
##--------------------------------------------------------------------------------------------------------------------

resource "azurerm_policy_assignment" "azdefinition_wl_eus_tagging" {
  name                 = "azdefinition-wl-eus-tagging"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.add_tag_to_resoures.id
  description          = "Assignment of the Tag to the resources."
  display_name         = "azdefinition-wl-eus-tagging"
  location             = "eastus"
  identity { type = "SystemAssigned" }
  enforcement_mode = false
}


#--------------------------------------------------------------------------------------------------------------------
#          **************************** inherit Tags from resource group to resources  **************************** 
##--------------------------------------------------------------------------------------------------------------------

resource "azurerm_policy_assignment" "inherit_tag_from_resoure_group" {
  name                 = "inherit_tag_from_resoure_group"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.inherit_tag_from_resoure_group.id
  description          = "Assignment of the Tag to the resources."
  display_name         = "azdefinition-wl-eus-tagging-inherit-from-resoure_group"
  location             = "eastus"
  identity { type = "SystemAssigned" }

  enforcement_mode = false
}
#--------------------------------------------------------------------------------------------------------------------
#          **************************** Allowed location Policy **************************** 
##--------------------------------------------------------------------------------------------------------------------



resource "azurerm_policy_assignment" "allowed_location_policy_assignment" {
  name                 = "allowed-location-policy-assignment"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.allowed_location_policy.id
  description          = "Policy Assignment enforce resources to be in specific locations"
  display_name         = "Allowed locations policy assignment"

  metadata = jsonencode({
    "category": var.policyset_definition_category
    })

  parameters = jsonencode({
  "allowedLocations": {
    "value": var.allowedLocations
  }
})

}
#--------------------------------------------------------------------------------------------------------------------
#          **************************** Defines restrictions on blocked Azure resources  **************************** 

# 1. This policy enables you to specify the resource types that your organization cannot deploy. 
# 2. This policy enables you to specify a set of virtual machine size SKUs that Wella can deploy
##--------------------------------------------------------------------------------------------------------------------
resource "azurerm_policy_assignment" "azdefinition-wl-eus-blockedresources" {
  name                 = "azdefinition-wl-eus-blockedresources"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.azdefinition-wl-eus-blockedresources.id
  description          = "1. This policy enables you to specify the resource types that your organization cannot deploy. \n 2. This policy enables you to specify a set of virtual machine size SKUs that Wella can deploy. "
  display_name         = "Defines restrictions on blocked Azure resources"

  metadata = jsonencode({
    "category": var.policyset_definition_category
    })

#[ "eastus","westus" ]
  parameters = jsonencode({
  "listOfAllowedSKUs": {
    "value":  var.allowed_vm_skus
  },
  "listOfResourceTypesNotAllowed": {
    "value":  var.list_of_resources_not_allowed
  }
})
enforcement_mode = true
}

#--------------------------------------------------------------------------------------------------------------------
#          **************************** Add Log-analytics workspace  **************************** 
##--------------------------------------------------------------------------------------------------------------------
data "azurerm_log_analytics_workspace" "log_analytics" {
  count = lookup(local.management.policies,"log_analytics_workspace",null)!=null?1:0
  name                = local.management.policies.log_analytics_workspace.name
  resource_group_name = local.management.policies.log_analytics_workspace.resource_group_name
}

resource "azurerm_policy_assignment" "azdefinition-wl-eus-loganalytics" {
  count = lookup(local.management.policies,"log_analytics_workspace",null)!=null?1:0
  name                 = "azdefinition-wl-eus-loganalytics"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.azdefinition-wl-eus-loganalytics.id
  description          = "1. Deploy log-analytics on windows VM.\n2. Deploy log-analytics on linux VM.\n3. Deploy log-analytics on windows VM scaleset"
  display_name         = "azdefinition-wl-eus-loganalytics"
  location             = "eastus"
  identity { type = "SystemAssigned" }

  parameters = jsonencode({
    "logAnalytics_name": {
      "value":  data.azurerm_log_analytics_workspace.log_analytics[0].id
    }
  })

  enforcement_mode = true
}
#--------------------------------------------------------------------------------------------------------------------
#          **************************** Add Tag to resources  **************************** 
##--------------------------------------------------------------------------------------------------------------------
resource "azurerm_policy_assignment" "core_networking_restrictions" {
  name                 = "azdefinition-wl-eus-corenetworking"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.core_networking_restrictions.id
  description          = "1. Management ports should be closed on your virtual machines. \n 2. Network interfaces should not have public IPs "
  display_name         = "azdefinition wl eus corenetworking"
  location             = "eastus"
  identity { type = "SystemAssigned" }
  enforcement_mode = false
}

#--------------------------------------------------------------------------------------------------------------------
