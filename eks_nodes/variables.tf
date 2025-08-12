variable "region" {
  type = string
}

variable "availability_zone" {
  type = list(string)
}

variable "eks_cluster_name" {
  type = string
}

variable "public_key" {
  type = string
}
