variable "gcloud_region" { default = "asia-southeast1" }
variable "gcloud_zone" { default = "asia-southeast1-a" }
variable "gcloud_project" { default = "moja-box" }

variable "platform_name" { default = "moja-box" }

variable "cluster_master_auth_username" {}
variable "cluster_master_auth_password" {}

variable "cluster_node_machine_type" { default = "n1-standard-4" }
#n1-standard-4: 0.2344 in Singapore, 15GB of RAM, 4 vCPUs
#n1-highmem-4:  0.2920 in Singapore,  26GB of RAM, 4 vCPUs

variable "cluster_node_initial_count" { default = 1 }

variable "route_53_zone_id" { default = "Z1C4RYEBYQ49PR"}
variable "record_name" { default = "*.moja-box.vessels.tech"}
variable "lb_public_ip" { }
