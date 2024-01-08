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

locals {
  active_directory_name   = var.ldap_enabled ? (var.ad_name != null ? var.ad_name : "${var.pool_name}-${var.location}-ad-config") : null
  backup_vault_name       = var.backup_vault_name != null ? var.backup_vault_name : "${var.pool_name}-${var.location}-vault-backup"
  backup_vault_labels     = merge(var.common_labels, var.backup_vault_labels)
  pool_labels             = merge(var.common_labels, var.pool_labels)
  active_directory_labels = merge(var.common_labels, var.ad_labels)
}

data "google_compute_network" "vpc_network" {
  name    = var.network_name
  project = var.project_id
}

resource "google_netapp_storage_pool" "storage_pool" {
  project          = var.project_id
  name             = var.pool_name
  location         = var.location
  service_level    = var.service_level
  capacity_gib     = var.storage_pool_size
  network          = data.google_compute_network.vpc_network.id
  description      = var.pool_description
  labels           = local.pool_labels
  ldap_enabled     = var.ldap_enabled
  active_directory = try(google_netapp_active_directory.active_directory[0].id, null)
}


resource "google_netapp_active_directory" "active_directory" {
  count                  = var.ldap_enabled ? 1 : 0
  project                = var.project_id
  name                   = local.active_directory_name
  location               = var.location
  domain                 = var.ad_domain
  dns                    = var.ad_dns
  net_bios_prefix        = var.ad_net_bios_prefix
  username               = var.ad_username
  password               = var.ad_password
  aes_encryption         = var.ad_aes_encryption
  backup_operators       = var.ad_backup_operators
  description            = var.ad_description
  encrypt_dc_connections = var.ad_encrypt_dc_connections
  kdc_hostname           = var.ad_kdc_hostname
  kdc_ip                 = var.ad_kdc_ip
  labels                 = local.active_directory_labels
  ldap_signing           = var.ad_ldap_signing
  nfs_users_with_ldap    = var.ad_nfs_users_with_ldap
  organizational_unit    = var.ad_organizational_unit
  security_operators     = var.ad_security_operators
  site                   = var.ad_site
}

resource "google_netapp_backup_vault" "backup_vault" {
  project     = var.project_id
  name        = local.backup_vault_name
  location    = var.location
  description = var.backup_vault_description
  labels      = local.backup_vault_labels
}
