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

resource "google_compute_address" "static" {
  for_each            = {for item in local.virtualMachinesWithExternalIp: item.name => item}

  name                = each.value.name
  region              = regex("(.*)-[a-z]", each.value.zone)[0]
}

resource "google_compute_firewall" "ssh" {
  for_each            = {for item in local.virtualMachinesWithExternalIp: item.name => item}
  name                = "${each.value.name}-ssh"
  network             = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges       = each.value.sshAuthorizedNetworks
  target_tags         = ["vm-${each.value.name}"]
}

resource "google_compute_firewall" "public" {
  for_each            = {for item in local.virtualMachinesWithPublicPorts: item.name => item}
  name                = "${each.value.name}-public"
  network             = var.network

  dynamic "allow" {
    for_each = length(each.value.publicTcpPorts) > 0 ? [1] : []
    content {
      protocol = "tcp"
      ports    = each.value.publicTcpPorts
    }
  }

  dynamic "allow" {
    for_each = length(each.value.publicUdpPorts) > 0 ? [1] : []
    content {
      protocol = "udp"
      ports    = each.value.publicUdpPorts
    }
  }

  source_ranges       = each.value.publicAuthorizedNetworks
  target_tags         = ["vm-${each.value.name}"]
}

resource "google_compute_instance" "vm" {
  for_each            = {for item in local.virtualMachines: item.name => item}

  name                = each.value.name
  machine_type        = each.value.machineType
  zone                = each.value.zone
  deletion_protection = each.value.deletionProtection

  tags                = ["vm-${each.value.name}"]

  network_interface {
    network = var.network
    subnetwork = each.value.subnetwork

    access_config {
      network_tier = "PREMIUM"
      nat_ip = google_compute_address.static[each.value.name] != null ? google_compute_address.static[each.value.name].address : null
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
