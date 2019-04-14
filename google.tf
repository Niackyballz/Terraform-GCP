resource "google_compute_network" "default" {
  name          =   "custom-network1"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "net1" {
  name          =   "net1"
  ip_cidr_range =   "192.168.0.0/24"
  network       =   "${google_compute_network.default.self_link}"
}

resource "google_compute_firewall" "http-nginx" {
  name          =   "http-nginx"
  network       =   "${google_compute_network.default.name}"
  target_tags   =   ["nginx"]
  source_ranges =   ["0.0.0.0/0"]

  allow {
    protocol    =  "tcp"
    ports       =  ["80","443"]
    }
}


resource "google_compute_firewall" "ssh-nginx" {
  name          =   "ssh-nginx"
  network       =   "${google_compute_network.default.name}"
  target_tags   =   ["nginx"]
  source_ranges =   ["0.0.0.0/0"]

  allow {
    protocol    =  "tcp"
    ports       =  ["22"]
  }
}
//Open port for test app in vm
resource "google_compute_firewall" "flask-app" {
  name          =   "flask-app"
  network       =   "${google_compute_network.default.name}"
  target_tags   =   ["nginx"]
  source_ranges =   ["0.0.0.0/0"]

  allow {
    protocol    =  "tcp"
    ports       =  ["5000"]
  }
}
resource "google_compute_disk" "disk-nginx-front" {
  count         =   "${var.NodeCount}"
  name          =   "disk-nginx-front-${count.index + 1}"
  type          =   "pd-standard"
  zone          =   "${var.zone}"
  image         =   "debian-9-stretch-v20190326"
}

resource "google_compute_disk" "disk-nginx-back" {
  count         =   "${var.NodeCount}"
  name          =   "disk-nginx-back-${count.index + 1}"
  type          =   "pd-standard"
  zone          =   "${var.zone}"
  image         =   "debian-9-stretch-v20190326"
}

resource "google_compute_project_metadata_item" "sshkey" {
  key           =   "ssh-keys"
  value         =   "dylan:${file(var.sshkey)}"
}

resource "google_compute_instance" "nginx-front" {
  count         =   "${var.NodeCount}"
  name          =   "nginx-front${count.index + 1}"
  machine_type  =   "n1-standard-1"
  tags          =   ["nginx","front"]
  metadata_startup_script = "${file("./install-nginx.sh")}"
  zone          =   "${var.zone}"
//  metadata   {
//    sshKeys     =    "dylan.felizardo@gmail.com:${file(var.sshkey)}"
//  } 
  boot_disk  {
    source      =  "${element(google_compute_disk.disk-nginx-front.*.self_link, count.index)}"
  }
  network_interface {
    subnetwork  =    "${google_compute_subnetwork.net1.self_link}"
    access_config {
    }
  }
}
resource "google_compute_instance" "nginx-back" {
  count         =   "${var.NodeCount}"
  name          =   "nginx-back${count.index + 1}"
  machine_type  =   "n1-standard-1"
  tags          =   ["nginx","back"]
  metadata_startup_script = "${file("./install-nginx.sh")}"
  zone          =   "${var.zone}"
//  metadata   {
//    sshKeys     =    "dylan.felizardo@gmail.com:${file(var.sshkey)}"
//  } 
  boot_disk  {
    source      =  "${element(google_compute_disk.disk-nginx-back.*.self_link, count.index)}"
  }
  network_interface {
    subnetwork  =    "${google_compute_subnetwork.net1.self_link}"
    access_config {
    }
  }
}
