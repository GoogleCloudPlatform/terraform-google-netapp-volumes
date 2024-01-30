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
  volume_labels           = merge(var.common_labels, var.volume_labels)
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


resource "google_netapp_volume" "test_volume" {
  project            = var.project_id
  location           = var.location
  name               = var.volume_name
  capacity_gib       = var.volume_size
  share_name         = var.volume_share_name
  storage_pool       = google_netapp_storage_pool.storage_pool.name
  protocols          = var.protocols
  labels             = local.volume_labels
  smb_settings       = var.volume_smb_settings
  unix_permissions   = var.volume_unix_permissions
  description        = var.volume_description
  snapshot_directory = var.volume_snapshot_directory
  security_style     = var.volume_security_style
  kerberos_enabled   = var.volume_kerberos_enabled
  restricted_actions = var.volume_restricted_actions

  dynamic "snapshot_policy" {
    for_each = var.volume_snapshot_policy.enabled ? ["volume_snapshot_policy"] : []
    content {
      enabled = var.volume_snapshot_policy.enabled
      dynamic "hourly_schedule" {
        for_each = var.volume_snapshot_policy.hourly_schedule == null ? [] : ["hourly_schedule"]
        content {
          snapshots_to_keep = lookup(var.volume_snapshot_policy.hourly_schedule, "snapshots_to_keep")
          minute            = lookup(var.volume_snapshot_policy.hourly_schedule, "minute")
        }
      }

      dynamic "daily_schedule" {
        for_each = var.volume_snapshot_policy.daily_schedule == null ? [] : ["daily_schedule"]
        content {
          snapshots_to_keep = lookup(var.volume_snapshot_policy.daily_schedule, "snapshots_to_keep")
          minute            = lookup(var.volume_snapshot_policy.daily_schedule, "minute")
          hour              = lookup(var.volume_snapshot_policy.daily_schedule, "hour")
        }
      }

      dynamic "weekly_schedule" {
        for_each = var.volume_snapshot_policy.weekly_schedule == null ? [] : ["weekly_schedule"]
        content {
          snapshots_to_keep = lookup(var.volume_snapshot_policy.weekly_schedule, "snapshots_to_keep")
          minute            = lookup(var.volume_snapshot_policy.weekly_schedule, "minute")
          hour              = lookup(var.volume_snapshot_policy.weekly_schedule, "hour")
          day               = lookup(var.volume_snapshot_policy.weekly_schedule, "day")
        }
      }

    }
  }

  dynamic "export_policy" {
    for_each = var.export_policy_rules == null ? [] : ["export_policy_rules"]
    content {
      dynamic "rules" {
        for_each = var.export_policy_rules == null ? {} : var.export_policy_rules
        content {
          allowed_clients       = lookup(rules.value, "allowed_clients")
          has_root_access       = lookup(rules.value, "has_root_access")
          access_type           = lookup(rules.value, "access_type")
          nfsv3                 = lookup(rules.value, "nfsv3")
          nfsv4                 = lookup(rules.value, "nfsv4")
          kerberos5_read_only   = lookup(rules.value, "kerberos5_read_only")
          kerberos5_read_write  = lookup(rules.value, "kerberos5_read_write")
          kerberos5i_read_only  = lookup(rules.value, "kerberos5i_read_only")
          kerberos5i_read_write = lookup(rules.value, "kerberos5i_read_write")
          kerberos5p_read_only  = lookup(rules.value, "kerberos5p_read_only")
          kerberos5p_read_write = lookup(rules.value, "kerberos5p_read_write")
        }
      }
    }
  }
}





## Backup policies define a schedule for automated backup creation. You can define how many daily, weekly, and monthly backups of your data you want NetApp Volumes to retain. If a policy is attached to a volume, then backups will generate automatically.
## You can't control the exact time a scheduled backup is created. Scheduled backups that use a backup policy retain the number of specified daily, weekly, and monthly backups. 
# resource "google_netapp_backup_policy" "test_backup_policy_full" {
#   name          = "test-backup-policy-full"
#   location = "us-central1"
#   daily_backup_limit   = 2
#   weekly_backup_limit  = 1
#   monthly_backup_limit = 1
#   description = "TF test backup schedule"
#   enabled = true
#   labels = {
#     "foo" = "bar"
#   }
# }


### Active Directory policies are region-specific, with the ability to configure only one policy per region.
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

##You can only create one backup vault per region. A vault can hold multiple backups for multiple volumes in that region
resource "google_netapp_backup_vault" "backup_vault" {
  count       = var.create_backup_vault ? 1 : 0
  project     = var.project_id
  name        = local.backup_vault_name
  location    = var.location
  description = var.backup_vault_description
  labels      = local.backup_vault_labels
}


## The use of CMEK is optional. If used, CMEK policies are region-specific. You can only configure one policy per region.
resource "google_netapp_kmsconfig" "kms_config" {
  provider        = google-beta
  count           = var.kms_config_name == null ? 0 : 1
  project         = var.project_id
  name            = var.kms_config_name
  description     = var.kms_config_description
  crypto_key_name = var.kms_config_crypto_key_id
  location        = var.location
}
