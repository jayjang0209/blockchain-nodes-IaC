variable "credentials_file" {
  description = "Path to the GCP credentials JSON file"
  type        = string
}

variable "project_id" {
  description = "GCP project ID to use for resources (must exist)"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for the VM instance"
  type        = string
  default     = "us-central1-a"
}

variable "node_count" {
  description = "Number of Coreum full node instances to create"
  type        = number
  default     = 1
}

variable "instance_name_prefix" {
  description = "Name prefix for Coreum instances and resources"
  type        = string
  default     = "coreum-node"
}

variable "machine_type" {
  description = "Machine type for the VM (ensure 4+ vCPU, 16GB+ RAM)"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB (SSD recommended, e.g. 500GB+ for mainnet)"
  type        = number
  default     = 500
}

variable "disk_type" {
  description = "Disk type (pd-ssd for SSD persistent disk, or pd-balanced, etc.)"
  type        = string
  default     = "pd-ssd"
}

variable "boot_image" {
  description = "Source image for the VM (family or specific image of OS)"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "network_name" {
  description = "VPC network name to use for the instance"
  type        = string
  default     = "default"
}

variable "subnetwork_name" {
  description = "Subnetwork name (if applicable; leave default for auto or if using default network)"
  type        = string
  default     = null
}

variable "ssh_username" {
  description = "Username for SSH access (will be created with provided public key)"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_keys" {
  description = "Map of username to public key path"
  type        = map(string)
  default     = {
    "ubuntu" = "~/.ssh/id_rsa.pub"
  }
}

variable "ssh_allowed_ips" {
  description = "List of IP addresses allowed to connect via SSH (CIDR notation)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Default to allow all (not recommended for production)
}