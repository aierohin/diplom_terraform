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