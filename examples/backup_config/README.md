# NetApp Example with backup policy

This example illustrates how to use the `netapp-volume` module. It creates a NetApp Storage Pool and 2 Volumes in that Storage Pool with backup policy attached.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network\_name | The ID of the network in which to provision resources. | `string` | `"backup-netapp"` | no |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| region | Location of the resources | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| backup\_policy\_id | Backup policy created |
| backup\_vault\_id | Backup vault created |
| location | Location of the resources |
| project\_id | Project ID |
| storage\_pool | Storage pool created |
| storage\_volumes | List of created volumes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
