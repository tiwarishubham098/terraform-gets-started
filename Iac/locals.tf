locals {
  resource_group_name = format("%s-%s-%s-%s", var.org_name, var.project_name, var.environment_name, var.environment_instance)
}
