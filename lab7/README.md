# Data discovery, search and Data Lineage 

In the Dataplex Discover tab:  
Step1: Use search “tag:data_product_information” . This should populate all the data products across all domains 
Step2: Search based on Dataplex lakes and Zones 
Under “Filters” → Go to “Lakes and Zones” Tab and select Customer Raw Zone to look at the raw products 
Click on on the listed entities and go to the browse through the schema and partition information
Next click “CLEAR” next to filters


To search for PII data products type below in search bar
tag:data_product_classification.is_pii=true" 

To search for data product with high data quality score
tag:data_product_quality.timeliness_score<50

To search for data products that our Master Data
tag:data_product_information.data_product_category="Master Data"

To search for data products that our Master Data	 
tag:data_product_information.data_product_geo_region:us


The input dq yaml files are located under the gcs bucket. Feel free to go update the tags in this directory especially the URLs


Data Lineage: 


Data overview 
