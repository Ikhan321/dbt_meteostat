with source_data as (
    select *
    from {{ source('northwind_data', 'order_details') }}
)
select
    order_id,
    product_id,
    unit_price::numeric,
    quantity::int,
    discount::numeric
from source_data

