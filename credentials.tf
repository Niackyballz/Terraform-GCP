provider "google" {
    credentials =   "${file("terraform-project-1d3464948416.json")}"
    project     =   "terraform-project-237408"
    region      =   "${var.region}"
}
