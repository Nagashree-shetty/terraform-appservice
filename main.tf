provider "azurerm"{
    #version = "=4.0"
    features {}    
}

resource "azurerm_resource_group" "tf_terraformrg"{
    name = "tf_rg"
    location = "West US"
}

# # Create an App Service Plan with Linux
resource "azurerm_service_plan" "terraformplan" {
  name                = "web-12345"
  location            = "${azurerm_resource_group.tf_terraformrg.location}"
  resource_group_name = "${azurerm_resource_group.tf_terraformrg.name}"
  os_type             = "Linux"
  sku_name            = "B1"

  
}



# # Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_linux_web_app" "newterraformapp" {
  name                = "newterraformapp1234"
  location            = "${azurerm_resource_group.tf_terraformrg.location}"
  resource_group_name = "${azurerm_resource_group.tf_terraformrg.name}"
  service_plan_id     = "${azurerm_service_plan.terraformplan.id}"
  https_only          = true

  site_config {
    application_stack{
      python_version = 3.8
   }
  }
  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
  }

  # identity {
  #   # type = "SystemAssigned"
  # }
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_linux_web_app.newterraformapp.id
  repo_url           = "https://github.com/Nagashree-shetty/terraform-appservice"
  branch             = "main"
  use_manual_integration = true
  use_mercurial      = false
}


resource "azurerm_monitor_action_group" "actiongrp" {
  name                = "monitor-actiongroupTF"
  resource_group_name = azurerm_resource_group.tf_terraformrg.name
  short_name          = "appactgrp"

  email_receiver {
    email_address        = "shreeshetty1319@gmail.com"
    name = "sendalerttoadmin"
  }
}

resource "azurerm_monitor_metric_alert" "monitor-app-service" {
  name                = "app-metricalert"
  resource_group_name = azurerm_resource_group.tf_terraformrg.name
  scopes              = [azurerm_linux_web_app.newterraformapp.id]
  
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Requests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1

  }

  action {
    action_group_id = azurerm_monitor_action_group.actiongrp.id
  }
}
