variable "vm_config" {
  default = {
    "centos-vm1" = { vcpu = 1, memory = 512, ip = ["10.10.1.11"], disk = 10 }
    "centos-vm2" = { vcpu = 1, memory = 512, ip = ["10.10.1.12"], disk = 10 }
    # "centos-vm3" = { vcpu = 1, memory = 512, ip = ["10.10.1.13"], disk = 10 }
    # "centos-vm4" = { vcpu = 1, memory = 512, ip = ["10.10.1.14"], disk = 10 }
    # "centos-vm5" = { vcpu = 1, memory = 512, ip = ["10.10.1.15"], disk = 10 }
  }
}

variable "network_config" {
  default = {
    domain    = "kvm.lab"
    addresses = ["10.10.1.0/24"]
  }
}

variable "pool_config" {

  default = {
    path = "/kvm-pool/terraform_pool"
    name = "terraform_pool"
  }
}

