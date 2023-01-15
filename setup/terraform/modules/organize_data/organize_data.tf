/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

####################################################################################
# Variables
####################################################################################
variable "project_id" {}
variable "location" {}
variable "lake_name" {}
#variable "metastore_service_name" {}
variable "project_number" {}
variable "datastore_project_id" {}

/* With Metastore
resource "null_resource" "create_lake" {
 for_each = {
    "prod-customer-source-domain/Customer - Source Domain" : "domain_type=source",
    "prod-merchant-source-domain/Merchant - Source Domain" : "domain_type=source",
    "prod-transactions-source-domain/Transactions - Source Domain" : "domain_type=source",
    "prod-transactions-consumer-domain/Credit Card Analytics - Consumer Domain" : "domain_type=consumer",
    "central-operations-domain/Central Operations Domain" : "domain_type=operations"
  }
  provisioner "local-exec" {
    command = format("gcloud dataplex lakes create --project=%s %s --display-name=\"%s\" --location=%s --labels=%s --metastore-service=%s ", 
                     var.project_id,
                     element(split("/", each.key), 0),
                     element(split("/", each.key), 1),
                     var.location,
                     each.value,
                     "projects/${var.project_id}/locations/${var.location}/services/${var.metastore_service_name}")
  }
}
*/

resource "google_dataplex_lake" "create_lakes" {
 for_each = {
    "prod-customer-source-domain/Customer - Source Domain" : "domain_type=source",
    "prod-merchant-source-domain/Merchant - Source Domain" : "domain_type=source",
    "prod-transactions-source-domain/Transactions - Source Domain" : "domain_type=source",
    "prod-transactions-consumer-domain/Credit Card Analytics - Consumer Domain" : "domain_type=consumer",
    "central-operations-domain/Central Operations Domain" : "domain_type=operations"
  }
  location     = var.location
  name         = element(split("/", each.key), 0)
  description  = element(split("/", each.key), 1)
  display_name = element(split("/", each.key), 1)

  labels       = {
    element(split("=", each.value), 0) = element(split("=", each.value), 1)
  }
  
  project = var.project_id
}

/* roles for dataplex service account in datastore project 
+ so that dataplex can read from buckets

terraform doesn't seem to allow setting IAM bindings across projects so using gcloud instead

resource "google_project_iam_member" "dataplex_service_account_owner" {
for_each = toset([
"roles/dataplex.dataReader",
"roles/dataplex.serviceAgent"])
  project  = var.datastore_project_id
  role     = each.key
  member   = format("serviceAccount:service-%s@gcp-sa-dataplex.iam.gserviceaccount.com", local._project_number)
  depends_on = [
    google_service_account.dq_service_account
  ]
}
*/


resource "null_resource" "dataplex_permissions_1" {
  provisioner "local-exec" {
    command = format("gcloud projects add-iam-policy-binding %s --member=\"serviceAccount:service-%s@gcp-sa-dataplex.iam.gserviceaccount.com\" --role=\"roles/dataplex.dataReader\"", 
                      var.datastore_project_id,
                      var.project_number)
  }

  depends_on = [google_dataplex_lake.create_lakes]
}

resource "null_resource" "dataplex_permissions_2" {
  provisioner "local-exec" {
    command = format("gcloud projects add-iam-policy-binding %s --member=\"serviceAccount:service-%s@gcp-sa-dataplex.iam.gserviceaccount.com\" --role=\"roles/dataplex.serviceAgent\"", 
                      var.datastore_project_id,
                      var.project_number)
  }

  depends_on = [null_resource.dataplex_permissions_1]
}

resource "time_sleep" "sleep_after_dataplex_permissions" {
  create_duration = "120s"
  depends_on = [
                null_resource.dataplex_permissions_1,
                null_resource.dataplex_permissions_2
              ]
}

resource "google_dataplex_zone" "create_zones" {
 for_each = {
    "customer-curated-zone/Customer Curated Zone/prod-customer-source-domain/CURATED" : "",
    "customer-raw-zone/Customer Raw Zone/prod-customer-source-domain/RAW" : "",
    "merchant-raw-zone/Merchant Raw Zone/prod-merchant-source-domain/RAW" : "",
    "merchant-curated-zone/Merchant Curated Zone/prod-merchant-source-domain/CURATED" : "",
    "merchant-data-product-zone/Merchant Data Product Zone/prod-merchant-source-domain/CURATED" : "",
    "common-utilities/Common Utilities/central-operations-domain/CURATED" : "",
    "operations-data-product-zone/Data Product Zone/central-operations-domain/CURATED" : "",
    "clearing-and-settlement-data-product-zone/Clearing and Settlement Data Product Zone/prod-transactions-source-domain/CURATED" : "",
    "clearing-and-settlements-curated-zone/Clearing and Settlements Curated Zone/prod-transactions-source-domain/CURATED" : "",
    "clearing-and-settlements-raw-zone/Clearing and Settlements Raw Zone/prod-transactions-source-domain/RAW" : "",
    "funding-curated-zone/Funding Curated Zone/prod-transactions-source-domain/CURATED" : "",
    "funding-data-product-zone/Funding Data Product Zone/prod-transactions-source-domain/CURATED" : "",
    "funding-raw-zone/Funding Raw Zone/prod-transactions-source-domain/RAW" : "",
    "transactions-curated-zone/Authorizations Curated Zone/prod-transactions-source-domain/CURATED" : "",
    "transactions-raw-zone/Authorizations Raw Zone/prod-transactions-source-domain/RAW" : ""
  }

  discovery_spec {
    enabled = true
    schedule = "0 * * * *"
  }

  lake     =  element(split("/", each.key), 2)
  location = var.location
  name     = element(split("/", each.key), 0)

  resource_spec {
    location_type = "SINGLE_REGION"
  }

  type         = element(split("/", each.key), 3)
  description  = element(split("/", each.key), 1)
  display_name = element(split("/", each.key), 1)

  project      = var.project_id

  depends_on  = [time_sleep.sleep_after_dataplex_permissions]
}

#sometimes we get API rate limit errors for dataplex; add wait until this is resolved.
resource "time_sleep" "sleep_after_zones" {
  create_duration = "60s"

  depends_on = [google_dataplex_zone.create_zones]
}

resource "google_dataplex_zone" "create_zones_with_labels" {
 for_each = {
    "customer-data-product-zone/Customer Data Product Zone/prod-customer-source-domain/CURATED" : "data_product_category=master_data",
    "data-product-zone/Data Product Zone/prod-transactions-consumer-domain/CURATED" : "data_product_category=master_data",
    "transactions-data-product-zone/Authorizations Data Product Zone/prod-transactions-source-domain/CURATED" : "data_product_category=master_data"
  }

    discovery_spec {
    enabled = true
    schedule = "0 * * * *"
  }

  lake     =  element(split("/", each.key), 2)
  location = var.location
  name     = element(split("/", each.key), 0)

  resource_spec {
    location_type = "SINGLE_REGION"
  }

  type         = element(split("/", each.key), 3)
  description  = element(split("/", each.key), 1)
  display_name = element(split("/", each.key), 1)
  labels       = {
    element(split("=", each.value), 0) = element(split("=", each.value), 1)
  }
  project      = var.project_id

  depends_on  = [time_sleep.sleep_after_zones]
}
