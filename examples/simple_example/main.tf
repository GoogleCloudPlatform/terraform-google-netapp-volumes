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

resource "google_compute_network" "default" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "test network"
}

resource "google_compute_subnetwork" "subnetwork" {
  name                     = "subnet-${var.region}"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = var.region
  project                  = var.project_id
  network                  = google_compute_network.default.self_link
  private_ip_google_access = true
}

resource "google_compute_global_address" "private_ip_alloc" {
  project       = var.project_id
  name          = "psa"
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
  name          = "netapp-psa"
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

# resource "random_id" "suffix" {
#   byte_length = 4
# }

# resource "google_kms_key_ring" "keyring" {
#   name     = "netapp-key-ring-${random_id.suffix.hex}"
#   location = var.region
#   project  = var.project_id
# }

# resource "google_kms_crypto_key" "crypto_key" {
#   name     = "netapp-crypto-name"
#   key_ring = google_kms_key_ring.keyring.id
#   # rotation_period = "100000s"
# }

module "netapp_volumes" {
  source = "../.."

  project_id = var.project_id
  location   = var.region
  storege_pool = {
    create_pool   = true
    name          = "test-pool"
    size          = "2048"
    service_level = "PREMIUM"
    ldap_enabled  = false
    network_name  = var.network_name
    labels = {
      pool_env = "test"
    }
    description = "test pool"
  }
  # pool_name          = "test-pool"
  # storage_pool_size  = "2048"
  # service_level      = "PREMIUM"
  # ad_domain          = "ad.internal"
  # ad_dns             = "10.0.0.10"
  # network_name       = var.network_name
  # ad_net_bios_prefix = "smbserver"
  # ad_username        = "user"
  # ad_password        = "password"
  # ldap_enabled       = false

  # create_backup_vault      = true
  # kms_config_name          = "netapp-kms-policy"
  # kms_config_crypto_key_id = google_kms_crypto_key.crypto_key.id

  storage_volumes = [

    { name       = "test-volume-1"
      share_name = "test-volume-1"
      size       = "100"
      protocols  = ["NFSV3"]
      snapshot_policy = {
        enabled = true
        daily_schedule = {
          snapshots_to_keep = 1
          minute            = 45
          hour              = 23
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

    { name       = "test-volume-2"
      share_name = "test-volume-2"
      size       = "200"
      protocols  = ["NFSV3"]
      snapshot_policy = {
        enabled = true
        daily_schedule = {
          snapshots_to_keep = 1
          # minute            = 1
          hour = 22
        }
      }
    },

  ]

  depends_on = [
    google_service_networking_connection.vpc_connection,
    google_service_networking_connection.netapp_vpc_connection,
  ]
}

# resource "google_project_iam_custom_role" "net_app_custom_role" {
#   project     = var.project_id
#   role_id     = "cmekNetAppVolumesRole${random_id.suffix.hex}"
#   title       = "cmekNetAppVolumesRole-${random_id.suffix.hex}"
#   description = "custom cmek cvs role"
#   permissions = [
#     "cloudkms.cryptoKeyVersions.get",
#     "cloudkms.cryptoKeyVersions.list",
#     "cloudkms.cryptoKeyVersions.useToDecrypt",
#     "cloudkms.cryptoKeyVersions.useToEncrypt",
#     "cloudkms.cryptoKeys.get",
#     "cloudkms.keyRings.get",
#     "cloudkms.locations.get",
#     "cloudkms.locations.list",
#   ]
# }

# resource "google_kms_crypto_key_iam_member" "crypto_key" {
#   crypto_key_id = google_kms_crypto_key.crypto_key.id
#   role          = google_project_iam_custom_role.net_app_custom_role.id
#   member        = "serviceAccount:${module.netapp_volumes.kms_config_service_account}"
# }
