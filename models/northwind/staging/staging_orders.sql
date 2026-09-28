with source_data as (
    select *
    from {{ source('northwind_data', 'orders') }}
)
select
    order_id,
    customer_id,
    employee_id,
    order_date::date,
    required_date::date,
    shipped_date::date,
    ship_via,
    ship_city,
    ship_country
from source_data

