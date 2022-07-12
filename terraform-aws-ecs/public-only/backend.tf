terraform {
    backend "s3" {
        key = "ecs/tfstate.tfstate"
        bucket = "my-pet-projects-bucket"
        region = "us-west-2"
    }
}