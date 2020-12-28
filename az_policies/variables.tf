
variable "management" {
    description = "(mandatory) management block"
}

variable "policy_definition_category" {
  type        = string
  description = "The category to use for all Policy Definitions"
  default     = "General"
}

variable "policyset_definition_category" {
  type        = string
  description = "The category to use for all PolicySet defintions"
  default     = "General"
}

variable "mandatory_tag_keys" {
  type        = map
  description = "List of mandatory tag keys used by policies 'addTagToRG','inheritTagFromRG','bulkAddTagsToRG','bulkInheritTagsFromRG'"
  default = {
      "Environment"="Prod",
      "Compliance"="General", 
      "Data Classification"="General Business", 
      "Criticality"="Mission-Critical",
      "Disaster Recovery"="Essential"
  }
}

variable "mandatory_tag_to_inherit" {
  type        = list
  description = "List of tag to inherit from resource group"
  default = [
      "Environment",
      "Compliance" ,
      "Data Classification" ,
      "Criticality",
      "Disaster Recovery"
  ]
}

variable "mandatory_tag_to_resoures" {
  type        = map
  description = "Defines required tags on resources"
  default = {
      "Environment"="Prod",
      "DRSLATier"="TBA", 
      "CostCentre"="TBA"
  }
}

variable "application_tags" {
  type        = map
  description = "List of mandatory tag keys used by policies 'addTagToRG','inheritTagFromRG','bulkAddTagsToRG','bulkInheritTagsFromRG'"
  default = {
      "sharedInfrastructure_rg"={
       "Tag_Name"="Application",
       "Tag_Value"= "SharedInfrastructure",
       resource_groups = [ "rg-wl-prod-sharedinfra" ]
      },
      "coreInfrastructure_rg"={
       "Tag_Name"="Application",
       "Tag_Value"= "CoreInfrastructure",
       resource_groups = [ "rg-wl-hub-vnet","rg-wl-mgmt-vnet","rg-wl-prod-mgmt-infra","rg-wl-prod-mgmt-tooling","rg-wl-prod-mgmt-security","rg-wl-prod-monitoring","rg-wl-prod-externaldmz","rg-wl-prod-internaldmz" ]
      }
  }
}

variable "allowedLocations" {
  type = list
  description = "(mandatory) allowed locations"
  default =[ "eastus","eastus2","westus","westus2" ]
}
variable "mandatory_tag_value" {
  type        = string
  description = "Tag value to include with the mandatory tag keys used by policies 'addTagToRG','inheritTagFromRG','bulkAddTagsToRG','bulkInheritTagsFromRG'"
  default     = "TBC"
}



variable "list_of_resources_not_allowed" {
  type = list
  description = "(mandatory) list of resources not allowed"
  default =[ "livearena.broadcast/listcommunicationpreference"]

}

variable "allowed_vm_skus" {
  type = list
  description = "(mandatory) allowed VM SKU"
  default =[ "Standard_A1_v2",
"Standard_A2m_v2",
"Standard_A2_v2",
"Standard_A4m_v2",
"Standard_A4_v2",
"Standard_A8m_v2",
"Standard_A8_v2",
"Standard_A0",
"Standard_A1",
"Standard_A2",
"Standard_A3",
"Standard_A5",
"Standard_A4",
"Standard_A6",
"Standard_A7",
"Basic_A0",
"Basic_A1",
"Basic_A2",
"Basic_A3",
"Basic_A4",
"Standard_A8",
"Standard_A9",
"Standard_A10",
"Standard_A11",
"Standard_B1ls",
"Standard_B1ms",
"Standard_B1s",
"Standard_B2ms",
"Standard_B2s",
"Standard_B4ms",
"Standard_B8ms",
"Standard_B12ms",
"Standard_B16ms",
"Standard_B20ms",
"Standard_DS1_v2",
"Standard_DS2_v2",
"Standard_DS3_v2",
"Standard_DS4_v2",
"Standard_DS5_v2",
"Standard_DS11-1_v2",
"Standard_DS11_v2",
"Standard_DS12-1_v2",
"Standard_DS12-2_v2",
"Standard_DS12_v2",
"Standard_DS13-2_v2",
"Standard_DS13-4_v2",
"Standard_DS13_v2",
"Standard_DS14-4_v2",
"Standard_DS14-8_v2",
"Standard_DS14_v2",
"Standard_DS15_v2",
"Standard_DS2_v2_Promo",
"Standard_DS3_v2_Promo",
"Standard_DS4_v2_Promo",
"Standard_DS5_v2_Promo",
"Standard_DS11_v2_Promo",
"Standard_DS12_v2_Promo",
"Standard_DS13_v2_Promo",
"Standard_DS14_v2_Promo",
"Standard_D2s_v3",
"Standard_D4s_v3",
"Standard_D8s_v3",
"Standard_D16s_v3",
"Standard_D32s_v3",
"Standard_D1_v2",
"Standard_D2_v2",
"Standard_D3_v2",
"Standard_D4_v2",
"Standard_D5_v2",
"Standard_D11_v2",
"Standard_D12_v2",
"Standard_D13_v2",
"Standard_D14_v2",
"Standard_D15_v2",
"Standard_D2_v2_Promo",
"Standard_D3_v2_Promo",
"Standard_D4_v2_Promo",
"Standard_D5_v2_Promo",
"Standard_D11_v2_Promo",
"Standard_D12_v2_Promo",
"Standard_D13_v2_Promo",
"Standard_D14_v2_Promo",
"Standard_D2_v3",
"Standard_D4_v3",
"Standard_D8_v3",
"Standard_D16_v3",
"Standard_D1",
"Standard_D2",
"Standard_D3",
"Standard_D4",
"Standard_D11",
"Standard_D12",
"Standard_D13",
"Standard_D14",
"Standard_D2d_v4",
"Standard_D4d_v4",
"Standard_D8d_v4",
"Standard_D16d_v4",
"Standard_D32d_v4",
"Standard_D2_v4",
"Standard_D4_v4",
"Standard_D8_v4",
"Standard_D16_v4",
"Standard_D32_v4",
"Standard_D2ds_v4",
"Standard_D4ds_v4",
"Standard_D8ds_v4",
"Standard_D16ds_v4",
"Standard_D32ds_v4",
"Standard_D2s_v4",
"Standard_D4s_v4",
"Standard_D8s_v4",
"Standard_D16s_v4",
"Standard_D32s_v4",
"Standard_DC2s",
"Standard_DC4s",
"Standard_DC8_v2",
"Standard_DC1s_v2",
"Standard_DC2s_v2",
"Standard_DC4s_v2",
"Standard_NP10s",
"Standard_NP20s",
"Standard_NP40s",
"Standard_DS1",
"Standard_DS2",
"Standard_DS3",
"Standard_DS4",
"Standard_DS11",
"Standard_DS12",
"Standard_DS13",
"Standard_DS14",
"Standard_D2a_v4",
"Standard_D4a_v4",
"Standard_D8a_v4",
"Standard_D16a_v4",
"Standard_D32a_v4",
"Standard_D48a_v4",
"Standard_D64a_v4",
"Standard_D96a_v4",
"Standard_D2as_v4",
"Standard_D4as_v4",
"Standard_D8as_v4",
"Standard_D16as_v4",
"Standard_D32as_v4",
"Standard_F1s",
"Standard_F2s",
"Standard_F4s",
"Standard_F8s",
"Standard_F16s",
"Standard_F1",
"Standard_F2",
"Standard_F4",
"Standard_F8",
"Standard_F16",
"Standard_F2s_v2",
"Standard_F4s_v2",
"Standard_F8s_v2",
"Standard_F16s_v2",
"Standard_F32s_v2",
"Standard_E2_v4",
"Standard_E4_v4",
"Standard_E8_v4",
"Standard_E16_v4",
"Standard_E20_v4",
"Standard_E32_v4",
"Standard_E2d_v4",
"Standard_E4d_v4",
"Standard_E8d_v4",
"Standard_E16d_v4",
"Standard_E20d_v4",
"Standard_E32d_v4",
"Standard_E2s_v4",
"Standard_E4-2s_v4",
"Standard_E4s_v4",
"Standard_E8-2s_v4",
"Standard_E8-4s_v4",
"Standard_E8s_v4",
"Standard_E16-4s_v4",
"Standard_E16-8s_v4",
"Standard_E16s_v4",
"Standard_E20s_v4",
"Standard_E32-8s_v4",
"Standard_E32-16s_v4",
"Standard_E32s_v4",
"Standard_E2ds_v4",
"Standard_E4-2ds_v4",
"Standard_E4ds_v4",
"Standard_E8-2ds_v4",
"Standard_E8-4ds_v4",
"Standard_E8ds_v4",
"Standard_E16-4ds_v4",
"Standard_E16-8ds_v4",
"Standard_E16ds_v4",
"Standard_E20ds_v4",
"Standard_E32-8ds_v4",
"Standard_E32-16ds_v4",
"Standard_E32ds_v4",
"Standard_E2_v3",
"Standard_E4_v3",
"Standard_E8_v3",
"Standard_E16_v3",
"Standard_E20_v3",
"Standard_E32_v3",
"Standard_E2s_v3",
"Standard_E4-2s_v3",
"Standard_E4s_v3",
"Standard_E8-2s_v3",
"Standard_E8-4s_v3",
"Standard_E8s_v3",
"Standard_E16-4s_v3",
"Standard_E16-8s_v3",
"Standard_E16s_v3",
"Standard_E20s_v3",
"Standard_E32-8s_v3",
"Standard_E32-16s_v3",
"Standard_E32s_v3",
"Standard_E2a_v4",
"Standard_E4a_v4",
"Standard_E8a_v4",
"Standard_E16a_v4",
"Standard_E20a_v4",
"Standard_E32a_v4",
"Standard_E2as_v4",
"Standard_E4-2as_v4",
"Standard_E4as_v4",
"Standard_E8-2as_v4",
"Standard_E8-4as_v4",
"Standard_E8as_v4",
"Standard_E16-4as_v4",
"Standard_E16-8as_v4",
"Standard_E16as_v4",
"Standard_E20as_v4",
"Standard_E32-8as_v4",
"Standard_E32-16as_v4",
"Standard_E32as_v4",
"Standard_L8s_v2",
"Standard_L16s_v2",
"Standard_L32s_v2",
]
}