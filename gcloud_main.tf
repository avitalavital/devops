provider "google" {
  credentials = file(/home/avital/.ssh/protean-quanta-393311-f25840d522fc.json)
  project     = "protean-quanta-393311"
  region      = "us-east1"
}

terraform {
  backend "gcs" {
    bucket = "terra_buck"
    prefix = "terraform/state"
  }
}

resource "google_container_cluster" "gke_cluster" {
  name               = "terra_clus"
  location           = "us-east1-b"
  initial_node_count = 1

node_config {
    machine_type = "n1-standard-1"
    disk_size_gb = 50
    disk_type    = "pd-balanced"
  }
}

output "cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate
  sensitive = true
}

resource "google_compute_firewall" "allow_inbound" {
  name    = "allow-inbound"
  network = "default"
  # Inbound traffic rules
  allow {
    protocol = "tcp"
    ports    = ["22", "5000", "80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_outbound" {
  name    = "allow-outbound"
  network = "default"
  # Outbound traffic rules
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  source_ranges = ["0.0.0.0/0"]
}
avital@my-ubuntu:~/gcloud_t
