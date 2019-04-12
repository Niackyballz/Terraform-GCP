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

resource "google_compute_disk" "disk-nginx" {
  count         =   "${var.Count}"
  name          =   "disk-nginx-${count.index + 1}"
  type          =   "pd-standard"
  zone          =   "${var.zone}"
  image         =   "debian-9-stretch-v20190326"
}

resource "google_compute_instance" "nginx" {
  count         =   "${var.Count}"
  name          =   "nginx-${count.index + 1}"
  machine_type  =   "n1-standard-1"
  tags          =   ["nginx"]
  metadata_startup_script = "${file("./install-nginx.sh")}"
  zone          =   "${var.zone}"
  boot_disk  {
    source      =  "${element(google_compute_disk.disk-nginx.*.self_link, count.index)}"
  }
  network_interface {
    subnetwork  =    "${google_compute_subnetwork.net1.self_link}"
    access_config {
      
    }
  }
}