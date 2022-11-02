#
Azure DevOps


1. Create a pipeline in Azure DevOps using YAML
2. Validate the Terraform code as part of the pipeline (validate and format)
3. Move 'tfvars' and sensitive data into Azure Key Vault


## Setup

*Download this code and set the following ENV and Terraform variables before running Terraform:*




Variables that will need updating in 'variables.tf' before running the terraform code:

```

ado_org_service_url

ado_github_repo               - (change to reflect sample cloned repo OR own repo for testing pipeline)

ado_pipeline_yaml_path_1      - (if using the example repo above this shouldn’t need a change)
```



Set the Terrafor ENV variables 
```
export TF_VAR_ado_github_repo=“ “
export TF_VAR_az_tenant=“ “
export TF_VAR_az_client_secret=“ “
export TF_VAR_ado_org_service_url=“ “
export TF_VAR_az_subscription=“ “
export TF_VAR_az_client_id=“ “
export TF_VAR_ado_github_pat=“ “         
export TF_VAR_ado_azdevops_pat=“ “         

# Terraform using SP to run code
export ARM_SUBSCRIPTION_ID=“ “
export ARM_TENANT_ID=“ “ 
export ARM_CLIENT_SECRET=“ “ 
export ARM_CLIENT_ID=“ “

# for azdevops org pat
 export AZDO_PERSONAL_ACCESS_TOKEN=“ “

# used for GH serviceendpoint_github
export AZDO_GITHUB_SERVICE_CONNECTION_PAT=“ “
  
```




## Run

```
terraform init
terraform plan 
terraform apply
```





