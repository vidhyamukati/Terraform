# Define a Workload Identity Pool to manage external identities from Terraform Cloud
resource "google_iam_workload_identity_pool" "tfc_identity_pool" {
  workload_identity_pool_id= "terraform-pool-prod"
  display_name= "terraform-pool-prod"
  description= "Production Pool"
  disabled = false
}

# Configure the OIDC Provider to establish trust between GCP and Terraform Cloud
resource "google_iam_workload_identity_pool_provider" "pool-provider" {
  workload_identity_pool_id= google_iam_workload_identity_pool.tfc_identity_pool.workload_identity_pool_id
  workload_identity_pool_provider_id= "terraform-cloud-oidc-prod"
  display_name= "terraform-cloud-oidc-prod"
  description= "Terraform Cloud OIDC Provider"
  disabled= false
  attribute_mapping= {
    # Map TFC token claims to GCP-recognized attributes
    "attribute.tfc_organization_id"= "assertion.terraform_organization_id"
    "attribute.tfc_project_id"= "assertion.terraform_project_id"
    "attribute.tfc_project_name"= "assertion.terraform_project_name"
    "google.subject"= "assertion.terraform_workspace_id"
    "attribute.tfc_workspace_name"= "assertion.terraform_workspace_name"
    # Use CEL to extract the environment suffix from the workspace name (e.g., 'prod' from 'app-prod')
    "attribute.tfc_workspace_env"= "assertion.terraform_workspace_name.split('-')[assertion.terraform_workspace_name.split('-').size()-1]"
  }
  oidc {
       issuer_uri = "https://vstoken.dev.azure.com/350407"
  }

  # Ensure only tokens from the specific TFC organization and production workspaces are allowed
  attribute_condition = "attribute.tfc_organization_id == 'org-abcd123456' && attribute.tfc_workspace_env.startsWith('prod')"
}

# The Service Account that Terraform Cloud will impersonate to manage GCP resources
resource "google_service_account" "tfc_service_account" {
  account_id   = "tfc-service-account"
  display_name = "Terraform Cloud Service Account"
}

# Authorize the Workload Identity Pool to impersonate the Service Account
resource "google_service_account_iam_member" "tfc_service_account_member" {
  service_account_id = google_service_account.tfc_service_account.name
  role               = "roles/iam.workloadIdentityUser"

  # Restrict access to principals that belong to the specified Terraform Cloud organization
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tfc_identity_pool.name}/attribute.tfc_organization_id/YOUR_ORG_ID_HERE"
}

# Export the provider ID to be used in the TFC_GCP_WORKLOAD_PROVIDER_ID variable in Terraform Cloud
output "tfc_gcp_workload_provider_id" {
  value = google_iam_workload_identity_pool_provider.pool-provider.name
}

# Grant the Service Account permissions to manage compute resources in the project
resource "google_project_iam_member" "tfc_sa_compute_admin" {
  project = "qwiklabs-gcp-02-2e139cef6fb4"
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.tfc_service_account.email}"
}

# Create the Compute Engine instance using the Service Account
resource "google_compute_instance" "tfc_managed_instance" {
  name         = "tfc-managed-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  service_account {
    email  = google_service_account.tfc_service_account.email
    scopes = ["cloud-platform"]
  }
}
