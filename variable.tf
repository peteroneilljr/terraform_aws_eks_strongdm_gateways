variable "sdm_port" {
  description = "Listening port advertised by LoadBalancer"
  type = number
  default = 5000
}
variable "sdm_app_name" {
  description = "App name used by Kubernetes to sync services"
  type = string
}
variable "sdm_gateway_name" {
  description = "Logical name for the strongDM gateway"
  type = string
}