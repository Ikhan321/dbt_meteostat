with source_data as (
    select *
    from {{ source('northwind_data', 'orders') }}
)
select
    orderid        as order_id,
    customerid     as customer_id,
    employeeid     as employee_id,
    orderdate::date       as order_date,
    requireddate::date    as required_date,
    shippeddate::date     as shipped_date,
    shipvia        as ship_via,
    shipcity       as ship_city,
    shipcountry    as ship_country
from source_data
