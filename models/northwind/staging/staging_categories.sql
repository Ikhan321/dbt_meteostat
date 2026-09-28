with source_data as (
    select *
    from {{ source('northwind_data', 'categories') }}
)
select
    category_id,
    category_name
from source_data

