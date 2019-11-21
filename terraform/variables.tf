variable "vm_config" {
  default = {
    # "inf-registry" = { vcpu = 1, memory = 512, ip = ["10.10.1.11"], disk = 10 }
    # "inf-jenkins" = { vcpu = 2, memory = 2048, ip = ["10.10.1.12"], disk = 10 }
    "web-01"   = { vcpu = 1, memory = 512, ip = ["10.10.1.13"], disk = 10 }
    "web-02"   = { vcpu = 1, memory = 512, ip = ["10.10.1.14"], disk = 10 }
    "haproxy1" = { vcpu = 1, memory = 512, ip = ["10.10.1.15"], disk = 10 }
    "haproxy2" = { vcpu = 1, memory = 512, ip = ["10.10.1.16"], disk = 10 }
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
    name = "tf_pool"
  }
}

variable "images_pool" {
  default = {
    centos = "/kvm-pool/images/CentOS-7-x86_64-GenericCloud-1907.qcow2"
    ubuntu = "/kvm-pool/images/ubuntu-18.04-server-cloudimg-amd64.img"
  }
}

