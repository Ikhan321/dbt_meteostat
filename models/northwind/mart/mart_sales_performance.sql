with sales as (
    select * from {{ ref('prep_sales') }}
)

select
    order_year,
    order_month,
    category_name,

    sum(revenue) as total_revenue,
    count(distinct order_id) as total_orders,
    avg(revenue) as avg_revenue_per_order

from sales
group by 1, 2, 3
order by category_name, order_year, order_month
