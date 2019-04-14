variable "region" {
  default      =    "us-central1"
}
variable "zone" {
  default       =   "us-central1-a"
}
variable "NodeCount" {
  type ="string"
  default ="2"
  description = "Number of Nodes"
}

variable "sshkey" {
  default = "../id_rsa_terraform-gcp.pub"
}