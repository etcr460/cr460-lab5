resource "google_compute_instance" "Jumphost" {
  name         = "jumphost"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  tags = ["tag-reseau-public"]

  disk {
    image = "debian-cloud/debian-8"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.Public.name}"
    access_config {
      // Ephemeral IP
    }
  }
}


resource "google_compute_instance" "Vault" {
  name         = "vault"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  tags = ["tag-reseau-public"]

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.Public.name}"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "Master" {
  name         = "master"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  tags = ["tag-reseau-workload"]

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.Workload.name}"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "etcd1" {
  name         = "etcd1"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  tags = ["tag-reseau-backend"]

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.Backend.name}"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "etcd2" {
  name         = "etcd2"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  tags = ["tag-reseau-backend"]

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.Backend.name}"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "etcd3" {
  name         = "etcd3"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  tags = ["tag-reseau-backend"]

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.Backend.name}"
    access_config {
      // Ephemeral IP
    }
  }
}


resource "google_compute_instance_template" "Workers-instance-template" {
  name           = "workers-instance-template"
  machine_type   = "f1-micro"
  can_ip_forward = false

  tags = ["tag-reseau-workload"]

  disk {
    source_image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.Workload.name}"
  }
}

resource "google_compute_target_pool" "Workers-target-pool" {
  name = "workers-target-pool"
}

resource "google_compute_instance_group_manager" "Workers-igm" {
  name = "workers-igm"
  zone = "us-east1-b"

  instance_template  = "${google_compute_instance_template.Workers-instance-template.self_link}"
  target_pools       = ["${google_compute_target_pool.Workers-target-pool.self_link}"]
  base_instance_name = "worker"
}

resource "google_compute_autoscaler" "Workers-autoscaler" {
  name   = "workers-autoscaler"
  zone   = "us-east1-b"
  target = "${google_compute_instance_group_manager.Workers-igm.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
