variable "project_id" {
  type        = string
  description = "project id required"
}

variable "location" {
 description = "Location/region to be used"
 default = "us-central1"
}

variable "ip_range" {
 description = "IP Range used for the network for this demo"
 default = "10.6.0.0/24"
}

/*
variable "user_ip_range" {
 description = "IP range for the user running the demo"
}
*/

variable "hive_metastore_version" {
 description = "Version of hive to be used for the dataproc metastore"
 default = "3.1.2"
}

variable "lake_name" {
  description = "Default name of the Dataplex Lake"
  default = "dataplex_enablement_lake"
}

variable "date_partition" {
  description = "Date Partition to use for Data Generator Tool"
  default = "2022-05-01"
}

variable "tmpdir" {
  description = "Temporary folder to use for Data Generator Tool"
  default = "/tmp/data"
}


/*
variable "project_name" {
 type        = string
 description = "project name in which demo deploy"
}
variable "project_number" {
 type        = string
 description = "project number in which demo deploy"
}
variable "gcp_account_name" {
 description = "user performing the demo"
}
variable "deployment_service_account_name" {
 description = "Cloudbuild_Service_account having permission to deploy terraform resources"
}
variable "org_id" {
 description = "Organization ID in which project created"
}

*/
