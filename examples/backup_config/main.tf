/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Create Network with a subnetwork and private service access for both netapp.servicenetworking.goog and servicenetworking.googleapis.com

resource "google_compute_network" "default" {
  name                    = "backup-netapp"
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "test network"
}

resource "google_compute_subnetwork" "subnetwork" {
  name                     = "subnet-us-central1"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = "us-central1"
  project                  = var.project_id
  network                  = google_compute_network.default.self_link
  private_ip_google_access = true
}

resource "google_compute_global_address" "private_ip_alloc" {
  project       = var.project_id
  name          = "psa-backup"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  address       = "10.10.0.0"
  prefix_length = 16
  network       = google_compute_network.default.id
}

resource "google_service_networking_connection" "vpc_connection" {
  network = google_compute_network.default.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_alloc.name,
  ]
  deletion_policy = "ABANDON"
}

resource "google_compute_global_address" "netapp_private_svc_ip" {
  project       = var.project_id
  name          = "netapp-psa-backup"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  address       = "10.11.0.0"
  prefix_length = 16
  network       = google_compute_network.default.id
}

resource "google_service_networking_connection" "netapp_vpc_connection" {
  network = google_compute_network.default.id
  service = "netapp.servicenetworking.goog"
  reserved_peering_ranges = [
    google_compute_global_address.netapp_private_svc_ip.name,
  ]
  depends_on = [
    google_service_networking_connection.vpc_connection
  ]
  deletion_policy = "ABANDON"
}

## Create backup policy

resource "google_netapp_backup_policy" "backup_policy" {
  project              = var.project_id
  name                 = "netapp-backup-policy"
  location             = "us-central1"
  daily_backup_limit   = 2
  weekly_backup_limit  = 0
  monthly_backup_limit = 0
  enabled              = true
  description          = "TF test backup schedule"
  labels = {
    "env" = "test"
  }
}

## Create Storage Vault

resource "google_netapp_backup_vault" "backup_vault" {
  project  = var.project_id
  location = "us-central1"
  name     = "tf-test-vault"
}

## Create Storage Pool with 2 Volumes

module "netapp_volumes" {
  source  = "GoogleCloudPlatform/netapp-volumes/google"
  version = "~> 1.0"

  project_id = var.project_id
  location   = "us-central1"

  storage_pool = {
    create_pool   = true
    name          = "test-pool"
    size          = "2048"
    service_level = "PREMIUM"
    ldap_enabled  = false
    network_name  = "backup-netapp"
    labels = {
      pool_env = "test"
    }
    description = "test pool"
  }

  storage_volumes = [
    # test-volume-1
    {
      name            = "test-volume-1"
      share_name      = "test-volume-1"
      size            = "100"
      protocols       = ["NFSV3"]
      deletion_policy = "FORCE"
      backup_policies = [google_netapp_backup_policy.backup_policy.id]
      backup_vault    = google_netapp_backup_vault.backup_vault.id
      snapshot_policy = {
        enabled = true
        monthly_schedule = {
          snapshots_to_keep = 12
          minute            = 30
          hour              = 23
          days_of_month     = "10"
        }
        daily_schedule = {
          snapshots_to_keep = 1
          minute            = 45
          hour              = 5
        }
      }
      export_policy_rules = {
        test = {
          allowed_clients = "10.0.0.0/24,10.100.0.0/24"
          access_type     = "READ_WRITE"
          nfsv3           = true
          has_root_access = true
        }
      }
    },
    # test-volume-2
    {
      name            = "test-volume-2"
      share_name      = "test-volume-2"
      size            = "200"
      protocols       = ["NFSV3"]
      deletion_policy = "FORCE"
    },
  ]

  depends_on = [
    google_service_networking_connection.vpc_connection,
    google_service_networking_connection.netapp_vpc_connection,
  ]
}
