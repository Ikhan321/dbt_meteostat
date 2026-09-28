with source_data as (
    select *
    from {{ source('northwind_data', 'order_details') }}
)
select
    orderid      as order_id,
    productid    as product_id,
    unitprice::numeric as unit_price,
    quantity::int      as quantity,
    discount::numeric  as discount
from source_data
