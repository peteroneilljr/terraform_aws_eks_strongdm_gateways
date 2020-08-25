variable "sdm_port" {
  description = "Listening port advertised by LoadBalancer"
  type        = number
  default     = 5000
}
variable "sdm_app_name" {
  description = "App name used by Kubernetes to sync services"
  type        = string
}
variable "sdm_gateway_name" {
  description = "Logical name for the strongDM gateway"
  type        = string
}
variable "namespace" {
  type        = string
  description = "Namespace used to seperate strongDM gateways"
  default     = "sdm-gateway"
}
variable "gateway_count" {
  type        = number
  description = "Number of strongDM gateways to create"
  default     = 1
}
variable "dev_mode" {
  type        = bool
  description = "Create pods with a lower resource request for testing"
  default     = false
}
variable "expose_on_node_port" {
  type        = bool
  description = "Exposes gateways on the node's IP instead of creating a load balancer"
  default     = false
}
variable "resources_depends_on" {
  type        = any
  description = "Used to create a dependcy on resources created in other modules"
  default     = null
}