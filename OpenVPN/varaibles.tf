variable "vpc_name" {
  type        = string
  default     = "sec-vpc"
  description = "VPC name to use"
}
#
# variable "backend_bucket" {
#   type = string
#   description = "S3 bucket name to store tfstate"
# }
#
# variable "backend_bucket_region" {
#   type = string
#   description = "S3 bucket region"
# }
