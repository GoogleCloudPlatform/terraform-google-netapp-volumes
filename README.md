# terraform-google-netapp-volume

## Description
### Tagline
This is an auto-generated module.

### Detailed
This module was generated from [terraform-google-module-template](https://github.com/terraform-google-modules/terraform-google-module-template/), which by default generates a module that simply creates a GCS bucket. As the module develops, this README should be updated.

The resources/services/activations/deletions that this module will create/trigger are:

- Create a GCS bucket with the provided name

### PreDeploy
To deploy this blueprint you must have an active billing account and billing permissions.

## Architecture
![alt text for diagram](https://www.link-to-architecture-diagram.com)
1. Architecture description step no. 1
2. Architecture description step no. 2
3. Architecture description step no. N

## Documentation
- [Hosting a Static Website](https://cloud.google.com/storage/docs/hosting-static-website)

## Deployment Duration
Configuration: X mins
Deployment: Y mins

## Cost
[Blueprint cost details](https://cloud.google.com/products/calculator?id=02fb0c45-cc29-4567-8cc6-f72ac9024add)

## Usage

Basic usage of this module is as follows:

```hcl
module "netapp_volume" {
  source  = "terraform-google-modules/netapp-volume/google"
  version = "~> 0.1"

  project_id  = "<PROJECT ID>"
  bucket_name = "gcs-test-bucket"
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ad\_aes\_encryption | Enables AES-128 and AES-256 encryption for Kerberos-based communication with Active Directory | `bool` | `null` | no |
| ad\_backup\_operators | Domain user/group accounts to be added to the Backup Operators group of the SMB service. The Backup Operators group allows members to backup and restore files regardless of whether they have read or write access to the files. Comma-separated list | `list(string)` | `null` | no |
| ad\_description | An optional description of this resource | `string` | `null` | no |
| ad\_dns | Comma separated list of DNS server IP addresses for the Active Directory domain | `string` | n/a | yes |
| ad\_domain | Fully qualified domain name for the Active Directory domain | `string` | n/a | yes |
| ad\_encrypt\_dc\_connections | If enabled, traffic between the SMB server to Domain Controller (DC) will be encrypted | `bool` | `null` | no |
| ad\_kdc\_hostname | Hostname of the Active Directory server used as Kerberos Key Distribution Center. Only requried for volumes using kerberized NFSv4.1 | `string` | `null` | no |
| ad\_kdc\_ip | IP address of the Active Directory server used as Kerberos Key Distribution Center | `string` | `null` | no |
| ad\_labels | Active directory labels as key value pairs | `map(any)` | `{}` | no |
| ad\_ldap\_signing | Specifies whether or not the LDAP traffic needs to be signed | `bool` | `null` | no |
| ad\_name | The resource name of the Active Directory pool. Needs to be unique per location | `string` | `null` | no |
| ad\_net\_bios\_prefix | NetBIOS name prefix of the server to be created | `string` | n/a | yes |
| ad\_nfs\_users\_with\_ldap | Local UNIX users on clients without valid user information in Active Directory are blocked from access to LDAP enabled volumes. This option can be used to temporarily switch such volumes to AUTH\_SYS authentication (user ID + 1-16 groups) | `bool` | `null` | no |
| ad\_organizational\_unit | Name of the Organizational Unit where you intend to create the computer account for NetApp Volumes. Defaults to CN=Computers if left empty | `string` | `null` | no |
| ad\_password | Password for specified username. Note - Manual changes done to the password will not be detected. Terraform will not re-apply the password, unless you use a new password in Terraform. Note: This property is sensitive and will not be displayed in the plan | `string` | n/a | yes |
| ad\_security\_operators | Domain accounts that require elevated privileges such as SeSecurityPrivilege to manage security logs. Comma-separated list | `list(string)` | `null` | no |
| ad\_site | Domain user/group accounts to be added to the Backup Operators group of the SMB service. The Backup Operators group allows members to backup and restore files regardless of whether they have read or write access to the files. Comma-separated list | `string` | `null` | no |
| ad\_username | Username for the Active Directory account with permissions to create the compute account within the specified organizational unit | `string` | n/a | yes |
| backup\_vault\_description | An optional description of this resource | `string` | `null` | no |
| backup\_vault\_labels | Active directory labels as key value pairs | `map(any)` | `{}` | no |
| backup\_vault\_name | The resource name of the backup vault. Needs to be unique per location | `string` | `null` | no |
| common\_labels | Common Labels as key value pairs for all the resources | `map(any)` | `{}` | no |
| ldap\_enabled | When enabled, the volumes uses Active Directory as LDAP name service for UID/GID lookups. Required to enable extended group support for NFSv3, using security identifiers for NFSv4.1 or principal names for kerberized NFSv4.1 | `bool` | `false` | no |
| location | Name of the location. Usually a region name, expect for some STANDARD service level pools which require a zone name | `string` | n/a | yes |
| network\_name | Name of VPC Network | `string` | n/a | yes |
| pool\_description | An optional description of this resource | `string` | `null` | no |
| pool\_labels | Storage pool labels as key value pairs | `map(any)` | `{}` | no |
| pool\_name | The resource name of the storage pool. Needs to be unique per location | `string` | n/a | yes |
| project\_id | The ID of the project in which the resource belongs | `string` | n/a | yes |
| service\_level | Service level of the storage pool. Possible values are: PREMIUM, EXTREME, STANDARD | `string` | n/a | yes |
| storage\_pool\_size | Capacity of the storage pool (in GiB) | `number` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/storage.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
