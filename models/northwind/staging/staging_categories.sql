with source_data as (
    select *
    from {{ source('northwind_data', 'categories') }}
)
select
    categoryid   as category_id,
    categoryname as category_name
from source_data
