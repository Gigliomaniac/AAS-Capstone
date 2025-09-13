terraform {
  backend "s3" {
    bucket = "capstonestatefilestorage" # is literally my bucket name
    #key    = "terraform.tfstate"
    #key     = "labs//terraform.tfstate"
    region = "us-east-1"
    encrypt      = true # just encrypts the file. Gotta have it
  }
}