
variable "name_company" {
  type        = string
  description = "Company name"
}

variable "name_project" {
  type        = string
  description = "Project name"
}

variable "name_component" {
  type        = string
  description = "Name of the component being worked on, e.g. api"
}

variable "resource_group_name" {
  type        = string
  default     = "stacks-docker-images"
  description = "Name of the resource group for be used for the ACR"
}

variable "registry_admin_enabled" {
  type        = bool
  default     = true
  description = "State if the registry admin user should be enabled"
}

variable "anonymous_pull_enabled" {
  type        = bool
  default     = true
  description = "State if anonymous pull from the ACR should be anabled"
}

variable "registry_sku" {
  type        = string
  default     = "standard"
  description = "The SKU of the Azure Container Registry"
}

variable "location" {
  default     = "westeurope"
  description = "The location/region where the resources will be created"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to be used, this is used to name the resources"
}

variable "attributes" {
  description = "Additional attributes for tagging"
  default     = []
}
