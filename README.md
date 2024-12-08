# Google compute

Example usage:

```
provider "google" {
  project          = "my-infrastructure"
  region           = "europe-west1"
  zone             = "europe-west1-b"
}

resource "google_project_service" "compute" {
  service          = "compute.googleapis.com"
}

module "compute" {
  source           = "TaitoUnited/compute/google"
  version          = "1.0.0"

  project_id       = "my-project"
  network          = "my-project-net"
  virtual_machines = yamldecode(file("${path.root}/../infra.yaml"))["virtualMachines"]
}
```

Example YAML:

```
virtualMachines:
  - name: my-server
    zone: europe-west1-b
    subnetwork: subnet-europe-west1
    externalIp: false
    machineType: e2-medium
    diskSizeGb: 100

  - name: my-server2
    zone: europe-west1-b
    subnetwork: subnet-europe-west1
    sshAuthorizedNetworks: ["35.235.240.0/20"]
    publicAuthorizedNetworks: ["0.0.0.0/32"]
    publicTcpPorts: ["80", "443"]
    machineType: e2-medium
    image: debian-cloud/debian-12
    diskSizeGb: 100
    gpuType: nvidia-tesla-t4
    gpuCount: 1
```

YAML attributes:

- See variables.tf for all the supported YAML attributes.
- See [compute_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) for attribute descriptions.

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/google)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/google)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/google)
- [Compute](https://registry.terraform.io/modules/TaitoUnited/compute/google)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/google)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/google)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/google)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/google)
- [Integrations](https://registry.terraform.io/modules/TaitoUnited/integrations/google)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/postgresql)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/mysql)

TIP: Similar modules are also available for AWS, Azure, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/). See also [Google Cloud project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/google), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!
