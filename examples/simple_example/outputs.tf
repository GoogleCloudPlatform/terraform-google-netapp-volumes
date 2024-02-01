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


output "project_id" {
  value = var.project_id
}

output "location" {
  value       = var.region
  description = "Location of the resources"
}

output "storage_pool" {
  value       = module.netapp_volumes.storage_pool
  description = "Storage pool created"
}

output "storage_pool_name" {
  value       = module.netapp_volumes.storage_pool.name
  description = "Name of theStorage pool created"
}

output "storage_pool_id" {
  value       = module.netapp_volumes.storage_pool.id
  description = "Name of theStorage pool created"
}

output "storage_volumes" {
  value       = module.netapp_volumes.storage_volumes
  description = "List of created volumes"
}

output "storage_volume1_name" {
  value       = module.netapp_volumes.storage_volumes["test-volume-1"].name
  description = "storage volume 1 name"
}

output "storage_volume1_id" {
  value       = module.netapp_volumes.storage_volumes["test-volume-1"].id
  description = "storage volume 1 ID"
}

output "storage_volume2_name" {
  value       = module.netapp_volumes.storage_volumes["test-volume-2"].name
  description = "storage volume 2 name"
}

output "storage_volume2_id" {
  value       = module.netapp_volumes.storage_volumes["test-volume-2"].id
  description = "storage volume 2 ID"
}

output "storage_volumes_only" {
  value       = module.volumes_only.storage_volumes
  description = "List of created volumes"
}

output "storage_volume3_name" {
  value       = module.volumes_only.storage_volumes["test-volume-3"].name
  description = "storage volume 3 name"
}

output "storage_volume3_id" {
  value       = module.volumes_only.storage_volumes["test-volume-3"].id
  description = "storage volume 3 ID"
}
