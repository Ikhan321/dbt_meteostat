with source_data as (
    select *
    from {{ source('northwind_data', 'products') }}
)
select
    product_id,
    product_name,
    supplier_id,
    category_id,
    unit_price::numeric
from source_data

