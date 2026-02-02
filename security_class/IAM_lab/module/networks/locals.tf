locals {
  total_subnet = 2
  public_count = 1


  # This is a new method of using COUNT
  subnet_ip = [
    {
      subnet_cidr = "10.0.1.0/27"
    },
    {
      subnet_cidr = "10.0.2.0/27"
    }
  ]


}
