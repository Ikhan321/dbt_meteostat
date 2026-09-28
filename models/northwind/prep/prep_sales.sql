with orders as (
    select * from {{ ref('staging_orders') }}
),

order_details as (
    select * from {{ ref('staging_order_details') }}
),

products as (
    select * from {{ ref('staging_products') }}
),

categories as (
    select * from {{ ref('staging_categories') }}
),

joined as (
    select
        o.order_id,
        o.customer_id,
        p.product_name,
        c.category_name,
        od.unit_price,
        od.quantity,
        od.discount,

        -- business logic: revenue
        (od.unit_price * od.quantity * (1 - od.discount)) as revenue,

        -- time dimensions
        extract(year from o.order_date) as order_year,
        extract(month from o.order_date) as order_month

    from orders o
    join order_details od using (order_id)
    join products p using (product_id)
    left join categories c using (category_id)
)

select * from joined
