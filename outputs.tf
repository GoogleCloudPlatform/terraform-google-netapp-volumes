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

output "storage_pool" {
  value       = google_netapp_storage_pool.storage_pool
  description = "Storage Pool created"
}

output "active_directory_id" {
  value       = try(google_netapp_active_directory.active_directory[0].id, null)
  description = "ID of Active Directory configuration"
}

output "backup_vault" {
  value       = google_netapp_backup_vault.backup_vault
  description = "Backup Vault created"
}

output "kms_config_service_account" {
  value       = google_netapp_kmsconfig.kms_config[0].service_account
  description = "The Service account which needs to have access to the provided KMS key"
}

output "kms_config_instructions" {
  value       = google_netapp_kmsconfig.kms_config[0].instructions
  description = "Access to the key needs to be granted. The instructions contain gcloud commands to run to grant access. To make the policy work, a CMEK policy check is required, which verifies key access"
}

output "storage_volume" {
  value       = google_netapp_volume.test_volume
  description = "Storage Volume created"
}
