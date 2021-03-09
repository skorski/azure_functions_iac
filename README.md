# Example Python Azure Function with Terraform

This repo shows how to automatically deploy a python azure function with the appropriate application insights instance.
The user can deploy the function to any region using the variables defined in `terraform/variables.tf`.

The python function is packaged and deployed using the `func azure` commands.
These are likely to be installed if the user is doing local development.
In CI/CD scenarios, these tools may have to be installed.

The `hello_world` folder contains the python code that is to be deployed.
These files are zipped with a sha hash recorded for the output.
Terraform can track the value of the hash and then automatically redeploy when changes are made.

Getting going...

1. `terraform init --upgrade` install any required terraform packages.
1. `az login` login to the azure subscription.
1. `az account list -o table` verify you are working in the right subscription.
1. `terraform apply -var="project=example"` package up the app and deploy it to azure.
1. ...do work, make changes...
1. `terraform apply -var="project=example"` push changes into azure.
1. `terraform destroy` remove all traces of your work.

## Resources

primary documentation
https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell#set-up-terraform-access-to-azure

Installing terraform:
https://learn.hashicorp.com/tutorials/terraform/install-cli

Installing Azure CLI:
https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

Terraform + azure functions:
https://www.maxivanov.io/deploy-azure-functions-with-terraform/

### Azure Login

You'll need to ensure you are logged into azure appropriately.
Start with `az login`.
This should open a browser window and allow you to authenticate.

Next you'll have to verify you are in the right subscription.
Run `az account list -o table` and make sure the correct subscription is set to IsDefault.

The subscription can be changed using `az account set --subscription {subscription_id}`

### Running Terraform

Create the `main.tf` file with the azurerm plugin configuration
Then run `terraform init -upgrade` to download the plugin locally.

Creating the plan generates a binary like file `tfplan`.
`tf apply {filename}.tfplan` will then make the changes in azure.

You can create a graph of the deployment... I didn't find it very useful.
`terraform graph | dot -Tsvg > graph.svg`

`terraform destroy` will remove resources.
This is run in the directory containing the `terraform.tfstate` file.

The main.tf file can be edited and has autocomplete when the terraform plugins are enabled.
This does not provide context to individual variables.

### Resource Variables
[archive](https://registry.terraform.io/providers/hashicorp/archive/latest)
[storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)


## Azure Functions

Installed the local azure function tools [link](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local).

Plan to create local python function and use the terraform script to deploy it.

Python 3.6 is the latest supported by azure functions?  
Ran it with conda environment set to 3.6.
It found python 3.8.5 and was happy.
The primary grumble was python 3.7.9.

Going through hello world [azure functions](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-cli-python)

Potential remote debugging? https://medium.com/airwalk/debugging-azure-functions-in-pycharm-c666e1cc5d98