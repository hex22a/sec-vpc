variable "db_remote_state_bucket" {
  type = string
  default = "tf-backend-bucket-sec-vpc-2"
}

variable "db_remote_state_key" {
  type = string
  default = "3x-ui.tfstate"
}

variable "db_remote_state_region" {
  type = string
  default = "us-east-1"
}
