/**
 * Copyright 2021 Google LLC
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
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "test network"
}

resource "google_compute_subnetwork" "subnetwork" {
  name                     = "subnet-smb-${var.region}"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = var.region
  project                  = var.project_id
  network                  = google_compute_network.default.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnetwork_region2" {
  name                     = "subnet-smb-${var.replica_region}"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.replica_region
  project                  = var.project_id
  network                  = google_compute_network.default.self_link
  private_ip_google_access = true
}

resource "google_compute_global_address" "private_ip_alloc" {
  project       = var.project_id
  name          = "psasmb"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  address       = "10.20.0.0"
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
  name          = "netapp-smb-psa"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  address       = "10.21.0.0"
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

## Create Active Directory
resource "google_netapp_active_directory" "smb_test_active_directory" {
  project                = var.project_id
  name                   = "smb-test-active-directory"
  location               = "us-central1"
  domain                 = "ad.internal"
  dns                    = "172.30.64.3"
  net_bios_prefix        = "smbserver"
  username               = "user"
  password               = "pass"
  aes_encryption         = false
  backup_operators       = ["test1", "test2"]
  description            = "ActiveDirectory is the public representation of the active directory config."
  encrypt_dc_connections = false
  kdc_hostname           = "hostname"
  kdc_ip                 = "10.10.0.11"
  labels = {
    "foo" : "bar"
  }
  ldap_signing        = false
  nfs_users_with_ldap = false
  organizational_unit = "CN=Computers"
  security_operators  = ["test1", "test2"]
  site                = "test-site"
}

## Create Storage Pool and 1 Volume
module "netapp_volumes" {
  source  = "GoogleCloudPlatform/netapp-volumes/google"
  version = "~> 0.3"

  project_id = var.project_id
  location   = var.region

  storage_pool = {
    create_pool   = true
    name          = "test-pool-smb"
    size          = "2048"
    service_level = "PREMIUM"
    network_name  = var.network_name
    labels = {
      pool_env = "test"
    }
    description  = "test pool for SMB"
    ldap_enabled = true
    ad_id        = google_netapp_active_directory.smb_test_active_directory.id
  }

  storage_volumes = [

    {
      name       = "test-volume-smb-1"
      share_name = "test-volume-smb-1"
      size       = "100"
      protocols  = ["SMB"]
      snapshot_policy = {
        enabled = true
        hourly_schedule = {
          snapshots_to_keep = 12
          minute            = 30
        }
        daily_schedule = {
          snapshots_to_keep = 1
          minute            = 45
          hour              = 23
        }
      }
    },

  ]

  depends_on = [
    google_service_networking_connection.vpc_connection,
    google_service_networking_connection.netapp_vpc_connection,
  ]
}
