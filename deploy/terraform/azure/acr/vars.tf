
variable "name_company" {
    type = string
}

variable "name_project" {
    type = string
}

variable "name_component" {
    type = string
}

variable "resource_group_name" {
    type = string
    default = "stacks-docker-images"
}

variable "registry_admin_enabled" {
    type = bool
    default = true
}

variable "anonymous_pull_enabled" {
    type = bool
    default = true
}

variable "registry_sku" {
    type = string
    default = "standard"
}

variable "location" {
    default = "westeurope"
}

variable "tags" {
    type = map(string)
    default = {}
}

variable "attributes" {
  description = "Additional attributes for tagging"
  default     = []
}
