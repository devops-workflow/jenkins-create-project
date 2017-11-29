/**
 *  Variables for MODULE
**/

// Standard Variables

variable "name" {
  description = "Name"
}
variable "environment" {
  description = "Environment (ex: dev, qa, stage, prod)"
}
variable "namespaced" {
  description = "Namespace all resources (prefixed with the environment)?"
  default     = true
}
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

// Module specific Variables

variables "tags_example" {
  type = "map"
  default = {
    team        = "unknown"
    product     = "unknown"
    service     = "unknown"
    owner       = "unknown"
  }
}
