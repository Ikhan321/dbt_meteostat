-- models/mart/mart_route_stats.sql

with flights as (
    select
        origin,
        dest,
        tail_number,
        airline,
        actual_elapsed_time,
        arr_delay,
        cancelled,
        diverted
    from {{ ref('prep_flights') }}
),

airports as (
    select
        faa,
        name,
        city,
        country
    from {{ ref('prep_airports') }}
),

route_stats as (
    select
        f.origin,
        f.dest,

        -- total flights on this route
        count(*) as total_flights,

        -- unique airplanes
        count(distinct f.tail_number) as unique_airplanes,

        -- unique airlines
        count(distinct f.airline) as unique_airlines,

        -- average actual elapsed time
        avg(f.actual_elapsed_time) as avg_actual_elapsed_time,

        -- average arrival delay
        avg(f.arr_delay) as avg_arr_delay,

        -- max/min delay
        max(f.arr_delay) as max_arr_delay,
        min(f.arr_delay) as min_arr_delay,

        -- total cancelled
        sum(coalesce(f.cancelled, 0)) as total_cancelled,

        -- total diverted
        sum(coalesce(f.diverted, 0)) as total_diverted,

        -- origin airport info
        o.name  as origin_airport_name,
        o.city  as origin_city,
        o.country as origin_country,

        -- destination airport info
        d.name  as dest_airport_name,
        d.city  as dest_city,
        d.country as dest_country

    from flights f
    left join airports o
        on f.origin = o.faa
    left join airports d
        on f.dest = d.faa
    group by
        f.origin,
        f.dest,
        o.name, o.city, o.country,
        d.name, d.city, d.country
)

select *
from route_stats;
