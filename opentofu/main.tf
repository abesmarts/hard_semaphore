terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}


provider "google" {
  credentials = file("${path.module}/dummy-gcp-service-account.json") # dummy placeholder
  project     = "d3vwrx-aac"            
  region      = "us-central1"
  zone        = "us-central1-c"
}


resource "google_compute_instance" "ubuntu_vm" {
  name         = "semaphore-ubuntu"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20250805" # Ubuntu 22.04 LTS
      size  = 20
    }
  }

  network_interface {
    network       = "default"
    access_config {} 
  }

  # Optional metadata startup script for initial setup
  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip git curl
    mkdir -p /var/log/vm_state /var/log/bot_data /var/log/ansible /var/log/opentofu
  EOT

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


resource "local_file" "ansible_inventory" {
  filename = "..ansible/hosts.ini"
  content  = <<EOT
[ubuntu_vms]
${google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
EOT
}


resource "null_resource" "copy_scripts" {
  depends_on = [google_compute_instance.ubuntu_vm]

  provisioner "file" {
    source      = "${path.module}/python-scripts"
    destination = "/home/ubuntu/python-scripts"

    connection {
      type        = "ssh"
      host        = google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/python-scripts/*.py"
    ]

    connection {
      type        = "ssh"
      host        = google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}


output "ubuntu_vm_ip" {
  value       = google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip
  description = "Public IP of the Ubuntu VM"
}
 