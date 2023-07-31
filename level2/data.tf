data "terraform_remote_state" "level1" {
  backend = "s3"

  config = {
    bucket = "terraformbuck861"
    key    = "tasks-terraform/level1.tfstate"
    region = "ap-south-1"
  }

}