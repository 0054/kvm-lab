variable "vm_config" {
  default = {
    # "inf-registry" = { vcpu = 1, memory = 512, ip = ["10.10.1.11"], disk = 10 }
    # "inf-jenkins" = { vcpu = 2, memory = 2048, ip = ["10.10.1.12"], disk = 10 }
    # "web-01" = { vcpu = 2, memory = 2048, ip = ["10.10.1.13"], disk = 10 }
    # "web-02" = { vcpu = 1, memory = 512, ip = ["10.10.1.14"], disk = 10 }
    # "haproxy1" = { vcpu = 1, memory = 512, ip = ["10.10.1.15"], disk = 10 }
    # "haproxy2" = { vcpu = 1, memory = 512, ip = ["10.10.1.16"], disk = 10 }
    # "lb-nginx1" = { vcpu = 1, memory = 512, ip = ["10.10.1.17"], disk = 10 }
    # "lb-nginx2" = { vcpu = 1, memory = 512, ip = ["10.10.1.18"], disk = 10 }
    # "inf-prometheus" = { vcpu = 1, memory = 512, ip = ["10.10.1.19"], disk = 10 }
    #"inf-rsync" = { vcpu = 1, memory = 512, ip = ["10.10.1.20"], disk = 10 }
    "inf-db1" = { vcpu = 2, memory = 2048, ip = ["10.10.1.21"], disk = 15 }
    # "inf-db2" = { vcpu = 2, memory = 2048, ip = ["10.10.1.22"], disk = 10 }
    # "inf-mariadb1" = { vcpu = 2, memory = 1024, ip = ["10.10.1.23"], disk = 10 }
    # "inf-mariadb2" = { vcpu = 2, memory = 1024, ip = ["10.10.1.24"], disk = 10 }
    # "elk-1" = { vcpu = 1, memory = 2048, ip = ["10.10.1.31"], disk = 10 }
    # "elk-2" = { vcpu = 1, memory = 2048, ip = ["10.10.1.32"], disk = 10 }
    # "elk-3" = { vcpu = 1, memory = 2048, ip = ["10.10.1.33"], disk = 10 }

    # "client1" = { vcpu = 1, memory = 512, ip = ["10.10.1.200"], disk = 10 }
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

