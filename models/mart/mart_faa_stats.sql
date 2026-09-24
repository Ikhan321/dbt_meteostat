-- models/mart/mart_faa_stats.sql

with flights as (
    select
        origin,
        dest,
        cancelled,
        diverted,
        tail_number,
        airline
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

airport_stats as (
    select
        a.faa as airport_code,
        a.name as airport_name,
        a.city,
        a.country,

        count(distinct case when f.origin = a.faa then f.dest end) as unique_departure_connections,
        count(distinct case when f.dest = a.faa then f.origin end) as unique_arrival_connections,

        count(case when f.origin = a.faa or f.dest = a.faa then 1 end) as total_planned_flights,

        sum(case when f.origin = a.faa or f.dest = a.faa then coalesce(f.cancelled,0) end) as total_cancelled,
        sum(case when f.origin = a.faa or f.dest = a.faa then coalesce(f.diverted,0) end) as total_diverted,

        sum(
            case
                when (f.origin = a.faa or f.dest = a.faa)
                     and coalesce(f.cancelled,0)=0
                     and coalesce(f.diverted,0)=0
                then 1
            end
        ) as total_actual_flights,

        count(distinct case when f.origin = a.faa or f.dest = a.faa then f.tail_number end) as unique_airplanes,
        count(distinct case when f.origin = a.faa or f.dest = a.faa then f.airline end) as unique_airlines

    from airports a
    left join flights f
        on f.origin = a.faa or f.dest = a.faa
    group by a.faa, a.name, a.city, a.country
)

select *
from airport_stats

