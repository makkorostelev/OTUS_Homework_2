resource "yandex_compute_instance" "default" {
  platform_id = "standard-v1"
  hostname    = "node-${count.index}"
  count       = 3

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vm24pae6k98274k7o" # ОС (CentOS 7)
    }

  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.custom_subnet.id
    security_group_ids = [yandex_vpc_security_group.custom_sg.id]
    nat                = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: centos\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${var.public_key}"
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
    echo "[node${count.index}]" >> hosts.ini
    echo "${self.network_interface.0.nat_ip_address}" >> hosts.ini
    EOF
  }
}

resource "yandex_compute_instance" "storage" {
  platform_id = "standard-v1"
  hostname    = "storage"
  depends_on  = [yandex_compute_instance.default]

  resources {
    cores  = 2
    memory = 2
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.empty-disk.id
    auto_delete = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vm24pae6k98274k7o" # ОС (CentOS 7)
    }

  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.custom_subnet.id
    security_group_ids = [yandex_vpc_security_group.custom_sg.id]
    nat                = true
    ip_address         = "10.5.0.100"
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: centos\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${var.public_key}"
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
    echo "[cluster:children]" >> hosts.ini
    echo "node0\nnode1\nnode2" >> hosts.ini
    echo "[storage]" >> hosts.ini
    echo "${self.network_interface.0.nat_ip_address}" >> hosts.ini
    ansible-playbook -u centos -i hosts.ini --private-key ${var.private_key_path} pacemaker-playbook.yml --extra-var "storage_ip=${self.network_interface.0.nat_ip_address}"
    rm -rf hosts.ini
    EOF
  }
}

resource "yandex_compute_disk" "empty-disk" {
  name = "empty-disk"
  type = "network-hdd"
  size = 5
}


resource "yandex_vpc_network" "custom_vpc" {
  name = "custom_vpc"

}
resource "yandex_vpc_subnet" "custom_subnet" {
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.custom_vpc.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}



resource "yandex_vpc_security_group" "custom_sg" {
  name        = "WebServer security group"
  description = "My Security group"
  network_id  = yandex_vpc_network.custom_vpc.id

  dynamic "ingress" {
    for_each = ["80", "443", "22", "2224", "3121", "3260", "5403", "21064", "9929"]
    content {
      protocol       = "TCP"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = ingress.value
    }
  }

  dynamic "ingress" {
    for_each = ["5404", "5405", "9929"]
    content {
      protocol       = "UDP"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = ingress.value
    }
  }

  egress {
    protocol       = "ANY"
    description    = "Outcoming traf"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = -1
  }
}
