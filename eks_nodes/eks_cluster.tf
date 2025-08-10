# EKS Master Role
resource "aws_iam_role" "role_cluster" {
  name               = "eks-role-cluster"
  assume_role_policy = file("${path.module}/iam_role_policy/cluster_iam_role.json")
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.role_cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.role_cluster.name
}



# EKS Cluster
resource "aws_eks_cluster" "eks_clus" {
  name = "HR_EKS-Cluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.role_cluster.arn
  version  = "1.32"

  vpc_config {
    subnet_ids              = local.public_subnets #concat for multiple subnets(local.public_subnets, local.private_subnets)
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    #security_group_ids      = [aws_security_group.eks_vpc_sg.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }

  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "authenticator", "audit", "controllerManager", "scheduler"]



  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]
}
