terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws" # The source is the directory in the repo
    }
  }
}

provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
  region                   = "us-east-1"
}
