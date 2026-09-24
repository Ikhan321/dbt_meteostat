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

-- split the OR join into two safe joins
flights_departures as (
    select
        a.faa as airport_code,
        f.dest as connection,
        f.cancelled,
        f.diverted,
        f.tail_number,
        f.airline
    from airports a
    join flights f
        on f.origin = a.faa
),

flights_arrivals as (
    select
        a.faa as airport_code,
        f.origin as connection,
        f.cancelled,
        f.diverted,
        f.tail_number,
        f.airline
    from airports a
    join flights f
        on f.dest = a.faa
),

combined as (
    select * from flights_departures
    union all
    select * from flights_arrivals
),

airport_stats as (
    select
        a.faa as airport_code,
        a.name as airport_name,
        a.city,
        a.country,

        count(distinct case when c.connection is not null then c.connection end) as unique_connections,

        count(*) as total_planned_flights,
        sum(coalesce(c.cancelled,0)) as total_cancelled,
        sum(coalesce(c.diverted,0)) as total_diverted,

        sum(case when coalesce(c.cancelled,0)=0 and coalesce(c.diverted,0)=0 then 1 end) as total_actual_flights,

        count(distinct c.tail_number) as unique_airplanes,
        count(distinct c.airline) as unique_airlines

    from airports a
    left join combined c
        on a.faa = c.airport_code
    group by a.faa, a.name, a.city, a.country
)

select *
from airport_stats
