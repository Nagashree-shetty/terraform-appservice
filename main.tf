provider "azurerm"{
    #version = "=4.0"
    features {}    
}

resource "azurerm_resource_group" "tf_terraformrg"{
    name = "tf_terraformrgnew"
    location = "East US"
}

# # Create an App Service Plan with Linux
resource "azurerm_service_plan" "terraformplan" {
  name                = "${azurerm_resource_group.tf_terraformrg}-terraformplan"
  location            = "${azurerm_resource_group.tf_terraformrg.location}"
  resource_group_name = "${azurerm_resource_group.tf_terraformrg.name}"
  os_type             = "Linux"
  sku_name            = "F1"
}



# # Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_linux_web_app" "newterraformapp" {
  name                = "${azurerm_resource_group.tf_terraformrg.name}-newterraformapp"
  location            = "${azurerm_resource_group.tf_terraformrg.location}"
  resource_group_name = "${azurerm_resource_group.tf_terraformrg.name}"
  service_plan_id = "${azurerm_service_plan.terraformplan.id}"

 

  site_config {
    linux_fx_version = "nagashreeshetty/newpythonwebapp"
    always_on        = "true"
  }

  identity {
    type = "SystemAssigned"
  }
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_linux_web_app.newterraformapp.id
  repo_url           = "https://github.com/Nagashree-shetty/terraform-appservice"
  branch             = "main"
  use_manual_integration = true
  use_mercurial      = false
}


