# terraform-google-netapp-volume

## Description
This module makes it easy to setup [NetApp Volumes](https://cloud.google.com/netapp/volumes/docs/discover/overview). It is designed to deploy [Stroage Pool](https://cloud.google.com/netapp/volumes/docs/configure-and-use/storage-pools/overview), [Storage Volume](https://cloud.google.com/netapp/volumes/docs/configure-and-use/volumes/overview), [Active Directory Configuration](https://cloud.google.com/netapp/volumes/docs/configure-and-use/active-directory/about-ad) and [Backup Vault](https://cloud.google.com/netapp/volumes/docs/protect-data/manage-backup-vault).


## Version

Current version is 0.X. Upgrade guides:


## Usage

Basic usage of this module is as follows:

```hcl
module "netapp_volume" {
  source = "GoogleCloudPlatform/netapp-volumes/google"
  version = "~> 0.1"

  project_id         = var.project_id
  location           = "us-central1"

  storege_pool = {
    create_pool   = true
    name          = "test-pool"
    size          = "2048"
    service_level = "PREMIUM"
    ldap_enabled  = false
    network_name  = var.network_name
    labels = {
      pool_env = "test"
    }
    description = "test pool"
  }

  storage_volumes = [

    { name       = "test-volume-1"
      share_name = "test-volume-1"
      size       = "100"
      protocols  = ["NFSV3"]
      snapshot_policy = {
        enabled = true
        daily_schedule = {
          snapshots_to_keep = 1
          minute            = 45
          hour              = 23
        }
      }

      export_policy_rules = {
        test = {
          allowed_clients = "10.0.0.0/24,10.100.0.0/24"
          access_type     = "READ_WRITE"
          nfsv3           = true
          has_root_access = true
        }
      }
    },

    { name       = "test-volume-2"
      share_name = "test-volume-2"
      size       = "200"
      protocols  = ["NFSV3"]
      snapshot_policy = {
        enabled = true
        daily_schedule = {
          snapshots_to_keep = 1
          # minute            = 1
          hour = 22
        }
      }
    },

  ]

}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| common\_labels | Common Labels as key value pairs for all the resources | `map(any)` | `{}` | no |
| location | Name of the location. Usually a region name, expect for some STANDARD service level pools which require a zone name | `string` | n/a | yes |
| project\_id | The ID of the project in which the resource belongs | `string` | n/a | yes |
| storage\_volumes | Storage volumes details | <pre>list(object({<br>    name               = string<br>    size               = number<br>    share_name         = string<br>    protocols          = list(string)<br>    labels             = optional(map(string), {})<br>    smb_settings       = optional(list(string))<br>    unix_permissions   = optional(string)<br>    description        = optional(string)<br>    snapshot_directory = optional(bool)<br>    security_style     = optional(string)<br>    kerberos_enabled   = optional(bool)<br>    restricted_actions = optional(list(string))<br><br>    export_policy_rules = optional(map(object({<br>      allowed_clients       = optional(string)<br>      has_root_access       = optional(string)<br>      access_type           = optional(string) #Possible values are: READ_ONLY, READ_WRITE, READ_NONE<br>      nfsv3                 = optional(bool)<br>      nfsv4                 = optional(bool)<br>      kerberos5_read_only   = optional(bool)<br>      kerberos5_read_write  = optional(bool)<br>      kerberos5i_read_only  = optional(bool)<br>      kerberos5i_read_write = optional(bool)<br>      kerberos5p_read_only  = optional(bool)<br>      kerberos5p_read_write = optional(bool)<br>    })))<br><br>    snapshot_policy = optional(object({<br>      enabled = optional(bool, false)<br>      hourly_schedule = optional(object({<br>        snapshots_to_keep = optional(number)<br>        minute            = optional(number)<br>      }), null)<br><br>      daily_schedule = optional(object({<br>        snapshots_to_keep = optional(number)<br>        minute            = optional(number)<br>        hour              = optional(number)<br>      }), null)<br><br>      weekly_schedule = optional(object({<br>        snapshots_to_keep = optional(number)<br>        minute            = optional(number)<br>        hour              = optional(number)<br>        day               = optional(string)<br>      }), null)<br>    }))<br><br>  }))</pre> | n/a | yes |
| storege\_pool | Storage pool details | <pre>object({<br>    create_pool   = optional(bool, false)<br>    name          = string<br>    network_name  = optional(string)<br>    service_level = optional(string)<br>    description   = optional(string)<br>    labels        = optional(map(string), {})<br>    size          = optional(number)<br>    ldap_enabled  = optional(bool, false)<br>    ad_id         = optional(string)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| storage\_pool | Storage Pool created |
| storage\_volumes | Storage Volume created |

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
