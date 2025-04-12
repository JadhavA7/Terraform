variable "my_access" {
  type = string
  default = "access_key"
}
variable "my_secret" {
  type = string
  default = "secret_key"
}
variable "inst_type" {
    type = map
   default = {
    default = "t2.micro"
    dev = "t2.nano"
    test = "t2.small"
    prod = "t2.medium"
  }
}
variable "my_ami" {
   type = string
   default = "ami-00bb6a80f01f03502"
}
