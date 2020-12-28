# Azure VM Terraform

A [Terraform](https://en.wikipedia.org/wiki/Terraform_(software)) configuration to provision VM in [Azure](https://azure.microsoft.com/en-us/). The custom configuration inside `terraform.tfvars` will deploy and provision a virtual machine into subscription. We used `Ubuntuserver 20.04.0-LTS` image distribution and some packages are installed with `remote-exec` terraform ***provisioner***. For other distros, update accordingly in main.tf.

## Prerequisites

- Azure subscription (it supports free tier sub).
- Azure CLI installed and configured
- Log into Azure sub: `az login`

### Step 1 - Init plugins

```bash
terraform init
```

Azure plugin version: `~>2.16.0`

### Step 2 - Set the parameters

Terraform will read default vars from `terraform.tfvars` automatically. Don't forget to update the values.

```
subscription_id = "update_me"
location        = "update_me"
admin_password  = "update_me"
admin_username  = "update_me"
```

### Step 3 - Show the plan

```bash
terraform plan
```

### Step 4 - Create resource

```bash
terraform apply -auto-approve
```

## Destroy resources

The resources will have the costs. To destroy all of them, run the following:

```bash
terraform destroy -auto-approve
```

> `Important:` Be careful, if you have removed the `terraform.tfstate` file created when resources were deployed, then you won't be able to destroy using this command, and this will be only possible manually in the UI portal or through az CLI.

## Authors

- **Finbarrs Oketunji** _aka 0xnu_ - _Main Developer_ - [0xnu](https://github.com/0xnu)

## License

This project is licensed under the [WTFPL License](LICENSE) - see the file for details.

## Copyright

(c) 2020 [Finbarrs Oketunji](https://finbarrs.eu).

