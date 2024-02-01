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
  description = "Common Labels as key value pairs for all the resources"
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
    description   = optional(string)
    labels        = optional(map(string), {})
    size          = optional(number)
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
  description = "Storage volumes details"
  # default     = {}
}

# #### Volume
# variable "volume_name" {
#   description = "The name of the volume. Needs to be unique per location"
#   type        = string
# }

# variable "volume_size" {
#   description = "Capacity of the volume (in GiB)"
#   type        = number
# }

# variable "volume_share_name" {
#   description = "Share name (SMB) or export path (NFS) of the volume. Needs to be unique per location"
#   type        = string
# }

# variable "protocols" {
#   description = "The protocol of the volume. Allowed combinations are ['NFSV3'], ['NFSV4'], ['SMB'], ['NFSV3', 'NFSV4'], ['SMB', 'NFSV3'] and ['SMB', 'NFSV4']. Each value may be one of: NFSV3, NFSV4, SMB"
#   type        = list(any)
# }

# variable "volume_labels" {
#   description = "Storage volume labels as key value pairs"
#   type        = map(any)
#   default     = {}
# }

# variable "export_policy_rules" {
#   description = "Storage volume labels as key value pairs"
#   type = map(object({
#     allowed_clients       = optional(string)
#     has_root_access       = optional(string)
#     access_type           = optional(string) #Possible values are: READ_ONLY, READ_WRITE, READ_NONE
#     nfsv3                 = optional(bool)
#     nfsv4                 = optional(bool)
#     kerberos5_read_only   = optional(bool)
#     kerberos5_read_write  = optional(bool)
#     kerberos5i_read_only  = optional(bool)
#     kerberos5i_read_write = optional(bool)
#     kerberos5p_read_only  = optional(bool)
#     kerberos5p_read_write = optional(bool)
#   }))
#   default = null
# }

# variable "volume_smb_settings" {
#   description = "Settings for volumes with SMB access. Each value may be one of: ENCRYPT_DATA, BROWSABLE, CHANGE_NOTIFY, NON_BROWSABLE, OPLOCKS, SHOW_SNAPSHOT, SHOW_PREVIOUS_VERSIONS, ACCESS_BASED_ENUMERATION, CONTINUOUSLY_AVAILABLE"
#   type        = list(string)
#   default     = null
# }

# variable "volume_unix_permissions" {
#   description = "Unix permission the mount point will be created with. Default is 0770. Applicable for UNIX security style volumes only"
#   type        = string
#   default     = null
# }

# variable "volume_description" {
#   description = "An optional description of the volume"
#   type        = string
#   default     = null
# }

# variable "volume_snapshot_directory" {
#   description = "If enabled, a NFS volume will contain a read-only .snapshot directory which provides access to each of the volume's snapshots. Will enable `Previous Versions` support for SMB"
#   type        = bool
#   default     = null
# }

# variable "volume_security_style" {
#   description = " Security Style of the Volume. Use UNIX to use UNIX or NFSV4 ACLs for file permissions. Use NTFS to use NTFS ACLs for file permissions. Can only be set for volumes which use SMB together with NFS as protocol. Possible values are: NTFS, UNIX"
#   type        = string
#   default     = null
# }

# variable "volume_kerberos_enabled" {
#   description = "Flag indicating if the volume is a kerberos volume or not, export policy rules control kerberos security modes (krb5, krb5i, krb5p)"
#   type        = bool
#   default     = null
# }

# variable "volume_restricted_actions" {
#   description = "List of actions that are restricted on this volume. Each value may be one of: DELETE"
#   type        = list(string)
#   default     = null
# }

# variable "volume_snapshot_policy" {
#   description = "Snapshot policy defines the schedule for automatic snapshot creation"
#   type = object({
#     enabled = optional(bool, false)
#     hourly_schedule = optional(object({
#       snapshots_to_keep = optional(number)
#       minute            = optional(number)
#     }), null)

#     daily_schedule = optional(object({
#       snapshots_to_keep = optional(number)
#       minute            = optional(number)
#       hour              = optional(number)
#     }), null)

#     weekly_schedule = optional(object({
#       snapshots_to_keep = optional(number)
#       minute            = optional(number)
#       hour              = optional(number)
#       day               = optional(string)
#     }), null)

#   })
#   default = { enabled = false }
# }
########################################
# variable "pool_name" {
#   description = "The resource name of the storage pool. Needs to be unique per location"
#   type        = string
# }

# variable "pool_description" {
#   description = "An optional description of this resource"
#   type        = string
#   default     = null
# }

# variable "pool_labels" {
#   description = "Storage pool labels as key value pairs"
#   type        = map(any)
#   default     = {}
# }

# variable "storage_pool_size" {
#   description = "Capacity of the storage pool (in GiB)"
#   type        = number
# }

# variable "ldap_enabled" {
#   description = "When enabled, the volumes uses Active Directory as LDAP name service for UID/GID lookups. Required to enable extended group support for NFSv3, using security identifiers for NFSv4.1 or principal names for kerberized NFSv4.1"
#   type        = bool
#   default     = false
# }

# variable "ad_name" {
#   description = "The resource name of the Active Directory pool. Needs to be unique per location"
#   type        = string
#   default     = null
# }

# variable "network_name" {
#   description = "Name of VPC Network"
#   type        = string
# }

# variable "service_level" {
#   description = "Service level of the storage pool. Possible values are: PREMIUM, EXTREME, STANDARD"
#   type        = string
# }

# variable "ad_description" {
#   description = "An optional description of this resource"
#   type        = string
#   default     = null
# }

# variable "ad_domain" {
#   description = "Fully qualified domain name for the Active Directory domain"
#   type        = string
#   default     = null
# }

# variable "ad_dns" {
#   description = "Comma separated list of DNS server IP addresses for the Active Directory domain"
#   type        = string
#   default     = null
# }

# variable "ad_net_bios_prefix" {
#   description = "NetBIOS name prefix of the server to be created"
#   type        = string
#   default     = null
# }

# variable "ad_username" {
#   description = "Username for the Active Directory account with permissions to create the compute account within the specified organizational unit"
#   type        = string
#   default     = null
# }

# variable "ad_password" {
#   description = "Password for specified username. Note - Manual changes done to the password will not be detected. Terraform will not re-apply the password, unless you use a new password in Terraform. Note: This property is sensitive and will not be displayed in the plan"
#   type        = string
#   default     = null
# }

# variable "ad_aes_encryption" {
#   description = "Enables AES-128 and AES-256 encryption for Kerberos-based communication with Active Directory"
#   type        = bool
#   default     = null
# }

# variable "ad_security_operators" {
#   description = "Domain accounts that require elevated privileges such as SeSecurityPrivilege to manage security logs. Comma-separated list"
#   type        = list(string)
#   default     = null
# }

# variable "ad_backup_operators" {
#   description = "Domain user/group accounts to be added to the Backup Operators group of the SMB service. The Backup Operators group allows members to backup and restore files regardless of whether they have read or write access to the files. Comma-separated list"
#   type        = list(string)
#   default     = null
# }

# variable "ad_kdc_hostname" {
#   description = "Hostname of the Active Directory server used as Kerberos Key Distribution Center. Only requried for volumes using kerberized NFSv4.1"
#   type        = string
#   default     = null
# }

# variable "ad_kdc_ip" {
#   description = "IP address of the Active Directory server used as Kerberos Key Distribution Center"
#   type        = string
#   default     = null
# }

# variable "ad_nfs_users_with_ldap" {
#   description = "Local UNIX users on clients without valid user information in Active Directory are blocked from access to LDAP enabled volumes. This option can be used to temporarily switch such volumes to AUTH_SYS authentication (user ID + 1-16 groups)"
#   type        = bool
#   default     = null
# }

# variable "ad_ldap_signing" {
#   description = "Specifies whether or not the LDAP traffic needs to be signed"
#   type        = bool
#   default     = null
# }

# variable "ad_encrypt_dc_connections" {
#   description = "If enabled, traffic between the SMB server to Domain Controller (DC) will be encrypted"
#   type        = bool
#   default     = null
# }

# variable "ad_organizational_unit" {
#   description = "Name of the Organizational Unit where you intend to create the computer account for NetApp Volumes. Defaults to CN=Computers if left empty"
#   type        = string
#   default     = null
# }

# variable "ad_site" {
#   description = "Domain user/group accounts to be added to the Backup Operators group of the SMB service. The Backup Operators group allows members to backup and restore files regardless of whether they have read or write access to the files. Comma-separated list"
#   type        = string
#   default     = null
# }

# variable "ad_labels" {
#   description = "Active directory labels as key value pairs"
#   type        = map(any)
#   default     = {}
# }



# variable "create_backup_vault" {
#   description = "Create backup valut or not"
#   type        = bool
#   default     = false
# }

# variable "backup_vault_name" {
#   description = "The resource name of the backup vault. Needs to be unique per location"
#   type        = string
#   default     = null
# }

# variable "backup_vault_description" {
#   description = "An optional description of this resource"
#   type        = string
#   default     = null
# }

# variable "backup_vault_labels" {
#   description = "Active directory labels as key value pairs"
#   type        = map(any)
#   default     = {}
# }

# variable "kms_config_name" {
#   description = "Name of the CMEK policy"
#   type        = string
#   default     = null
# }

# variable "kms_config_description" {
#   description = "Description for the CMEK policy"
#   type        = string
#   default     = null
# }

# variable "kms_config_crypto_key_id" {
#   description = "Resource name of the KMS key to use. Only regional keys are supported. Format: projects/{{project}}/locations/{{location}}/keyRings/{{key_ring}}/cryptoKeys/{{key}}"
#   type        = string
#   default     = null
# }

