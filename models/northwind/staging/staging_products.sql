with source_data as (
    select *
    from {{ source('northwind_data', 'products') }}
)
select
    productid      as product_id,
    productname    as product_name,
    supplierid     as supplier_id,
    categoryid     as category_id,
    unitprice::numeric as unit_price
from source_data
