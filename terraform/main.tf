provider "google" {
  credentials = "${file("../config/default.json")}"
  project     = "${var.gcloud_project}"
  region      = "${var.gcloud_region}"
}

provider "aws" {
  region = "ap-southeast-2"
  shared_credentials_file = "~/.aws/credentials"
  profile = "vessels-lewis.daly"
}

module "network" {
  source = "./modules/network"

  gcloud_region = "${var.gcloud_region}"

  platform_name = "${var.platform_name}"
}

module "cluster" {
  source = "./modules/cluster"

  gcloud_region = "${var.gcloud_region}"
  gcloud_zone = "${var.gcloud_zone}"

  platform_name = "${var.platform_name}"

  network_name = "${module.network.network_name}"
  subnetwork_name = "${module.network.subnetwork_name}"

  cluster_node_machine_type = "${var.cluster_node_machine_type}"
  cluster_node_initial_count = "${var.cluster_node_initial_count}"

  cluster_master_auth_username = "${var.cluster_master_auth_username}"
  cluster_master_auth_password = "${var.cluster_master_auth_password}"
}

module "dns" {
  source = "./modules/dns"

  route_53_zone_id = "${var.route_53_zone_id}"
  record_name_base = "${var.record_name_base}"
  record_name_wild = "${var.record_name_wild}"
  lb_public_ip = "${var.lb_public_ip}"
}