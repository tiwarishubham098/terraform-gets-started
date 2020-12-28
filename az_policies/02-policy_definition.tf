#---------------------------------------------------------------------------------------------------------------
#https://github.com/globalbao/terraform-azurerm-policy/blob/master/modules/policy-definitions/main.tf
#---------------------------------------------------------------------------------------------------------------
resource "azurerm_policy_definition" "addTagToRG" {
  
   for_each = {
    for k,v in var.mandatory_tag_keys : k=> v
  }

  name         = "addTagToRG_${each.key}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Add tag ${each.key} to resource group"
  description  = "Adds the mandatory tag key ${each.key} when any resource group missing this tag is created or updated. \nExisting resource groups can be remediated by triggering a remediation task.\nIf the tag exists with a different value it will not be changed."

  metadata = jsonencode({
    "category": var.policy_definition_category,
  })

  policy_rule = jsonencode({
        "if": {
          "allOf": [
            {
              "field": "type",
              "equals": "Microsoft.Resources/subscriptions/resourceGroups"
            },
            {
              "field": "[concat('tags[', parameters('tagName'), ']')]",
              "exists": "false"
            }
          ]
        },
        "then": {
          "effect": "modify",
          "details": {
            "roleDefinitionIds": [
              "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
            ],
            "operations": [
              {
                "operation": "add",
                "field": "[concat('tags[', parameters('tagName'), ']')]",
                "value": "[parameters('tagValue')]"
              }
            ]
          }
        }
  })


  parameters = jsonencode({
        "tagName": {
          "type": "String",
          "metadata": {
            "displayName": "Mandatory Tag ${each.key}",
            "description": "Name of the tag, such as ${each.key}"
          },
          "defaultValue": each.key
        },
        "tagValue": {
          "type": "String",
          "metadata": {
            "displayName": "Tag Value '${each.value}'",
            "description": "Value of the tag, such as '${each.value}'"
          },
          "defaultValue": each.value
        }
  })

}

# output "addTagToRG_policy_ids" {
#   value       = azurerm_policy_definition.addTagToRG#.*.id
#   description = "The policy definition ids for addTagToRG policies"
# }

#--------------------------------------------------------------------------------------------------------------------
#          **************************** Add tag to resources **************************** 
##--------------------------------------------------------------------------------------------------------------------

resource "azurerm_policy_definition" "add_tag_to_resoures" {
  
   for_each = {
    for k,v in var.mandatory_tag_to_resoures : k=> v
  }

  name         = "addTagToResources_${each.key}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Add tag ${each.key} to resources"
  description  = "Adds or replaces the specified tag and value when any resource is created or updated. Existing resources can be remediated by triggering a remediation task. Does not modify tags on resource groups."

  metadata = jsonencode({
    "category": var.policy_definition_category,
    "version" : "1.0.0"
    })

parameters = jsonencode({
        "tagName": {
          "type": "String",
          "metadata": {
            "displayName": "Mandatory Tag ${each.key}",
            "description": "Name of the tag, such as ${each.key}"
          },
          "defaultValue": each.key
        },
        "tagValue": {
          "type": "String",
          "metadata": {
            "displayName": "Tag Value '${each.value}'",
            "description": "Value of the tag, such as '${each.value}'"
          },
          "defaultValue": each.value
        }
  })

  policy_rule = jsonencode({
        "if": {
              "field": "[concat('tags[', parameters('tagName'), ']')]",
              "exists": "false"
        },
        "then": {
          "effect": "modify",
          "details": {
            "roleDefinitionIds": [
              "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
            ],
            "operations": [
              {
                "operation": "addOrReplace",
                "field": "[concat('tags[', parameters('tagName'), ']')]",
                "value": "[parameters('tagValue')]"
              }
            ]
          }
        }
  })
}



#--------------------------------------------------------------------------------------------------------------------
#          **************************** inherit_tag_from_resoure_group **************************** 
##--------------------------------------------------------------------------------------------------------------------

resource "azurerm_policy_definition" "inherit_tag_from_resoure_group" {
  
  count = length( var.mandatory_tag_to_inherit)

  name         = "inherit__${var.mandatory_tag_to_inherit[count.index]}_tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Add tag ${var.mandatory_tag_to_inherit[count.index]} to resources"
  description  = "Adds or replaces the specified tag and value when any resource is created or updated. Existing resources can be remediated by triggering a remediation task. Does not modify tags on resource groups."

  metadata = jsonencode({
    "category": var.policy_definition_category,
    "version" : "1.0.0"
    })

parameters = jsonencode({
        "tagName": {
          "type": "String",
          "metadata": {
            "displayName": "inherit Tag ${var.mandatory_tag_to_inherit[count.index]}",
            "description": "Name of the tag, such as ${var.mandatory_tag_to_inherit[count.index]}"
          },
          "defaultValue": var.mandatory_tag_to_inherit[count.index]
        }
  })

  policy_rule = jsonencode({
        "if": {
             "allOf": [
              {
                "field": "[concat('tags[', parameters('tagName'), ']')]",
                "notEquals": "[resourceGroup().tags[parameters('tagName')]]"
              },
              {
                "value": "[resourceGroup().tags[parameters('tagName')]]",
                "notEquals": ""
              }
            ]
        },
        "then": {
          "effect": "modify",
          "details": {
            "roleDefinitionIds": [
              "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
            ],
            "operations": [
              {
                "operation": "addOrReplace",
                "field": "[concat('tags[', parameters('tagName'), ']')]",
                "value": "[resourceGroup().tags[parameters('tagName')]]"
              }
            ]
          }
        }
  })
}

#--------------------------------------------------------------------------------------------------------------------
#          **************************** Allowed location Policy **************************** 
##--------------------------------------------------------------------------------------------------------------------

resource "azurerm_policy_definition" "allowed_location_policy" {
  
  name         = "allowed-location-policy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed location policy"

 metadata = jsonencode({
    "category": var.policy_definition_category,
    "version" : "1.0.0"
    })

  policy_rule = jsonencode({
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "deny"
    }
  })

  parameters = jsonencode({
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of allowed locations for resources.",
        "displayName": "Allowed locations",
        "strongType": "location"
      }
    }
  })
}

#--------------------------------------------------------------------------------------------------------------------
#          **************************** Allowed Virtual Machine SKU **************************** 
##--------------------------------------------------------------------------------------------------------------------
resource "azurerm_policy_definition" "allowed_vm_sku_policy" {
  
  name         = "allowed-vm-sku-policy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed VM SKU policy"
  description = "This policy enables you to specify a set of virtual machine size SKUs that your organization can deploy."

 metadata = jsonencode({
    "category": var.policy_definition_category,
    "version" : "1.0.0"
    })

parameters = jsonencode({
    "listOfAllowedSKUs": {
      "type": "Array",
      "metadata": {
        "description": "This policy enables you to specify a set of virtual machine size SKUs that your organization can deploy.",
        "displayName": "Allowed Size SKUs",
        "strongType": "VMSKUs"
      }
    }
  })

  policy_rule =jsonencode({
    "if": {
      "allOf":[
        {
          "field":"type",
          "equals":"Microsoft.Compute/virtualMachines"
        },
        {
          "not": {
            "field": "Microsoft.Compute/virtualMachines/sku.name",
            "in": "[parameters('listOfAllowedSKUs')]"
          }
        }
      ]
    },
    "then": {
      "effect": "deny"
    }
  })
}


#-----------------------------------------------------------------------------------------------------------------------
#********************** Defines restrictions on blocked Azure resources ******************** 
# 
##----------------------------------------------------------------------------------------------------------------------
resource "azurerm_policy_definition" "not_allowed_resource_types" {
  
  name         = "not-allowed-resource-types"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Resource Types not allowed"
  description = "This policy enables you to specify the resource types that your organization can NOT be deploy."

 metadata = jsonencode({
    "category": var.policy_definition_category,
    "version" : "1.0.0"
    })

parameters = jsonencode({
     "listOfResourceTypesNotAllowed": {
        "type": "Array",
        "metadata": {
          "description": "The list of resource types that can NOT be deployed.",
          "displayName": "resource types not allowed",
          "strongType": "resourceTypes"
        }
      }
  })

  policy_rule =jsonencode({
    "if": {
          "field": "type",
          "in": "[parameters('listOfResourceTypesNotAllowed')]"
      },
      "then": {
        "effect": "deny"
      }
  })
}


#-----------------------------------------------------------------------------------------------------------------------
#********************** Core networking restrictions ******************** 
# This include both Network-interfaces-should-not-have-public-IPs  and management-ports-should-be-closed
##----------------------------------------------------------------------------------------------------------------------

resource "azurerm_policy_definition" "network_interfaces_should_not_have_public_ip" {
  
  name         = "Network-interfaces-should-not-have-public-IPs"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Network interfaces should not have public IPs"
  description = "This policy denies the network interfaces which are configured with any public IP. Public IP addresses allow internet resources to communicate inbound to Azure resources, and Azure resources to communicate outbound to the internet. This should be reviewed by the network security team. "


 metadata = jsonencode({
    "category": "Network",
    "version" : "1.0.0"
    })

  policy_rule =jsonencode({
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Network/networkInterfaces"
          },
          {
            "not": {
              "field": "Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id",
              "notLike": "*"
            }
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
    })
}



resource "azurerm_policy_definition" "management_ports_should_be_closed" {
  
  name         = "management-ports-should-be-closed"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Management ports should be closed on your virtual machines"
  description = "Open remote management ports are exposing your VM to a high level of risk from Internet-based attacks. These attacks attempt to brute force credentials to gain admin access to the machine."

 metadata = jsonencode({
    "category": "Network",
    "version" : "1.0.0"
    })

parameters = jsonencode({
    "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ],
        "defaultValue": "AuditIfNotExists"
      }
  })

  policy_rule =jsonencode({
      "if": {
        "field": "type",
        "in": [
          "Microsoft.Compute/virtualMachines",
          "Microsoft.ClassicCompute/virtualMachines"
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Security/assessments",
          "name": "bc303248-3d14-44c2-96a0-55f5c326b5fe",
          "existenceCondition": {
            "field": "Microsoft.Security/assessments/status.code",
            "in": [
              "Healthy"
            ]
          }
        }
      }
    })
}
#-----------------------------------------------------------------------------------------------------------------------
#********************** The Log Analytics agent should be installed on Virtual Machine Scale Sets ******************** 
##----------------------------------------------------------------------------------------------------------------------

resource "azurerm_policy_definition" "log_analytics_on_windows_vm" {
  
  name         = "Deploy-Log-Analytics-agent-for-windows-VMs"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deploy Log Analytics agent for windows VMs"
  description = "Deploy Log Analytics agent for Windows VMs if the VM Image (OS) is in the list defined and the agent is not installed."

  metadata = jsonencode({
    "category": "Monitoring",
    "version" : "2.0.0"
    })

parameters = jsonencode({
  "logAnalytics": {
        "type": "String",
        "metadata": {
          "displayName": "Log Analytics workspace",
          "description": "Select Log Analytics workspace from dropdown list. If this workspace is outside of the scope of the assignment you must manually grant 'Log Analytics Contributor' permissions (or similar) to the policy assignment's principal ID.",
          "strongType": "omsWorkspace",
          "assignPermissions": true
        }
      }
})

  policy_rule =jsonencode({
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "anyOf": [
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftWindowsServer"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "WindowsServer"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "in": [
                      "2008-R2-SP1",
                      "2008-R2-SP1-smalldisk",
                      "2012-Datacenter",
                      "2012-Datacenter-smalldisk",
                      "2012-R2-Datacenter",
                      "2012-R2-Datacenter-smalldisk",
                      "2016-Datacenter",
                      "2016-Datacenter-Server-Core",
                      "2016-Datacenter-Server-Core-smalldisk",
                      "2016-Datacenter-smalldisk",
                      "2016-Datacenter-with-Containers",
                      "2016-Datacenter-with-RDSH",
                      "2019-Datacenter",
                      "2019-Datacenter-Core",
                      "2019-Datacenter-Core-smalldisk",
                      "2019-Datacenter-Core-with-Containers",
                      "2019-Datacenter-Core-with-Containers-smalldisk",
                      "2019-Datacenter-smalldisk",
                      "2019-Datacenter-with-Containers",
                      "2019-Datacenter-with-Containers-smalldisk",
                      "2019-Datacenter-zhcn"
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftWindowsServer"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "WindowsServerSemiAnnual"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "in": [
                      "Datacenter-Core-1709-smalldisk",
                      "Datacenter-Core-1709-with-Containers-smalldisk",
                      "Datacenter-Core-1803-with-Containers-smalldisk"
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftWindowsServerHPCPack"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "WindowsServerHPCPack"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftSQLServer"
                  },
                  {
                    "anyOf": [
                      {
                        "field": "Microsoft.Compute/imageOffer",
                        "like": "*-WS2016"
                      },
                      {
                        "field": "Microsoft.Compute/imageOffer",
                        "like": "*-WS2016-BYOL"
                      },
                      {
                        "field": "Microsoft.Compute/imageOffer",
                        "like": "*-WS2012R2"
                      },
                      {
                        "field": "Microsoft.Compute/imageOffer",
                        "like": "*-WS2012R2-BYOL"
                      }
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftRServer"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "MLServer-WS2016"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftVisualStudio"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "in": [
                      "VisualStudio",
                      "Windows"
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftDynamicsAX"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "Dynamics"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "equals": "Pre-Req-AX7-Onebox-U8"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "microsoft-ads"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "windows-data-science-vm"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftWindowsDesktop"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "Windows-10"
                  }
                ]
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "deployIfNotExists",
        "details": {
          "type": "Microsoft.Compute/virtualMachines/extensions",
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
          ],
          "existenceCondition": {
            "allOf": [
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/type",
                "equals": "MicrosoftMonitoringAgent"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/publisher",
                "equals": "Microsoft.EnterpriseCloud.Monitoring"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/provisioningState",
                "equals": "Succeeded"
              }
            ]
          },
          "deployment": {
            "properties": {
              "mode": "incremental",
              "template": {
                "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "vmName": {
                    "type": "string"
                  },
                  "location": {
                    "type": "string"
                  },
                  "logAnalytics": {
                    "type": "string"
                  }
                },
                "variables": {
                  "vmExtensionName": "MicrosoftMonitoringAgent",
                  "vmExtensionPublisher": "Microsoft.EnterpriseCloud.Monitoring",
                  "vmExtensionType": "MicrosoftMonitoringAgent",
                  "vmExtensionTypeHandlerVersion": "1.0"
                },
                "resources": [
                  {
                    "name": "[concat(parameters('vmName'), '/', variables('vmExtensionName'))]",
                    "type": "Microsoft.Compute/virtualMachines/extensions",
                    "location": "[parameters('location')]",
                    "apiVersion": "2018-06-01",
                    "properties": {
                      "publisher": "[variables('vmExtensionPublisher')]",
                      "type": "[variables('vmExtensionType')]",
                      "typeHandlerVersion": "[variables('vmExtensionTypeHandlerVersion')]",
                      "autoUpgradeMinorVersion": true,
                      "settings": {
                        "workspaceId": "[reference(parameters('logAnalytics'), '2015-03-20').customerId]",
                        "stopOnMultipleConnections": "true"
                      },
                      "protectedSettings": {
                        "workspaceKey": "[listKeys(parameters('logAnalytics'), '2015-03-20').primarySharedKey]"
                      }
                    }
                  }
                ],
                "outputs": {
                  "policy": {
                    "type": "string",
                    "value": "[concat('Enabled extension for VM', ': ', parameters('vmName'))]"
                  }
                }
              },
              "parameters": {
                "vmName": {
                  "value": "[field('name')]"
                },
                "location": {
                  "value": "[field('location')]"
                },
                "logAnalytics": {
                  "value": "[parameters('logAnalytics')]"
                }
              }
            }
          }
        }
      }
    })
}


resource "azurerm_policy_definition" "log_analytics_on_linux_vm" {
  
  name         = "Deploy-Log-Analytics-agent-for-Linux-VMs"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deploy Log Analytics agent for Linux VMs"
  description = "Deploy Log Analytics agent for Linux VMs if the VM Image (OS) is in the list defined and the agent is not installed."

  metadata = jsonencode({
    "category": "Monitoring",
    "version" : "2.0.0"
    })

parameters = jsonencode({
  "logAnalytics": {
        "type": "String",
        "metadata": {
          "displayName": "Log Analytics workspace",
          "description": "Select Log Analytics workspace from dropdown list. If this workspace is outside of the scope of the assignment you must manually grant 'Log Analytics Contributor' permissions (or similar) to the policy assignment's principal ID.",
          "strongType": "omsWorkspace",
          "assignPermissions": true
        }
      }
})

  policy_rule =jsonencode({
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "anyOf": [
               {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "RedHat"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "in": [
                      "RHEL",
                      "RHEL-SAP-HANA"
                    ]
                  },
                  {
                    "anyOf": [
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "6.*"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "7*"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "8*"
                      }
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "SUSE"
                  },
                  {
                    "anyOf": [
                      {
                        "allOf": [
                          {
                            "field": "Microsoft.Compute/imageOffer",
                            "in": [
                              "SLES",
                              "SLES-HPC",
                              "SLES-HPC-Priority",
                              "SLES-SAP",
                              "SLES-SAP-BYOS",
                              "SLES-Priority",
                              "SLES-BYOS",
                              "SLES-SAPCAL",
                              "SLES-Standard"
                            ]
                          },
                          {
                            "anyOf": [
                              {
                                "field": "Microsoft.Compute/imageSKU",
                                "like": "12*"
                              },
                              {
                                "field": "Microsoft.Compute/imageSKU",
                                "like": "15*"
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "allOf": [
                          {
                            "anyOf": [
                              {
                                "field": "Microsoft.Compute/imageOffer",
                                "like": "sles-12-sp*"
                              },
                              {
                                "field": "Microsoft.Compute/imageOffer",
                                "like": "sles-15-sp*"
                              }
                            ]
                          },
                          {
                            "field": "Microsoft.Compute/imageSKU",
                            "in": [
                              "gen1",
                              "gen2"
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "Canonical"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "in": [
                      "UbuntuServer",
                      "0001-com-ubuntu-server-focal"
                    ]
                  },
                  {
                    "anyOf": [
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "14.04*LTS"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "16.04*LTS"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "16_04*lts-gen2"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "18.04*LTS"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "18_04*lts-gen2"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "20_04*lts"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "20_04*lts-gen2"
                      }
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "credativ"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "Debian"
                  },
                  {
                    "anyOf": [
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "8*"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "9*"
                      }
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "Oracle"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "Oracle-Linux"
                  },
                  {
                    "anyOf": [
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "6.*"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "7.*"
                      }
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "OpenLogic"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "in": [
                      "CentOS",
                      "Centos-LVM",
                      "CentOS-SRIOV"
                    ]
                  },
                  {
                    "anyOf": [
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "6.*"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "7*"
                      },
                      {
                        "field": "Microsoft.Compute/imageSKU",
                        "like": "8*"
                      }
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "cloudera"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "cloudera-centos-os"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "like": "7*"
                  }
                ]
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "deployIfNotExists",
        "details": {
          "type": "Microsoft.Compute/virtualMachines/extensions",
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
          ],
          "existenceCondition": {
            "allOf": [
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/type",
                "equals": "OmsAgentForLinux"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/publisher",
                "equals": "Microsoft.EnterpriseCloud.Monitoring"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/provisioningState",
                "equals": "Succeeded"
              }
            ]
          },
          "deployment": {
            "properties": {
              "mode": "incremental",
              "template": {
                "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "vmName": {
                    "type": "string"
                  },
                  "location": {
                    "type": "string"
                  },
                  "logAnalytics": {
                    "type": "string"
                  }
                },
                "variables": {
                  "vmExtensionName": "OMSAgentForLinux",
                  "vmExtensionPublisher": "Microsoft.EnterpriseCloud.Monitoring",
                  "vmExtensionType": "OmsAgentForLinux",
                  "vmExtensionTypeHandlerVersion": "1.13"
                },
                "resources": [
                  {
                    "name": "[concat(parameters('vmName'), '/', variables('vmExtensionName'))]",
                    "type": "Microsoft.Compute/virtualMachines/extensions",
                    "location": "[parameters('location')]",
                    "apiVersion": "2018-06-01",
                    "properties": {
                      "publisher": "[variables('vmExtensionPublisher')]",
                      "type": "[variables('vmExtensionType')]",
                      "typeHandlerVersion": "[variables('vmExtensionTypeHandlerVersion')]",
                      "autoUpgradeMinorVersion": true,
                      "settings": {
                        "workspaceId": "[reference(parameters('logAnalytics'), '2015-03-20').customerId]",
                        "stopOnMultipleConnections": "true"
                      },
                      "protectedSettings": {
                        "workspaceKey": "[listKeys(parameters('logAnalytics'), '2015-03-20').primarySharedKey]"
                      }
                    }
                  }
                ],
                "outputs": {
                  "policy": {
                    "type": "string",
                    "value": "[concat('Enabled extension for VM', ': ', parameters('vmName'))]"
                  }
                }
              },
              "parameters": {
                "vmName": {
                  "value": "[field('name')]"
                },
                "location": {
                  "value": "[field('location')]"
                },
                "logAnalytics": {
                  "value": "[parameters('logAnalytics')]"
                }
              }
            }
          }
        }
      }
  })
}


resource "azurerm_policy_definition" "log_analytics_on_windows_vm_scaleset" {
  
  name         = "Deploy-Log-Analytics-agent-for-windows-VM-scaleset"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deploy Log Analytics agent for windows VM scaleset"
  description = "Deploy Log Analytics agent for Windows virtual machine scale sets if the VM Image (OS) is in the list defined and the agent is not installed. The list of OS images is updated over time as support is updated. Note: if your scale set upgradePolicy is set to Manual, you need to apply the extension to all VMs in the set by calling upgrade on them. In CLI this would be az vmss update-instances."

  metadata = jsonencode({
    "category": "Monitoring",
    "version" : "2.0.0"
    })

parameters = jsonencode({
  "logAnalytics": {
        "type": "String",
        "metadata": {
          "displayName": "Log Analytics workspace",
          "description": "Select Log Analytics workspace from dropdown list. If this workspace is outside of the scope of the assignment you must manually grant 'Log Analytics Contributor' permissions (or similar) to the policy assignment's principal ID.",
          "strongType": "omsWorkspace",
          "assignPermissions": true
        }
      }
})

  policy_rule =jsonencode({
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachineScaleSets"
          },
          {
            "anyOf": [
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftWindowsServer"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "WindowsServer"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "in": [
                      "2008-R2-SP1",
                      "2008-R2-SP1-smalldisk",
                      "2012-Datacenter",
                      "2012-Datacenter-smalldisk",
                      "2012-R2-Datacenter",
                      "2012-R2-Datacenter-smalldisk",
                      "2016-Datacenter",
                      "2016-Datacenter-Server-Core",
                      "2016-Datacenter-Server-Core-smalldisk",
                      "2016-Datacenter-smalldisk",
                      "2016-Datacenter-with-Containers",
                      "2016-Datacenter-with-RDSH",
                      "2019-Datacenter",
                      "2019-Datacenter-Core",
                      "2019-Datacenter-Core-smalldisk",
                      "2019-Datacenter-Core-with-Containers",
                      "2019-Datacenter-Core-with-Containers-smalldisk",
                      "2019-Datacenter-smalldisk",
                      "2019-Datacenter-with-Containers",
                      "2019-Datacenter-with-Containers-smalldisk",
                      "2019-Datacenter-zhcn"
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftWindowsServer"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "WindowsServerSemiAnnual"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "in": [
                      "Datacenter-Core-1709-smalldisk",
                      "Datacenter-Core-1709-with-Containers-smalldisk",
                      "Datacenter-Core-1803-with-Containers-smalldisk"
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftWindowsServerHPCPack"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "WindowsServerHPCPack"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftSQLServer"
                  },
                  {
                    "anyOf": [
                      {
                        "field": "Microsoft.Compute/imageOffer",
                        "like": "*-WS2016"
                      },
                      {
                        "field": "Microsoft.Compute/imageOffer",
                        "like": "*-WS2016-BYOL"
                      },
                      {
                        "field": "Microsoft.Compute/imageOffer",
                        "like": "*-WS2012R2"
                      },
                      {
                        "field": "Microsoft.Compute/imageOffer",
                        "like": "*-WS2012R2-BYOL"
                      }
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftRServer"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "MLServer-WS2016"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftVisualStudio"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "in": [
                      "VisualStudio",
                      "Windows"
                    ]
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftDynamicsAX"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "Dynamics"
                  },
                  {
                    "field": "Microsoft.Compute/imageSKU",
                    "equals": "Pre-Req-AX7-Onebox-U8"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "microsoft-ads"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "windows-data-science-vm"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "Microsoft.Compute/imagePublisher",
                    "equals": "MicrosoftWindowsDesktop"
                  },
                  {
                    "field": "Microsoft.Compute/imageOffer",
                    "equals": "Windows-10"
                  }
                ]
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "deployIfNotExists",
        "details": {
          "type": "Microsoft.Compute/virtualMachineScaleSets/extensions",
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
            "/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c"
          ],
          "existenceCondition": {
            "allOf": [
              {
                "field": "Microsoft.Compute/virtualMachineScaleSets/extensions/type",
                "equals": "MicrosoftMonitoringAgent"
              },
              {
                "field": "Microsoft.Compute/virtualMachineScaleSets/extensions/publisher",
                "equals": "Microsoft.EnterpriseCloud.Monitoring"
              }
            ]
          },
          "deployment": {
            "properties": {
              "mode": "incremental",
              "template": {
                "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "vmName": {
                    "type": "string"
                  },
                  "location": {
                    "type": "string"
                  },
                  "logAnalytics": {
                    "type": "string"
                  }
                },
                "variables": {
                  "vmExtensionName": "MicrosoftMonitoringAgent",
                  "vmExtensionPublisher": "Microsoft.EnterpriseCloud.Monitoring",
                  "vmExtensionType": "MicrosoftMonitoringAgent",
                  "vmExtensionTypeHandlerVersion": "1.0"
                },
                "resources": [
                  {
                    "name": "[concat(parameters('vmName'), '/', variables('vmExtensionName'))]",
                    "type": "Microsoft.Compute/virtualMachineScaleSets/extensions",
                    "location": "[parameters('location')]",
                    "apiVersion": "2018-06-01",
                    "properties": {
                      "publisher": "[variables('vmExtensionPublisher')]",
                      "type": "[variables('vmExtensionType')]",
                      "typeHandlerVersion": "[variables('vmExtensionTypeHandlerVersion')]",
                      "autoUpgradeMinorVersion": true,
                      "settings": {
                        "workspaceId": "[reference(parameters('logAnalytics'), '2015-03-20').customerId]",
                        "stopOnMultipleConnections": "true"
                      },
                      "protectedSettings": {
                        "workspaceKey": "[listKeys(parameters('logAnalytics'), '2015-03-20').primarySharedKey]"
                      }
                    }
                  }
                ],
                "outputs": {
                  "policy": {
                    "type": "string",
                    "value": "[concat('Enabled extension for: ', parameters('vmName'))]"
                  }
                }
              },
              "parameters": {
                "vmName": {
                  "value": "[field('name')]"
                },
                "location": {
                  "value": "[field('location')]"
                },
                "logAnalytics": {
                  "value": "[parameters('logAnalytics')]"
                }
              }
            }
          }
        }
      }
    })
}

##--------------------------------------------------------------------------------------------------------------------