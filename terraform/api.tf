
resource "azurerm_api_management" "api_management_service" {
  name                = "${var.resource_prefix}-api-management"
  location            = azurerm_resource_group.backend_resources.location
  resource_group_name = azurerm_resource_group.backend_resources.name
  publisher_name      = var.resource_prefix
  publisher_email     = var.company_email

  sku_name = "Consumption_0"

  protocols {
    enable_http2 = true
  }

  security {
    enable_backend_ssl30 = true
    enable_backend_tls10 = true
    enable_backend_tls11 = true
  }

  depends_on = [ azurerm_resource_group.backend_resources, data.azurerm_storage_account.primary_storage_account ]
}

resource "azurerm_service_plan" "api_function_app_service_plan" {
  name                     = "${var.resource_prefix}-function-app-service-plan"
  resource_group_name      = azurerm_resource_group.backend_resources.name
  location                 = var.resource_location
  os_type                  = "Linux"
  sku_name                 = "B1"
}


resource "azurerm_linux_function_app" "api_function_app" {
  name                     = "${var.resource_prefix}-api-function-app"
  resource_group_name      = azurerm_resource_group.backend_resources.name
  location                 = var.resource_location

  storage_account_name       = var.storage_account_name
  storage_account_access_key = data.azurerm_storage_account.primary_storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.api_function_app_service_plan.id

  site_config {
    cors {
      allowed_origins = ["*"]
    }
    application_stack {
      docker {
        registry_url = azurerm_container_registry.container_registry.login_server
        image_name =  var.api_docker_image_name
        image_tag = var.api_docker_image_tag
        registry_username = azurerm_container_registry.container_registry.admin_username
        registry_password = azurerm_container_registry.container_registry.admin_password
      }
    }
  }

   app_settings = {
     WEBSITES_ENABLE_APP_SERVICE_STORAGE  = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    developer   = "Yogesh"
    environment = var.environment
  }

  depends_on = [ azurerm_service_plan.api_function_app_service_plan ]
}

data "azurerm_linux_function_app" "api_function_app_data" {
  name = azurerm_linux_function_app.api_function_app.name
  resource_group_name = azurerm_resource_group.backend_resources.name

  depends_on = [ azurerm_linux_function_app.api_function_app ]
}


resource "azurerm_role_assignment" "mobile_api_function_app_acr_image_pull_access" {
  scope                = azurerm_container_registry.container_registry.login_server
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_linux_function_app.api_function_app_data.identity.0.principal_id
  depends_on = [ data.azurerm_linux_function_app.api_function_app_data ]
}



data "azurerm_function_app_host_keys" "api_function_host_keys" {
  name                = azurerm_linux_function_app.api_function_app.name
  resource_group_name = azurerm_resource_group.backend_resources.name
}


resource "azurerm_api_management_backend" "api_backend" {
  name                = "${var.resource_prefix}-api-function-app-backend"
  resource_group_name = azurerm_resource_group.backend_resources.name
  api_management_name = azurerm_api_management.api_management_service.name
  protocol            = "http"
  url                 = "https://${azurerm_linux_function_app.api_function_app.name}.azuremobilesites.net/api/"
  credentials {
    header = {
      "x-functions-key" = data.azurerm_function_app_host_keys.api_function_host_keys.default_function_key
    }
  }

  depends_on = [
    azurerm_linux_function_app.api_function_app,
    data.azurerm_function_app_host_keys.api_function_host_keys
  ]
}


resource "azurerm_api_management_api" "api" {
  name                = "${var.resource_prefix}-api"
  resource_group_name = azurerm_resource_group.backend_resources.name
  api_management_name = azurerm_api_management.api_management_service.name
  revision            = "1"
  display_name        = "${var.resource_prefix}-mobile-api"
  api_type            = "http"
  path                = "api"
  protocols           = ["https"]
  subscription_required = false

  import {
    content_format = "openapi"
    content_value  = file("${path.module}/docs.yml")
  }
}

resource "azurerm_api_management_api_policy" "api_backend_policy" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.api_management_service.name
  resource_group_name = azurerm_resource_group.backend_resources.name

  xml_content = <<XML
<policies>
  <inbound>
    <base/>
    <set-backend-service backend-id="${azurerm_api_management_backend.api_backend.name}" />
  </inbound>
</policies>
XML

  depends_on = [ azurerm_api_management_api.api, azurerm_api_management_backend.api_backend ]
}