variable "rg" {
  type    = string
  default = ""
}

variable "prodresourcegroup" {
  type    = string
  default = ""
}

variable "tags" {
  type = map(any)
  default = {
    "Created By" = "amit.singh"
    ENV          = "Prod"
    Client       = "Acme"
    "Created On" = "28 July 2024"
  }
}

variable "vnetaddress" {
  type    = string
  default = ""
}

variable "appsubnetaddress" {
  type    = string
  default = ""
}
variable "middlesubnetaddress" {
  type    = string
  default = ""
}
variable "dbsubnetaddress" {
  type    = string
  default = ""
}

variable "dns" {
  type = object({
    dns1 = string
    dns2 = string
  })
}

variable "clientname" {
  type    = string
  default = ""
}

variable "location" {
  type    = string
  default = ""
}
