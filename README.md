# terraform-google-netapp-volume

## Description
This module makes it easy to setup [NetApp Volumes](https://cloud.google.com/netapp/volumes/docs/discover/overview). It is designed to deploy [Stroage Pool](https://cloud.google.com/netapp/volumes/docs/configure-and-use/storage-pools/overview), [Storage Volume](https://cloud.google.com/netapp/volumes/docs/configure-and-use/volumes/overview), [Active Directory Configuration](https://cloud.google.com/netapp/volumes/docs/configure-and-use/active-directory/about-ad) and [Backup Vault](https://cloud.google.com/netapp/volumes/docs/protect-data/manage-backup-vault).


## Version

Current version is 0.X. Upgrade guides:


## Usage

Basic usage of this module is as follows:

```hcl
module "netapp_volume" {
  source = "../../"

  project_id         = var.project_id
  location           = "us-central1"
  pool_name          = "test-pool"
  storage_pool_size  = "2048"
  service_level      = "PREMIUM"
  ad_domain          = "ad.internal"
  ad_dns             = "172.30.64.3"
  network_name       = "vpc-net-netapp"
  ad_net_bios_prefix = "smbserver"
  ad_username        = "user"
  ad_password        = "password"
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

- [Terraform][terraform] v1.3+
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v5.12+

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/netapp.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `netapp.googleapis.com`

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
