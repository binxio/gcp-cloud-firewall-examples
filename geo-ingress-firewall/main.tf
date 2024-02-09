# Postfix for naming
resource "random_id" "id" {
  byte_length = 1
}

# Firewall policy
resource "google_compute_network_firewall_policy" "example" {
  project = var.project_id
  name    = "example-${random_id.id.hex}"
}

resource "google_compute_network_firewall_policy_rule" "example_allow_nl_ssh_ingress" {
  project         = var.project_id
  firewall_policy = google_compute_network_firewall_policy.example.name
  priority        = 100000

  action    = "allow"
  direction = "INGRESS"

  match {
    layer4_configs {
      ip_protocol = "tcp"
      ports = [ "22" ]
    }

    src_region_codes = [ "NL" ]
  }
}

resource "google_compute_network_firewall_policy_association" "example_example" {
  project = var.project_id
  name    = "example-${random_id.id.hex}-example-${random_id.id.hex}"

  firewall_policy   = google_compute_network_firewall_policy.example.name
  attachment_target = google_compute_network.example.id
}

# VPC to associate
resource "google_compute_network" "example" {
  project = var.project_id
  name    = "example-${random_id.id.hex}"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "example_clients" {
  project       = var.project_id
  network       = google_compute_network.example.id
  name          = "${google_compute_network.example.name}-clients"
  region        = "europe-west1"
  ip_cidr_range = "10.0.0.0/24"

  private_ip_google_access = true
}

# Client VM to use for testing
resource "google_service_account" "client" {
  project    = var.project_id
  account_id = "client-${random_id.id.hex}"
}

resource "google_project_iam_member" "client_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.client.email}"
}

resource "google_project_iam_member" "client_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.client.email}"
}

resource "google_compute_instance" "client" {
  project = var.project_id
  zone    = "europe-west1-b"
  name    = "client"

  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      size  = 20
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork_project = var.project_id
    subnetwork         = google_compute_subnetwork.example_clients.self_link

    access_config {
    }
  }

  service_account {
    email  = google_service_account.client.email
    scopes = ["cloud-platform"]
  }
}
