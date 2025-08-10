variable "region" {
  type = string
}

variable "availability_zone" {
  type        = list(string)
  description = "List of Az's in my region"
}

variable "eks_cluster_name" {
  type = string
}

variable "public_key" {
  type = string
}
