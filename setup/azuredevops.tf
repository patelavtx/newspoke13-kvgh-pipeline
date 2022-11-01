# Create ADO objects for pipeline

provider "azuredevops" {
  org_service_url = var.ado_org_service_url
  #personal_access_token = var.AZDO_PERSONAL_ACCESS_TOKEN   ; exported as ENV variable.
}

# Create project.
resource "azuredevops_project" "project" {
  name               = local.ado_project_name
  description        = local.ado_project_description
  visibility         = local.ado_project_visibility
  version_control    = "Git"   
  work_item_template = "Agile"  #  Not sure on this

  features = {
    # Only enable pipelines for now
    "testplans"    = "disabled"
    "artifacts"    = "disabled"
    "boards"       = "disabled"
    "repositories" = "enabled"   #added , but not needed when GH repo is used and not AzDevOPs; though can then easily import GH repo to AzDO repo
    "pipelines"    = "enabled"
  }
}

# set environment -  (Which can be then referred to in the yaml file for 'approval/checks' during the stage runs)
resource "azuredevops_environment" "example" {
  project_id = azuredevops_project.project.id
  name       = "spoke13-kv"
}


## Service connections
# Service conn for azurerm 
resource "azuredevops_serviceendpoint_azurerm" "serviceendpoint_azurerm" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "atulavtx-sst2"
  description           = "Managed by Terraform"
  credentials {
    serviceprincipalid  = var.az_client_id
    serviceprincipalkey = var.az_client_secret
  }
  azurerm_spn_tenantid      = var.az_tenant
  azurerm_subscription_id   = var.az_subscription
  azurerm_subscription_name = "CSP-AVTX-apatel"
}

## Authorize Project pipelines to use svc conn.
# added Auth project to use azurerm conn
resource "azuredevops_resource_authorization" "azurerm" {
  project_id  = azuredevops_project.project.id
  resource_id = azuredevops_serviceendpoint_azurerm.serviceendpoint_azurerm.id
  authorized  = true
}



# Use if trying to connect to GH repo ################################
# GH conn - Check if ENV works ; but pull repo to project using GH pat
resource "azuredevops_serviceendpoint_github" "serviceendpoint_github" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "GH-spokeado13"    

  auth_personal {
    personal_access_token = var.ado_github_pat   #  doc suggests variable is AZDO_GITHUB_SERVICE_CONNECTION_PAT
  }
}


## Authorize Project Pipelines to use svc conn.
# added Auth project to use GH conn
resource "azuredevops_resource_authorization" "auth" {
  project_id  = azuredevops_project.project.id
  resource_id = azuredevops_serviceendpoint_github.serviceendpoint_github.id
  authorized  = true
}


#  Make use of pipeline VG to pull secrets from key vault
resource "azuredevops_variable_group" "variablegroup" {
  project_id   = azuredevops_project.project.id
  name         = "spoke13-kv"
  description  = "Variable group for pipelines"
  allow_access = true

  variable {
    name  = "service_name"     # service endpoint
    value = "key_vault"
  }

  variable {
    name = "key_vault_name"
    value = local.az_key_vault_name
  }

}


 # Create pipeline -  svc conn with GH repo (need to try az repo)
resource "azuredevops_build_definition" "pipeline_1" {
  depends_on = [azuredevops_resource_authorization.auth]
  project_id = azuredevops_project.project.id
  name       = local.ado_pipeline_name_1

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = var.ado_github_repo
    branch_name           = "main"
    yml_path              = var.ado_pipeline_yaml_path_1
    service_connection_id = azuredevops_serviceendpoint_github.serviceendpoint_github.id
  }

}


