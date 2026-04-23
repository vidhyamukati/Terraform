# ============================================================
# variables.tf
# ============================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the GKE cluster"
  type        = string
  default     = "us-west1"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "my-gke-cluster"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "kubernetes_version" {
  description = "Minimum Kubernetes master version"
  type        = string
  default     = "1.29"
}

variable "release_channel" {
  description = "GKE release channel: RAPID, REGULAR, STABLE"
  type        = string
  default     = "REGULAR"
}

# ---- Networking ------------------------------------------------

variable "subnet_cidr" {
  description = "Primary CIDR for the GKE subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for Pods"
  type        = string
  default     = "10.16.0.0/14"
}

variable "services_cidr" {
  description = "Secondary CIDR range for Services"
  type        = string
  default     = "10.20.0.0/20"
}

variable "master_ipv4_cidr" {
  description = "CIDR for the GKE control plane (must be /28)"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of CIDRs authorized to reach the Kubernetes API"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "All (restrict in production)"
    }
  ]
}

# ---- Node Pools ------------------------------------------------

variable "general_machine_type" {
  description = "Machine type for general-purpose nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "general_node_count" {
  description = "Initial node count per zone for general pool"
  type        = number
  default     = 1
}

variable "general_node_min" {
  description = "Minimum nodes per zone (autoscaling)"
  type        = number
  default     = 1
}

variable "general_node_max" {
  description = "Maximum nodes per zone (autoscaling)"
  type        = number
  default     = 5
}

variable "spot_machine_type" {
  description = "Machine type for spot nodes"
  type        = string
  default     = "e2-standard-4"
}

# ---- Namespaces ------------------------------------------------

variable "app_namespaces" {
  description = "Kubernetes namespaces to create"
  type        = list(string)
  default     = ["staging", "production"]
}

# ---- Labels ----------------------------------------------------

variable "common_labels" {
  description = "Common labels to apply to all GCP resources"
  type        = map(string)
  default = {
    managed-by  = "terraform"
    environment = "production"
    team        = "platform"
  }
}
