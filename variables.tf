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

variable "project_id" {
  description = "The ID of the project in which the resource belongs"
  type        = string
}

variable "location" {
  description = "Name of the location. Usually a region name, expect for some STANDARD service level pools which require a zone name"
  type        = string
}

variable "common_labels" {
  description = "Common Labels as key value pairs. Applies to all the resources. If labels are provided in storege_pool or storage_volumes then they are merged with common labels before being applied to the resources"
  type        = map(any)
  default     = {}
}


variable "storege_pool" {
  description = "Storage pool details"
  type = object({
    create_pool   = optional(bool, false)
    name          = string
    network_name  = optional(string)
    service_level = optional(string)
    size          = optional(number)
    description   = optional(string)
    labels        = optional(map(string), {})
    ldap_enabled  = optional(bool, false)
    ad_id         = optional(string)
  })
}

variable "storage_volumes" {
  type = list(object({
    name               = string
    size               = number
    share_name         = string
    protocols          = list(string)
    labels             = optional(map(string), {})
    smb_settings       = optional(list(string))
    unix_permissions   = optional(string)
    description        = optional(string)
    snapshot_directory = optional(bool)
    security_style     = optional(string)
    kerberos_enabled   = optional(bool)
    restricted_actions = optional(list(string))

    export_policy_rules = optional(map(object({
      allowed_clients       = optional(string)
      has_root_access       = optional(string)
      access_type           = optional(string) #Possible values are: READ_ONLY, READ_WRITE, READ_NONE
      nfsv3                 = optional(bool)
      nfsv4                 = optional(bool)
      kerberos5_read_only   = optional(bool)
      kerberos5_read_write  = optional(bool)
      kerberos5i_read_only  = optional(bool)
      kerberos5i_read_write = optional(bool)
      kerberos5p_read_only  = optional(bool)
      kerberos5p_read_write = optional(bool)
    })))

    snapshot_policy = optional(object({
      enabled = optional(bool, false)
      hourly_schedule = optional(object({
        snapshots_to_keep = optional(number)
        minute            = optional(number)
      }), null)

      daily_schedule = optional(object({
        snapshots_to_keep = optional(number)
        minute            = optional(number)
        hour              = optional(number)
      }), null)

      weekly_schedule = optional(object({
        snapshots_to_keep = optional(number)
        minute            = optional(number)
        hour              = optional(number)
        day               = optional(string)
      }), null)
    }))

  }))
  description = "List of Storage Volumes"
}
