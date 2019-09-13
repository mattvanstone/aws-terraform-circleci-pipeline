variable "common_tags" {
  type = "map"
  default = {
    pipeline = "[pipeline-name]"
  }
}

variable "env" {
}
