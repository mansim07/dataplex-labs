
#!/bin/bash

# Addig a comment

source ~/.profile

gcloud config set project ${PROJECT_DATASTO}

 gcloud auth activate-service-account.

export partition_date='2022-12-01'

# --destination_table=myDataset.myTable \

bk mk \
--table \
--description "This is a table customer refined data. Native raw from Source. No Data Transformations" \
'${PROJECT_DATASTO}'.customer_refined_data.customers_data \
  client_id:STRING,
  ssn STRING,
  first_name STRING,
  last_name STRING,
  gender STRING,
  street STRING,
  city STRING,
  state STRING,
  zip INT64,
  latitude FLOAT64,
  longitude FLOAT64,
  city_pop INT64,
  job STRING, \
  dob STRING, \
  email STRING, \
  phonenum STRING, \
  profile STRING, \
  dt STRING, \
  ingest_date DATE \




bq query --use_legacy_sql=false \

'CREATE TABLE IF NOT EXISTS `'${PROJECT_DATASTO}'.customer_refined_data.customers_data`
(
  client_id STRING,
  ssn STRING,
  first_name STRING,
  last_name STRING,
  gender STRING,
  street STRING,
  city STRING,
  state STRING,
  zip INT64,
  latitude FLOAT64,
  longitude FLOAT64,
  city_pop INT64,
  job STRING,
  dob STRING,
  email STRING,
  phonenum STRING,
  profile STRING,
  dt STRING,
  ingest_date DATE
)
PARTITION BY ingest_date'


CREATE TABLE IF NOT EXISTS `${PROJECT_DATASTO}.customer_data_product.customer_data`
(
  client_id STRING,
  ssn STRING,
  first_name STRING,
  middle_name INT64,
  last_name STRING,
  dob DATE,
  gender STRING,
  address_with_history ARRAY<STRUCT<status STRING, street STRING, city STRING, state STRING, zip_code INT64, WKT GEOGRAPHY, modify_date INT64>>,
  phone_num ARRAY<STRUCT<primary STRING, secondary INT64, modify_date INT64>>,
  email ARRAY<STRUCT<status STRING, primary STRING, secondary INT64, modify_date INT64>>, 
  ingest DATE
)



CREATE TABLE IF NOT EXISTS  `${PROJECT_DATASTO}.customer_data_product.tokenized_customer_data`
(
  client_id STRING,
  ssn STRING,
  first_name STRING,
  middle_name INT64,
  last_name STRING,
  dob STRING,
  gender STRING,
  address_with_history ARRAY<STRUCT<status STRING, street STRING, city STRING, state STRING, zip_code STRING, WKT STRING, modify_date INT64>>,
  phone_num ARRAY<STRUCT<primary STRING, secondary INT64, modify_date INT64>>,
  email ARRAY<STRUCT<status STRING, primary STRING, secondary INT64, modify_date INT64>>,
  ingest_date DATE
)




CREATE TABLE IF NOT EXISTS  `${PROJECT_DATASTO}.customer_refined_data.{input_tbl_cc_cust}`
  (
  cc_number INT64,
  cc_expiry STRING,
  cc_provider STRING,
  cc_ccv INT64,
  cc_card_type STRING,
  client_id STRING,
  token STRING,
  dt STRING,
  ingest_date DATE )
PARTITION BY
  ingest_date
OPTIONS(
  partition_expiration_days=365,
  require_partition_filter=false
)



CREATE TABLE IF NOT EXISTS  `${PROJECT_DATASTO}.customer_data_product.cc_customer_data`
(
  cc_number INT64,
  cc_expiry STRING,
  cc_provider STRING,
  cc_ccv INT64,
  cc_card_type STRING,
  client_id STRING,
  token STRING,
  ingest_date DATE )


INSERT INTO
  `${PROJECT_DATASTO}.customer_data_product.customer_data`
SELECT
  client_id AS client_id,
  ssn AS ssn,
  first_name AS first_name,
  NULL AS middle_name,
  last_name AS last_name,
  PARSE_DATE("%F",
    dob) AS dob,
    gender,
  [STRUCT('current' AS status,
    cdd.street AS street,
    cdd.city,
    cdd.state,
    cdd.zip AS zip_code,
    ST_GeogPoint(cdd.latitude,
      cdd.longitude) AS WKT,
    NULL AS modify_date)] AS address_with_history,
  [STRUCT(cdd.phonenum AS primary,
    NULL AS secondary,
    NULL AS modify_date)] AS phone_num,
  [STRUCT('current' AS status,
    cdd.email AS primary,
    NULL AS secondary,
    NULL AS modify_date)] AS email,
  ingest_date AS ingest_date
FROM (
  SELECT
    * EXCEPT(rownum)
  FROM (
    SELECT
      *,
      ROW_NUMBER() OVER (PARTITION BY client_id, ssn, first_name, last_name, gender, street, city, state, zip, city_pop, job, dob, email, phonenum, profile ORDER BY client_id ) rownum
    FROM
      `${PROJECT_DATASTO}.customer_refined_data.customers_data`
    WHERE
      ingest_date='${partition_date}' )
  WHERE
    rownum = 1 ) cdd;



INSERT INTO  `${PROJECT_DATASTO}.customer_private.customer_keysets`
SELECT 
client_id as client_id,
  ssn as ssn,
  first_name  as first_name,
  last_name as last_name,
  gender as gender,
  street as street,
  city as city,
  state as state,
  zip as zip,
  latitude as latitude,
  longitude as longitude,
  city_pop as city_pop,
  job as job,
  PARSE_DATE("%F",dob) as dob,
  email as email,
  phonenum as phonenum,
KEYS.NEW_KEYSET('AEAD_AES_GCM_256') AS keyset ,
ingest_date  as ingest_date

FROM
( SELECT 
distinct client_id ,
  ssn ,
  first_name ,
  last_name ,
  gender ,
  street ,
  city ,
  state ,
  zip ,
  latitude ,
  longitude ,
  city_pop ,
  job ,
  dob ,
  email ,
  phonenum ,
  profile,
  ingest_date
  from 
  `${PROJECT_DATASTO}.customer_refined_data.customers_data` where ingest_date='${partition_date}') cdd
  ;




INSERT INTO  `${PROJECT_DATASTO}.customer_data_product.tokenized_customer_data`
SELECT
  TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(client_id as String)))  AS client_id,
  TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(ssn  as String)) ) AS ssn,
  TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(first_name as String)) ) AS first_name,
  NULL AS middle_name,
  TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(last_name  as String)) ) AS last_name,
  TO_BASE64 (AEAD.ENCRYPT(keyset,'dummy_value',cast(dob as String)) ) AS dob,
  TO_BASE64 (AEAD.ENCRYPT(keyset,'dummy_value',cast(gender as String)) ) as gender,
  [STRUCT('current' AS status,
    TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(cdk.street as String)) ) AS street,
    TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(cdk.city as String)) ) AS city,
    TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(cdk.state  as String)) ) AS state,
    TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(cdk.zip as String)) ) AS zip_code,
    TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(ST_GEOHASH(ST_GeogPoint(cdk.latitude, cdk.longitude))  as String)) ) as WKT,
    null AS modify_date)] AS address_with_history,
  [STRUCT( TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(cdk.phonenum  as String)) ) AS primary,
    NULL AS secondary,
    NULL AS modify_date)] AS phone_num,
  [STRUCT('current' AS status,
    TO_BASE64(AEAD.ENCRYPT(keyset,'dummy_value',cast(cdk.email  as String)) ) AS primary,
    NULL AS secondary,
    NULL AS modify_date)] AS email,
      ingest_date as ingest_date

FROM
`${PROJECT_DATASTO}.customer_private.customer_keysets` cdk where ingest_date='${partition_date}';
"""

CC_CUST_DATA = f"""
INSERT INTO  `${PROJECT_DATASTO}.customer_data_product.cc_customer_data`
SELECT 
  cc_number ,
  cc_expiry ,
  cc_provider ,
  cc_ccv ,
  cc_card_type ,
  client_id ,
  token ,
  ingest_date 
  from 
  `${PROJECT_DATASTO}.customer_refined_data.{input_tbl_cc_cust}`
where 
ingest_date='${partition_date}';

