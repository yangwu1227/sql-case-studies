CREATE EXTERNAL TABLE IF NOT EXISTS data_mart.weekly_sales (
    week_date TIMESTAMP COMMENT 'The starting date of the sales week for each record',
    region VARCHAR(20) COMMENT "Represents the geographical area of operations within Data Mart's multi-region strategy",
    platform VARCHAR(10) COMMENT 'Indicates whether sales occurred through the retail channel or the online Shopify storefront',
    segment VARCHAR(10) COMMENT 'Categorizes customers based on demographic and age-related groupings',
    customer_type VARCHAR(10) COMMENT 'Provides additional demographic details, such as lifestyle or purchasing behavior',
    transactions INT COMMENT 'The count of unique purchases made during the corresponding sales week',
    sales DOUBLE COMMENT 'The total dollar amount of purchases made in the corresponding sales week'
) 
COMMENT 'Sales data containing weekly transaction and sales information by region, platform, segment, and customer type' 
STORED AS PARQUET LOCATION 's3://sql-case-studies/data_mart/weekly_sales/' TBLPROPERTIES (
    'classification' = 'parquet',
    'parquet.compress' = 'SNAPPY'
);
