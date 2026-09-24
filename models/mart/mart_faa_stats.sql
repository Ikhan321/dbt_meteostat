-- models/mart/mart_faa_stats.sql

with flights as (
    select
        f.origin,
        f.dest,
        f.cancelled,
        f.diverted,
        f.tail_number,
        f.airline
    from {{ ref('prep_flights') }} f
),

airports as (
    select
        a.faa,
        a.name,
        a.city,
        a.country
    from {{ ref('prep_airports') }} a
),

airport_stats as (
    select
        a.faa as airport_code,
        a.name as airport_name,
        a.city,
        a.country,

        -- unique number of departures connections (distinct destinations)
        count(distinct case when f.origin = a.faa then f.dest end) as unique_departure_connections,

        -- unique number of arrival connections (distinct origins)
        count(distinct case when f.dest = a.faa then f.origin end) as unique_arrival_connections,

        -- total planned flights (departures & arrivals)
        count(case when f.origin = a.faa or f.dest = a.faa then 1 end) as total_planned_flights,

        -- total cancelled (departures & arrivals)
        sum(case when (f.origin = a.faa or f.dest = a.faa) then coalesce(f.cancelled, 0) end) as total_cancelled,

        -- total diverted (departures & arrivals)
        sum(case when (f.origin = a.faa or f.dest = a.faa) then coalesce(f.diverted, 0) end) as total_diverted,

        -- total actually occurred (not cancelled, not diverted)
        sum(
            case
                when (f.origin = a.faa or f.dest = a.faa)
                     and coalesce(f.cancelled, 0) = 0
                     and coalesce(f.diverted, 0) = 0
                then 1
            end
        ) as total_actual_flights,

        -- optional: unique airplanes
        count(distinct case when f.origin = a.faa or f.dest = a.faa then f.tail_number end) as unique_airplanes,

        -- optional: unique airlines
        count(distinct case when f.origin = a.faa or f.dest = a.faa then f.airline end) as unique_airlines

    from airports a
    left join flights f
        on f.origin = a.faa
        or f.dest = a.faa
    group by a.faa, a.name, a.city, a.country
)

select *
from airport_stats;
