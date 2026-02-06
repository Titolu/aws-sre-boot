locals {
  total_subnet  = 2
  public_count  = 1
  private_count = local.total_subnet - local.public_count


  # This is a new method of using COUNT
  subnet_ip = [
    { subnet_cidr = "10.0.1.0/27" }, #Public - 0
    { subnet_cidr = "10.0.2.0/27" }  #Private - 1
  ]


}
