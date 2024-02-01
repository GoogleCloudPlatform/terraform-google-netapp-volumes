# Simple Example

This example illustrates how to use the `netapp-volume` module. It creates a NetApp Storage Pool and 2 Volumes in that Storage Pool. It also creates third volume by calling module and proving name of the storage pool created using the first module call.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network\_name | The ID of the network in which to provision resources. | `string` | `"simple-netapp"` | no |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| region | Location of the resources | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| location | Location of the resources |
| project\_id | n/a |
| storage\_pool | Storage pool created |
| storage\_pool\_id | Name of theStorage pool created |
| storage\_pool\_name | Name of theStorage pool created |
| storage\_volume1\_id | storage volume 1 ID |
| storage\_volume1\_name | storage volume 1 name |
| storage\_volume2\_id | storage volume 2 ID |
| storage\_volume2\_name | storage volume 2 name |
| storage\_volume3\_id | storage volume 3 ID |
| storage\_volume3\_name | storage volume 3 name |
| storage\_volumes | List of created volumes |
| storage\_volumes\_only | List of created volumes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
