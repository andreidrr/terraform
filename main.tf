terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}


provider "digitalocean" {
  token = "dop_v1_b921eec13639ed194c4e10a5585f03b8bab0b5e76b3c0a5795f50c5016851c01"
}

#digital_droplet criando a maquina e passando os parametros
resource "digitalocean_droplet" "jenkies" {
  image  = "ubuntu-22-04-x64"
  name   = "jenkies"
  region = var.region
  size   = "s-2vcpu-2gb"
  #vinculando a chave ssh
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}


data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}


#Criando o Cluster kubernets:

resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.26.3-do.0"
  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}


#Criando variaveis
#variable "do_token" {
#  default = ""
#}

variable "ssh_key_name" {
  default = ""
}

variable "region" {
  default = ""
}

output "jenkies_ip" {
  value       = digitalocean_droplet.jenkies.ipv4_address
}

resource "local_file" "kube_config" {
  content  = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  filename = "kube_config.yaml"
}