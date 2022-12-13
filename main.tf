terraform {
  cloud {
    organization = "aierohin"

     workspaces {
      name = "prod"
    }
  }

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
#   backend "s3" {
#     endpoint   = "storage.yandexcloud.net"
#     bucket     = "backend-erohin"
#     region     = "ru-central1"
#     key        = "<terraform/terraform.tfstate"
#     # Key in open view
#     access_key = "YCAJEgSyr8YOSy-J1MueZOFvk"
#     secret_key = "YCMSbEULO903kNLN4cdihzgk3BznEbIM6sjTyqJG"
#
#     skip_region_validation      = true
#     skip_credentials_validation = true
#   }
}
provider "yandex" {
  service_account_key_file = file("key.json")
  #service_account_key_file = file("/home/erohin/diplom_netology/terraform/key.json")
  cloud_id  = "<b1gp7k458hlu48fmqj2v>"
  folder_id = "b1g7umb836h4foki8gu0"
}
variable "centos-7-base" {
  default = "fd89dg08jjghmn88ut7p"
}
resource "yandex_iam_service_account" "sa" {
  folder_id = "b1g7umb836h4foki8gu0"
  name = "service-account"
}
// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = "b1g7umb836h4foki8gu0"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}
// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}
// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "backend" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "backend-erohin"
}
# network.tf
resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet-a" {
  name = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.net.id}"
  v4_cidr_blocks = ["192.168.101.0/24"]
}
resource "yandex_vpc_subnet" "subnet-b" {
  name = "subnet-b"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.net.id}"
  v4_cidr_blocks = ["192.168.102.0/24"]
}
resource "yandex_vpc_subnet" "subnet-c" {
  name = "subnet-c"
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.net.id}"
  v4_cidr_blocks = ["192.168.103.0/24"]
}
#node-cp.tf
resource "yandex_compute_instance" "node-cp" {
  name                      = "node-cp"
  platform_id               = "standard-v1" # тип процессора (Intel Broadwell)
  zone                      = "ru-central1-a"
  hostname                  = "node-cp.netology.cloud"
  allow_stopping_for_update = true

  resources {
    core_fraction = 5 # Гарантированная доля vCPU
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.centos-7-base}"
      name        = "root-node-cp"
      type        = "network-hdd"
      size        = "50"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-a.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("id_rsa.pub")}"
  }
}
# node-worker-1.tf
resource "yandex_compute_instance" "node-work-1" {
  name                      = "node-work-1"
  platform_id               = "standard-v1" # тип процессора (Intel Broadwell)
  zone                      = "ru-central1-b"
  hostname                  = "node-work-1.netology.cloud"
  allow_stopping_for_update = true

  resources {
    core_fraction = 5 # Гарантированная доля vCPU
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.centos-7-base}"
      name        = "root-node-work-1"
      type        = "network-hdd"
      size        = "100"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-b.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("id_rsa.pub")}"
  }
}
# node-worker-2.tf
resource "yandex_compute_instance" "node-work-2" {
  name                      = "node-work-2"
  platform_id               = "standard-v1" # тип процессора (Intel Broadwell)
  zone                      = "ru-central1-c"
  hostname                  = "node-work-2.netology.cloud"
  allow_stopping_for_update = true

  resources {
    core_fraction = 5 # Гарантированная доля vCPU
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.centos-7-base}"
      name        = "root-node-work-2"
      type        = "network-hdd"
      size        = "100"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-c.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("id_rsa.pub")}"
  }
}
#output.tf
output "internal_ip_address_node-cp_yandex_cloud" {
  value = "${yandex_compute_instance.node-cp.network_interface.0.ip_address}"
}

output "external_ip_address_node-cp_yandex_cloud" {
  value = "${yandex_compute_instance.node-cp.network_interface.0.nat_ip_address}"
}
output "internal_ip_address_node-work-1_yandex_cloud" {
  value = "${yandex_compute_instance.node-work-1.network_interface.0.ip_address}"
}

output "external_ip_address_node-work-1_yandex_cloud" {
  value = "${yandex_compute_instance.node-work-1.network_interface.0.nat_ip_address}"
}
output "internal_ip_address_node-work-2_yandex_cloud" {
  value = "${yandex_compute_instance.node-work-2.network_interface.0.ip_address}"
}

output "external_ip_address_node-work-2_yandex_cloud" {
  value = "${yandex_compute_instance.node-work-2.network_interface.0.nat_ip_address}"
}