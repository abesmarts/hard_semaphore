variable "project_id" {}
variable "region" { default = "us-central1" }
variable "zone" { default = "us-central1-a" }
variable "machine_type" { default = "e2-standard-4" }
variable "ssh_public_key" { default = "~/.ssh/gcp_vm_key.pub" }
variable "credentials_file" { default = "~/.gcp/service-account.json" }
