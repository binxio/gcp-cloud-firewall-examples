# Postfix for naming
resource "random_id" "id" {
  byte_length = 1
}

# Firewall policy
resource "google_compute_network_firewall_policy" "example" {
  project = var.project_id
  name    = "example-${random_id.id.hex}"
}

resource "google_compute_network_firewall_policy_rule" "example_deny_malicious_addresses" {
  project         = var.project_id
  firewall_policy = google_compute_network_firewall_policy.example.name
  priority        = 100000

  action    = "deny"
  direction = "EGRESS"

  match {
    layer4_configs {
      ip_protocol = "all"
    }

    # NOTE: Find available threat intelligence threats in the documentation: https://cloud.google.com/firewall/docs/firewall-policies-rule-details#threat-intelligence-fw-policy
    dest_threat_intelligences = [ "iplist-known-malicious-ips" ]
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

# Enable internet access
resource "google_compute_router" "example_nat" {
  project = var.project_id
  region  = "europe-west1"
  name    = "${google_compute_network.example.name}-nat"
  network = google_compute_network.example.name
}

resource "google_compute_router_nat" "example_nat_config" {
  project                            = var.project_id
  region                             = "europe-west1"
  router                             = google_compute_router.example_nat.name
  name                               = "${google_compute_network.example.name}-nat-euw1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Enable IAP access to testing VM
resource "google_compute_firewall" "example_allow_iap_access" {
  project     = var.project_id
  network     = google_compute_network.example.id
  name        = "${google_compute_network.example.name}-iap-access"
  description = "Allow incoming access from Identity Aware Proxy subnet block 35.235.240.0/20 for SSH, RDP and WinRM"

  priority    = 4000
  direction   = "INGRESS"
  target_tags = ["allow-iap-access"]

  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22", "3389", "5986"]
  }
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

  tags = ["allow-iap-access"]

  network_interface {
    subnetwork_project = var.project_id
    subnetwork         = google_compute_subnetwork.example_clients.self_link
  }

  service_account {
    email  = google_service_account.client.email
    scopes = ["cloud-platform"]
  }
}
