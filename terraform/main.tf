terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.26"
    }
    null = {
      source = "hashicorp/null"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~>2.1.0"
    }
    time = {
      source = "hashicorp/time"
      version = "~>0.7.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "random_string" "storage_name" {
    length = 8
    upper = false
    lower = true
    number = true
    special = false
}

resource "azurerm_resource_group" "rg" {
  name = "${var.project}-${var.environment}"
  location = var.location
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-${var.environment}-application-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "Node.JS" #unsure if this should be something else one of [web other java MobileCenter phone store ios Node.JS]
}

resource "azurerm_app_service_plan" "asp" {
    name = "${var.project}-asp"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    kind = "functionapp"
    reserved = true
    sku {
        tier = "Dynamic"
        size = "Y1"
    }
}

resource "azurerm_function_app" "functions" {
    name = join("", regexall("[a-z0-9]*", "${var.project}-${var.environment}"))
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.asp.id
    version = "~3"
    storage_account_access_key = "${azurerm_storage_account.storage.primary_access_key}"
    storage_account_name = "${azurerm_storage_account.storage.name}"
    os_type = "linux"
    app_settings = {
        https_only = true
        FUNCTIONS_WORKER_RUNTIME = "python"
        APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.application_insights.instrumentation_key
    }
}


resource "azurerm_storage_account" "storage" {
  name = replace(lower("${var.project}-${random_string.storage_name.result}"), "/[^a-z0-9]*/", "")
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "deployments" {
  name = replace("${var.project}-releases", "_", "-")
  storage_account_name = azurerm_storage_account.storage.name
  container_access_type = "private"
}

data "archive_file" "python_source" {
  type = "zip"
  output_path = "files/test.zip"
  source_dir = "../hello_world/"
}

resource "time_sleep" "wait_30_seconds" {
//  Adding a delay so the function is available
  depends_on = [azurerm_function_app.functions]
  create_duration = "30s"
}

resource "null_resource" "func_deploy" {
  depends_on = [time_sleep.wait_30_seconds, azurerm_function_app.functions]
  triggers = {
    src_hash = "${data.archive_file.python_source.output_sha}"
  }
  provisioner "local-exec" {
    command = "cd ../hello_world && func azure functionapp publish ${azurerm_function_app.functions.name}"
  }
}
