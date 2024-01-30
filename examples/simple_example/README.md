# Simple Example

This example illustrates how to use the `netapp-volume` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network\_name | The ID of the network in which to provision resources. | `string` | `"simple-netapp"` | no |
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |
| region | The region for primary cluster | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_id | KMS key for kms config profile |
| netapp\_volumes | n/a |
| project\_id | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
