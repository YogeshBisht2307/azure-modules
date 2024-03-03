variable "resource_prefix" {
  type = string
  description = "resource prefix for the resource"
  nullable = false
}

variable "resource_location" {
  type = string
  description = "Resource location"
  nullable = false
}

variable "storage_account_name" {
  type = string
  description = "storage account name"
  nullable = false
}

variable "api_docker_image_name" {
  type = string
  description = "api docker image name"
  nullable = false
}

variable "api_docker_image_tag" {
  type = string
  description = "api docker image tag"
  nullable = false
}

variable "environment" {
  type = string
  description = "Environment"
  nullable = false
}

variable "company_email" {
  type = string
  description = "Company Email"
  nullable = false
}

variable "portal_resource_group" {
  type = string
  description = "portal resource group"
  nullable = false
}

