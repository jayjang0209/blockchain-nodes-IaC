terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.54.0"  # Ensure compatibility
    }
  }
}

provider "google" {
  credentials = file(pathexpand(var.credentials_file))
  project     = var.project_id
  region      = var.region
}

# Reserve static IPs for Coreum Nodes
resource "google_compute_address" "coreum_addrs" {
  count   = var.node_count
  name    = "${var.instance_name_prefix}-${count.index + 1}-ip"
  project = var.project_id
  region  = var.region
}

# Firewall rule for Coreum network ports (P2P, RPC, gRPC, REST)
resource "google_compute_firewall" "coreum_allow" {
  name      = "${var.instance_name_prefix}-allow-ports"
  project   = var.project_id
  network   = var.network_name
  direction = "INGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["26656", "26657", "9090", "9091", "1317"]
  }

  target_tags   = ["coreum-node"]
  source_ranges = ["0.0.0.0/0"]
  description   = "Allow Coreum network traffic (P2P, RPC, gRPC, REST)"
}

# Separate firewall rule for SSH access (restrict source IP as needed)
resource "google_compute_firewall" "coreum_ssh" {
  name      = "${var.instance_name_prefix}-allow-ssh"
  project   = var.project_id
  network   = var.network_name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["coreum-node"]
  source_ranges = var.ssh_allowed_ips
  description   = "Allow SSH access to Coreum nodes"
}

# Create Coreum Node Instances
resource "google_compute_instance" "coreum_nodes" {
  count        = var.node_count
  name         = "${var.instance_name_prefix}-${count.index + 1}"
  project      = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  tags         = ["coreum-node"]

  # Boot Disk Configuration
  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.disk_size_gb
      type  = var.disk_type
    }
    auto_delete = true
  }

  # Attach Reserved Static IP
  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork_name
    access_config {
      nat_ip = google_compute_address.coreum_addrs[count.index].address
    }
  }

  # Inject SSH Keys
  metadata = {
    ssh-keys = join("\n", [for username, key_path in var.ssh_public_keys : 
      "${username}:${file(pathexpand(key_path))}"
    ])
  }
}