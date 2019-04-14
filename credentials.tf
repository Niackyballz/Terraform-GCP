provider "google" {
    credentials =   "${file("terraform-project-26255213a767.json")}"
    project     =   "terraform-project-237408"
    region      =   "${var.region}"
}
