/**
 * Copyright 2024 Taito United
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

resource "google_compute_instance" "vm" {
  for_each            = {for item in local.virtualMachines: item.name => item}

  name                = each.value.name
  machine_type        = each.value.machineType
  zone                = each.value.zone
  deletion_protection = each.value.deletionProtection

  network_interface {
    network = var.network
    subnetwork = each.value.subnetwork

    access_config {
      network_tier = "PREMIUM"
    }
  }

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.diskSizeGb
    }
  }

  dynamic "guest_accelerator" {
    for_each = each.value.gpuCount > 0 ? [1] : []
    content {
      count = each.value.gpuCount
      type = each.value.gpuType
    }
  }

  dynamic "scheduling" {
    for_each = each.value.gpuCount > 0 ? [1] : []
    content {
      on_host_maintenance = "TERMINATE"
    }
  }

}
