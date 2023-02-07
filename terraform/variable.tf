variable "type" {
  default = {
    "test"    = "t3.micro"
    "prod"    = "t3.medium"
    "nonprod" = "t2.micro"
    "staging" = "t2.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

variable "env" {
  default     = "nonprod"
  type        = string
  description = "Deployment Environment"
}
