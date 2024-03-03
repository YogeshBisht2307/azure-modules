resource "azurerm_resource_group" "container_hub" {
  name     = "${var.resource_prefix}-resource-hub"
  location = var.resource_location
}

resource "azurerm_container_registry" "container_registry" {
  name                = "${var.resource_prefix}containerhub"
  resource_group_name = azurerm_resource_group.container_hub.name
  location            = azurerm_resource_group.container_hub.location
  sku                 = "Standard"
  admin_enabled       = true

  depends_on = [ azurerm_resource_group.container_hub ]
}

resource "null_resource" "acr_login" {
  triggers = {
    api_docker_image_name = var.api_docker_image_name
    api_docker_image_tag = var.api_docker_image_tag
  }
  provisioner "local-exec" {
    command = "az acr login --name ${azurerm_container_registry.container_registry.name}"
  }
}

resource "null_resource" "docker_login" {
  triggers = {
    api_docker_image_name = var.api_docker_image_name
    api_docker_image_tag = var.api_docker_image_tag
  }

  provisioner "local-exec" {
    command = "echo ${azurerm_container_registry.container_registry.admin_password} | docker login ${azurerm_container_registry.container_registry.login_server} --username ${azurerm_container_registry.container_registry.admin_username} --password-stdin"
  }

  depends_on = [ null_resource.acr_login ]
}



resource "null_resource" "api_image_tagging" {
  triggers = {
    api_docker_image_name = var.api_docker_image_name
    api_docker_image_tag = var.api_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker image tag ${var.api_docker_image_name}:${var.api_docker_image_tag} ${azurerm_container_registry.container_registry.login_server}/${var.api_docker_image_name}:${var.api_docker_image_tag}"
  }

  depends_on = [ null_resource.docker_login ]
}


resource "null_resource" "api_docker_image_push" {
  triggers = {
    api_docker_image_name = var.api_docker_image_name
    api_docker_image_tag = var.api_docker_image_tag
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.container_registry.login_server}/${var.api_docker_image_name}:${var.api_docker_image_tag}"
  }

  depends_on = [ null_resource.api_image_tagging ]
}
