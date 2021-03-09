variable "project" {
    type = string
    description = "Project name that is used as a prefix."

    validation {
        condition = length(var.project) > 4 && length(join("", regexall("[a-z0-9-]*", var.project))) == length(var.project)
        error_message = "Must be more than 4 characters, lowercase, and only contain (a-z0-9-)."
    }
}

variable "location" {
    type = string
    description = "Azure region for resources."
}

variable "environment" {
    type = string
    description = "Environment (dev / stage / prod)"
}

variable "functionapp" {
    type = string
    default = "./main.tf"
}