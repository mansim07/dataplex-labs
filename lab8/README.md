# Data Profiling in Dataplex

## About

Dataplex data profiling lets you identify common statistical characteristics of the columns of your BigQuery tables. This information helps data consumers understand their data better, which makes it possible to analyze data more effectively. Dataplex also uses this information to recommend rules for data quality.

### Options for Data Profiling in Dataplex
1. Auto Data Profiling
2. User Configured Data Profiling

### Scope of this lab
User Configured Data Profiling

### Note
1. This feature is currently supported only for BigQuery tables.
2. Data profiling compute used is Google managed, so you don't need to plan for/or handle any infrastructure complexity.

### Documentation
[About](https://cloud.google.com/dataplex/docs/data-profiling-overview#limitations_in_public_preview) | 
[Practitioner's Guide](https://cloud.google.com/dataplex/docs/use-data-profiling)

### User Configured Dataplex Profiling - what's involved

| # | Step | 
| -- | :--- |
| 1 | A User Managed Service Account is needed with ```roles/dataplex.dataScanAdmin``` to run the profiling job|
| 2 | A scan profile needs to be created against a table|
| 3 | In the scan profile creation step, you can select a full scan or incremental|
| 4 | In the scan profile creation step, you can configure profiing to run on schedue or on demand|
| 5 | Profiling results are visually displayed|
| 6 | [Configure RBAC](https://cloud.google.com/dataplex/docs/use-data-profiling#datascan_permissions_and_roles) for running scan versus viewing results |

### User Configured Dataplex Profiling - what's supported
![supported](/lab8/resources/imgs/lab-profiling-01.png)



