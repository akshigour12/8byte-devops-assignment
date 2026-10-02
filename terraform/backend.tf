terraform {
  backend "s3" {
    bucket       = "8byte-devops-tfstate-109131608993"
    key          = "staging/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
