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

## Example for creating Storage Pool and Volumes

module "netapp_volumes" {
  source = "googlestaging/netapp-volumes/google"

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

  storage_volumes = [

    {
      name       = "test-volume-1"
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

    {
      name       = "test-volume-2"
      share_name = "test-volume-2"
      size       = "200"
      protocols  = ["NFSV3"]
      snapshot_policy = {
        enabled = true
        daily_schedule = {
          snapshots_to_keep = 1
          hour              = 22
        }
      }
    },

  ]

  depends_on = [
    google_service_networking_connection.vpc_connection,
    google_service_networking_connection.netapp_vpc_connection,
  ]
}

## Example for creating volume only by providing an existing storage pool

module "volumes_only" {
  source = "googlestaging/netapp-volumes/google"

  project_id = module.netapp_volumes.storage_pool.project
  location   = module.netapp_volumes.storage_pool.location
  storege_pool = {
    create_pool = false
    name        = module.netapp_volumes.storage_pool.name
  }

  storage_volumes = [

    {
      name       = "test-volume-3"
      share_name = "test-volume-3"
      size       = "100"
      protocols  = ["NFSV3"]
      snapshot_policy = {
        enabled = true
        daily_schedule = {
          snapshots_to_keep = 1
          minute            = 21
          hour              = 21
        }
        weekly_schedule = {
          snapshots_to_keep = 1
          minute            = 1
          hour              = 1
          day               = "Monday"
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
  ]

  depends_on = [
    module.netapp_volumes,
  ]
}
