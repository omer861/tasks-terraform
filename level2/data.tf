data "terraform_remote_state" "level1" {
  backend = "s3"

  config = {
    bucket = "task-terraform"
    key    = "level1.tfstate"
    region = "ap-south-1"
  }

}