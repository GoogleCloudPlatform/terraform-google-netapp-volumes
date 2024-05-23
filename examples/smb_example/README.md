# SMB NetApp Example

This example illustrates how to use the `netapp-volume` module. It creates a NetApp Storage Pool with ldap enabled and active directory policy. It also creates a volume with SMB protocol.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network\_name | The ID of the network in which to provision resources. | `string` | `"simple-netapp-smb"` | no |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| region | Location of the resources | `string` | `"us-central1"` | no |
| replica\_region | Location of the replica resources | `string` | `"us-east1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| active\_directory\_config | Active directory config |
| location | Location of the resources |
| project\_id | Project ID |
| storage\_pool | Storage pool created |
| storage\_pool\_id | Name of theStorage pool created |
| storage\_pool\_name | Name of theStorage pool created |
| storage\_volume1\_id | storage volume 1 ID |
| storage\_volume1\_name | storage volume 1 name |
| storage\_volumes | List of created volumes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
