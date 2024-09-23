# terraform-google-netapp-volumes

## Description
This module makes it easy to setup [NetApp Volumes](https://cloud.google.com/netapp/volumes/docs/discover/overview). It is designed to deploy [Stroage Pool](https://cloud.google.com/netapp/volumes/docs/configure-and-use/storage-pools/overview) and [Storage Volume(s)](https://cloud.google.com/netapp/volumes/docs/configure-and-use/volumes/overview). Creation of Storage Pool is optional. Module can create Storage Volme(s) in an existing storage pool.
## Compatibility

This module is meant for use with Terraform 1.3+ and tested using Terraform 1.3+. If you find incompatibilities using Terraform >=1.3, please open an issue.

## Version

Current version is 0.X. Upgrade guides:

- [0.X -> 1.0](/docs/upgrading_to_v1.0.md)


## Usage
Functional examples are included in the [examples](./examples/) directory. Basic usage of this module is as follows:

- Create a Storage Pool and Storage Volumes

```hcl
module "netapp_pool_volume" {
  source  = "GoogleCloudPlatform/netapp-volumes/google"
  version = "~> 1.1"

  project_id         = "test-project-id"
  location           = "us-central1"

  storage_pool = {
    create_pool   = true
    name          = "test-pool"
    size          = "2048"
    service_level = "PREMIUM"
    ldap_enabled  = false
    network_name  = "test-network"
    labels = {
      pool_env = "test"
    }
    description = "test pool"
  }

  storage_volumes = [

    {
      name       = "test-volume-1"
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

    {
      name       = "test-volume-2"
      share_name = "test-volume-2"
      size       = "200"
      protocols  = ["NFSV3"]
      snapshot_policy = {
        enabled = true
        daily_schedule = {
          snapshots_to_keep = 1
          hour              = 22
        }
      }
    },

  ]


}
```

- Create storage volumes in an existing storage pool

```hcl
module "storage_pool_only" {
  source  = "GoogleCloudPlatform/netapp-volumes/google"
  version = "~> 1.0"


  project_id = var.project_id
  location   = var.region

  storage_pool = {
    create_pool   = true
    name          = "test-pool-2"
    size          = "2048"
    service_level = "PREMIUM"
    ldap_enabled  = false
    network_name  = var.network_name
    labels = {
      pool_env = "test"
    }
    description = "test storage pool only"
  }

  depends_on = [
    google_service_networking_connection.vpc_connection,
    google_service_networking_connection.netapp_vpc_connection,
  ]
}


## 3 - Create storage volume in the storage pool already created

module "volumes_only" {
  source  = "GoogleCloudPlatform/netapp-volumes/google"
  version = "~> 1.0"


  project_id = module.netapp_volumes.storage_pool.project
  location   = module.netapp_volumes.storage_pool.location

  # name of an existing storage pool
  storage_pool = {
    create_pool = false
    name        = module.storage_pool_only.storage_pool.name
  }

  storage_volumes = [
    # test-volume-3
    {
      name            = "test-volume-3"
      share_name      = "test-volume-3"
      size            = "100"
      protocols       = ["NFSV3"]
      deletion_policy = "FORCE"
      snapshot_policy = {
        enabled = true
        daily_schedule = {
          snapshots_to_keep = 1
          minute            = 21
          hour              = 4
        }
        weekly_schedule = {
          snapshots_to_keep = 2
          minute            = 1
          hour              = 3
          day               = "Sunday"
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
  ]

  depends_on = [
    module.netapp_volumes,
  ]
}
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| common\_labels | Common Labels as key value pairs. Applies to all the resources. If labels are provided in storege\_pool or storage\_volumes then they are merged with common labels before being applied to the resources | `map(any)` | `{}` | no |
| location | Name of the location. Usually a region name, expect for some STANDARD service level pools which require a zone name | `string` | n/a | yes |
| project\_id | The ID of the project in which the resource belongs | `string` | n/a | yes |
| storage\_pool | Storage pool details | <pre>object({<br>    create_pool        = optional(bool, false)<br>    name               = string<br>    network_name       = optional(string)<br>    network_project_id = optional(string)<br>    service_level      = optional(string)<br>    size               = optional(number)<br>    description        = optional(string)<br>    labels             = optional(map(string), {})<br>    ldap_enabled       = optional(bool, false)<br>    ad_id              = optional(string)<br>  })</pre> | n/a | yes |
| storage\_volumes | List of Storage Volumes | <pre>list(object({<br>    name               = string<br>    size               = number<br>    share_name         = string<br>    protocols          = list(string)<br>    labels             = optional(map(string), {})<br>    smb_settings       = optional(list(string))<br>    unix_permissions   = optional(string)<br>    description        = optional(string)<br>    snapshot_directory = optional(bool)<br>    security_style     = optional(string)<br>    kerberos_enabled   = optional(bool)<br>    restricted_actions = optional(list(string))<br>    deletion_policy    = optional(string)<br><br>    backup_policies          = optional(list(string))<br>    backup_vault             = optional(string)<br>    scheduled_backup_enabled = optional(bool, true)<br><br>    export_policy_rules = optional(map(object({<br>      allowed_clients       = optional(string)<br>      has_root_access       = optional(string)<br>      access_type           = optional(string) #Possible values are: READ_ONLY, READ_WRITE, READ_NONE<br>      nfsv3                 = optional(bool)<br>      nfsv4                 = optional(bool)<br>      kerberos5_read_only   = optional(bool)<br>      kerberos5_read_write  = optional(bool)<br>      kerberos5i_read_only  = optional(bool)<br>      kerberos5i_read_write = optional(bool)<br>      kerberos5p_read_only  = optional(bool)<br>      kerberos5p_read_write = optional(bool)<br>    })))<br><br>    snapshot_policy = optional(object({<br>      enabled = optional(bool, false)<br>      hourly_schedule = optional(object({<br>        snapshots_to_keep = optional(number)<br>        minute            = optional(number)<br>      }))<br><br>      daily_schedule = optional(object({<br>        snapshots_to_keep = optional(number)<br>        minute            = optional(number)<br>        hour              = optional(number)<br>      }))<br><br>      weekly_schedule = optional(object({<br>        snapshots_to_keep = optional(number)<br>        minute            = optional(number)<br>        hour              = optional(number)<br>        day               = optional(string)<br>      }))<br><br>      monthly_schedule = optional(object({<br>        snapshots_to_keep = optional(number)<br>        minute            = optional(number)<br>        hour              = optional(number)<br>        days_of_month     = optional(string)<br>      }))<br><br>    }))<br><br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| storage\_pool | Storage Pool created |
| storage\_volumes | Storage Volume(s) created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## storage_pool details
In order to create Storage Pool set `create_pool` to `true`, provide values for `name`, `network_name`, `service_level` and `size`. Other fields are optional.

If you already have a Storage Pool created, set `create_pool` to `false` and provide `name` of an existing Storage Pool.


## storage_volumes details
Provide list of storage volumes to create. Each volume requires `name`, `size`, `share_name` and protocols. Other fields are optional.

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v1.3+
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v5.33+

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Google Cloud NetApp Volumes Admin: `roles/netapp.admin`

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud NetApp Volumes API: `netapp.googleapis.com`

The [Project Factory module](https://github.com/terraform-google-modules/terraform-google-project-factory) can be used to provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for information on contributing to this module.


## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
