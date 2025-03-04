terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "soft-analytics-gcp"
  region  = "europe-west3"
}

# Create a service account for invoking the Cloud Run service
resource "google_service_account" "cloud_run_invoker" {
  account_id   = "cloud-run-invoker"
  display_name = "Cloud Run Invoker Service Account"
  description  = "Service account for invoking the Cloud Run service"
}

resource "google_cloud_run_service" "default" {
  name     = "my-cloud-run-service"
  location = "europe-west3"

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# IAM policy to allow the service account to invoke the Cloud Run service
resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.cloud_run_invoker.email}"
}

# If you need to give permissions to other specific users or service accounts, add them like this:
# resource "google_cloud_run_service_iam_member" "user_invoker" {
#   location = google_cloud_run_service.default.location
#   service  = google_cloud_run_service.default.name
#   role     = "roles/run.invoker"
#   member   = "user:edoardo.vergani@soft.it"  # Replace with actual email
# }
