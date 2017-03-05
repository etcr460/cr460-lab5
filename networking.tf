resource "google_compute_network" "Network" {
	name			= "cr460"
	auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "Public" {
        name                    = "public"
	ip_cidr_range		= "172.16.1.0/24"
	network			= "${google_compute_network.Network.self_link}"
	region			= "us-east1"
}

resource "google_compute_subnetwork" "Workload" {
        name                    = "workload"
        ip_cidr_range           = "172.18.1.0/24"
        network			= "${google_compute_network.Network.self_link}"
        region                  = "us-east1"
}

resource "google_compute_subnetwork" "Backend" {
        name                    = "backend"
        ip_cidr_range           = "172.20.1.0/24"
        network              	= "${google_compute_network.Network.self_link}"
        region                  = "us-east1"
}

resource "google_compute_firewall" "fw-ext-network" {
  name    = "fw-ext-network"
  network = "${google_compute_network.Network.name}"
  
  allow {
    protocol = "tcp"
    ports    = ["80", "22", "443"]
  }

//  source_tags = ["patate"]
  target_tags = ["tag-reseau-public"]
}

resource "google_compute_firewall" "fw-public-workload" {
  name    = "fw-public-workload"
  network = "${google_compute_network.Network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["tag-reseau-public"]
  target_tags = ["tag-reseau-workload"]
}

resource "google_compute_firewall" "fw-public-backend" {
  name    = "fw-public-backend"
  network = "${google_compute_network.Network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22", "2379", "2380"]
  }

  source_tags = ["tag-reseau-public"]
  target_tags = ["tag-reseau-backend"]
}

resource "google_compute_firewall" "fw-workload-backend" {
  name    = "fw-workload-backend"
  network = "${google_compute_network.Network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22", "2379", "2380"]
  }

  source_tags = ["tag-reseau-workload"]
  target_tags = ["tag-reseau-backend"]
}




resource "google_dns_record_set" "jump" {
  name = "jump.etcr460.cr460lab.com."
  type = "A"
  ttl  = 300

  managed_zone = "etcr460"

  rrdatas = ["${google_compute_instance.Jumphost.network_interface.0.access_config.0.assigned_nat_ip}"]
}



resource "google_dns_record_set" "vault" {
  name = "vault.etcr460.cr460lab.com."
  type = "A"
  ttl  = 300

  managed_zone = "etcr460"

  rrdatas = ["${google_compute_instance.Vault.network_interface.0.access_config.0.assigned_nat_ip}"]
}

