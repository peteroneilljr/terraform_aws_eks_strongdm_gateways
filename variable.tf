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