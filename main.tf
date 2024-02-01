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

data "google_compute_network" "vpc_network" {
  count   = var.storege_pool.create_pool ? 1 : 0
  name    = var.storege_pool.network_name
  project = var.project_id
}

resource "google_netapp_storage_pool" "storage_pool" {
  count            = var.storege_pool.create_pool ? 1 : 0
  project          = var.project_id
  location         = var.location
  name             = var.storege_pool.name
  service_level    = var.storege_pool.service_level
  capacity_gib     = var.storege_pool.size
  network          = data.google_compute_network.vpc_network[0].id
  description      = lookup(var.storege_pool, "description", null)
  labels           = merge(var.common_labels, var.storege_pool.labels)
  ldap_enabled     = var.storege_pool.ldap_enabled
  active_directory = lookup(var.storege_pool, "ad_id", null)
}


resource "google_netapp_volume" "storage_volumes" {
  for_each           = { for x in var.storage_volumes : x.name => x }
  project            = var.project_id
  location           = var.location
  name               = each.key
  capacity_gib       = each.value.size
  share_name         = each.value.share_name
  storage_pool       = var.storege_pool.create_pool ? google_netapp_storage_pool.storage_pool[0].name : var.storege_pool.name
  protocols          = each.value.protocols
  labels             = merge(var.common_labels, each.value.labels)
  smb_settings       = lookup(each.value, "smb_settings", null)
  unix_permissions   = lookup(each.value, "unix_permissions", null)
  description        = lookup(each.value, "description", null)
  snapshot_directory = lookup(each.value, "snapshot_directory", null)
  security_style     = lookup(each.value, "security_style", null)
  kerberos_enabled   = lookup(each.value, "kerberos_enabled", null)
  restricted_actions = lookup(each.value, "restricted_actions", null)

  dynamic "snapshot_policy" {
    for_each = each.value.snapshot_policy.enabled ? ["volume_snapshot_policy"] : []
    content {
      enabled = each.value.snapshot_policy.enabled
      dynamic "hourly_schedule" {
        for_each = each.value.snapshot_policy.hourly_schedule == null ? [] : ["hourly_schedule"]
        content {
          snapshots_to_keep = lookup(each.value.snapshot_policy.hourly_schedule, "snapshots_to_keep")
          minute            = lookup(each.value.snapshot_policy.hourly_schedule, "minute")
        }
      }

      dynamic "daily_schedule" {
        for_each = each.value.snapshot_policy.daily_schedule == null ? [] : ["daily_schedule"]
        content {
          snapshots_to_keep = lookup(each.value.snapshot_policy.daily_schedule, "snapshots_to_keep")
          minute            = lookup(each.value.snapshot_policy.daily_schedule, "minute")
          hour              = lookup(each.value.snapshot_policy.daily_schedule, "hour")
        }
      }

      dynamic "weekly_schedule" {
        for_each = each.value.snapshot_policy.weekly_schedule == null ? [] : ["weekly_schedule"]
        content {
          snapshots_to_keep = lookup(each.value.snapshot_policy.weekly_schedule, "snapshots_to_keep")
          minute            = lookup(each.value.snapshot_policy.weekly_schedule, "minute")
          hour              = lookup(each.value.snapshot_policy.weekly_schedule, "hour")
          day               = lookup(each.value.snapshot_policy.weekly_schedule, "day")
        }
      }

    }
  }

  dynamic "export_policy" {
    for_each = each.value.export_policy_rules == null ? [] : ["export_policy_rules"]
    content {
      dynamic "rules" {
        for_each = each.value.export_policy_rules == null ? {} : each.value.export_policy_rules
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
