# Configure Terraform

## Download and install terraform binary
Get the latest stable version:

    # wget -O- https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip | funzip > /usr/bin/terraform
    # chmod +x /usr/bin/terraform

## Create instances ssh key
Generate keypairs for instances:

    $ ssh-keygen -N '' -t rsa -f templates/id_rsa

## Make providers init
The OpenStack provider needs to be configured with the proper credentials
before it can be used. They could be loaded from the environment variable names
(e.g. OS_*):

    $ export OS_CLOUD=admin
    $ terraform init

## Apply terraform state

Define image in `tfvars/3node.tfvars`

    $ terraform plan
    $ terraform apply -auto-approve -var-file=tfvars/3node.tfvars
