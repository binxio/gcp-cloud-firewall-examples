# GCP Cloud Firewall examples

Google [Cloud Firewall](https://cloud.google.com/security/products/firewall) is a powerful with "operational simplicity". As the documentation does not provide much examples, we've collected some samples for you.

## FQDN firewall

Do you want to allow or deny egress to certain domain names?

```hcl
resource "google_compute_network_firewall_policy_rule" "allow_xebia" {
  project         = var.project_id
  firewall_policy = google_compute_network_firewall_policy.example.name
  priority        = 10000

  action    = "allow"
  direction = "EGRESS"

  match {
    layer4_configs {
      ip_protocol = "tcp"
    }

    dest_fqdns = ["xebia.com"]
  }
}
```

Example reference: [fqdn-egress-firewall](./fqdn-egress-firewall/)
Limitations reference: [FQDN objects limitations](https://cloud.google.com/firewall/docs/firewall-policies-rule-details#limitations)


## Known malicious addresses firewall

Do you want to deny ingress from/egress to malicious addresses?

```hcl
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
```

Example reference: [malicious-addresses-firewall](./malicious-addresses-firewall/)

## Geolocation firewall

Do you want to allow or deny ingress traffic from certain regions?

```hcl
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
```

Example reference: [geo-ingress-firewall](./geo-ingress-firewall/)