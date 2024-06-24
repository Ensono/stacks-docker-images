# Create a random string as a suffix to the end of KV name
# this is to help when destorying and redeploying instances
resource "random_string" "namesuffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

module "default_label" {
  source          = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  namespace       = format("%s-%s", substr(var.name_company, 0, 16), substr(var.name_project, 0, 16))
  name            = "${lookup(local.location_name_map, var.location)}-${substr(var.name_component, 0, 16)}"
  attributes      = concat([random_string.namesuffix.result], var.attributes)
  delimiter       = "-"
  id_length_limit = 60
  tags            = merge(var.tags, local.tags)
}
