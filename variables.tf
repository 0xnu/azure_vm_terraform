# Definition of vars
variable "subscription_id" {
  description = "Target Subscription"
}

variable "location" {}

variable "admin_password" {
  type        = string
  description = "VM Password"
}

variable "admin_username" {
  type        = string
  description = "VM Username"
}