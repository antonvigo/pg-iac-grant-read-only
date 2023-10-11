variable "host" {
  description = "RDS connection data"
  type = object({
    host     = string
    port     = number
    username = string
    password = string
  })
}

variable "database" {
  description = "Database to manage permissions at"
  type = object({
    name  = string,
    owner = string
  })
}

variable "group_role" {
  description = "Group role to be granted with specified privileges"
  type        = string
  default     = "group_ro_all"
}

variable "make_admin_own" {
  description = "Is it necessary to grant admin user to database owner role or not. It is in case of RDS, because standard root account isn't a superuser."
  type        = bool
  default     = true
}

variable "revoke_grants" {
  description = "Revoke all grants which were provided by this module just before or not"
  type        = bool
  default     = false
}
