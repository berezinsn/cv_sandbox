terraform               {
  required_version           = "0.11.14"
  backend "gcs"         {
    bucket                   = "consul-vault-infra"
    prefix                   = "terraform/state"
  }
}

provider "google"       {
  version                   = "1.19.1"
  credentials               = "${file("../auth/account.json")}"
  project                   = "${var.GP}"
  region                    = "${var.REG}"
}

resource "google_compute_disk" "consul-persistent-drive" {
  name                      = "consul-disk"
  zone                      = "${var.ZONE}"
  image                     = "centos-7-v20190916"
  size                      = 15
}

resource "google_compute_attached_disk" "consul-persistent-drive" {
  disk                      = "${google_compute_disk.consul-persistent-drive.self_link}"
  instance                  = "${google_compute_instance.consul-instance.self_link}"
  mode                      = "READ_WRITE"
}

resource "google_compute_instance" "consul-instance" {
  name                      = "consul"
  machine_type              = "f1-micro"
  zone                      = "${var.ZONE}"
  boot_disk {
    initialize_params {
      image                 = "${var.CONSUL_IMG}"
    }
  }
  network_interface {
    network                 = "default"
    access_config {
      // Ephemeral IP
      network_tier          = "STANDARD"
    }
  }
}

resource "google_compute_disk" "vault-persistent-drive" {
  name                      = "vault-disk"
  zone                      = "${var.ZONE}"
  image                     = "centos-7-v20190916"
  size                      = 15
}

resource "google_compute_attached_disk" "vault-persistent-drive" {
  disk                      = "${google_compute_disk.vault-persistent-drive.self_link}"
  instance                  = "${google_compute_instance.vault-instance.self_link}"
  mode                      = "READ_WRITE"
}

resource "google_compute_instance" "vault-instance" {
  name                      = "vault"
  machine_type              = "f1-micro"
  zone                      = "${var.ZONE}"

  boot_disk {
    initialize_params {
      image                 = "${var.VAULT_IMG}"
    }
  }
  network_interface {
    network                 = "default"
    access_config {
      // Ephemeral IP
      network_tier          = "STANDARD"
    }
  }
}