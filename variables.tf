variable "common_tags" {
  type = "map"
  default = {
    pipeline = "[pipeline-name]"
  }
}

variable "env" {
}

###########################################################
# Sample Resources - Everything past this point is optional
###########################################################
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  default     = "10.0.0.0/23"
}

variable "subnets_cidrs" {
  type        = "list"
  description = "The CIDR block for the private subnet"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "net" {
  description = "The unique suffix for the network"
  default     = "1"
}

variable "availability_zones" {
  type        = "list"
  description = "The az that the resources will be launched"
  default     = ["a", "b"]
}

variable "public" {
  description = "Whether the subnets should be public or not"
  default     = true
}

variable "access_cidr" {
  default = ["198.48.156.73/32"]
}
