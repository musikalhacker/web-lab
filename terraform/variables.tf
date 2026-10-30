variable "location" {
  type    = string
  default = "centralus"   # or whatever region you prefer
}

variable "home_ip" {
  type        = string
  description = "Your home public IP (without /32)"
  # no default — set it in terraform.tfvars
}