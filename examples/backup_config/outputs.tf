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


output "project_id" {
  value       = var.project_id
  description = "Project ID"
}

output "location" {
  value       = google_compute_subnetwork.subnetwork.region
  description = "Location of the resources"
}

output "storage_pool" {
  value       = module.netapp_volumes.storage_pool
  description = "Storage pool created"
}

output "storage_volumes" {
  value       = module.netapp_volumes.storage_volumes
  description = "List of created volumes"
}

output "backup_policy_id" {
  value       = google_netapp_backup_policy.backup_policy.id
  description = "Backup policy created"
}

output "backup_vault_id" {
  value       = google_netapp_backup_vault.backup_vault.id
  description = "Backup vault created"
}
