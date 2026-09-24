-- models/mart/mart_selected_faa_stats_weather.sql
with flights_daily as (
    select
        flight_date,
        origin,
        dest,
        cancelled,
        diverted,
        tail_number,
        airline
    from {{ ref('prep_flights') }}
),

departures as (
    select
        a.faa as airport_code,
        f.flight_date,
        f.dest as connection,
        f.cancelled,
        f.diverted,
        f.tail_number,
        f.airline
    from {{ ref('prep_airports') }} a
    join flights_daily f
        on f.origin = a.faa
),

arrivals as (
    select
        a.faa as airport_code,
        f.flight_date,
        f.origin as connection,
        f.cancelled,
        f.diverted,
        f.tail_number,
        f.airline
    from {{ ref('prep_airports') }} a
    join flights_daily f
        on f.dest = a.faa
),

combined as (
    select * from departures
    union all
    select * from arrivals
),

airport_daily_stats as (
    select
        airport_code,
        flight_date as reading_date,

        count(distinct connection) as unique_connections,
        count(*) as total_planned_flights,
        sum(coalesce(cancelled,0)) as total_cancelled,
        sum(coalesce(diverted,0)) as total_diverted,
        sum(case when coalesce(cancelled,0)=0 and coalesce(diverted,0)=0 then 1 end) as total_actual_flights,

        count(distinct tail_number) as unique_airplanes,
        count(distinct airline) as unique_airlines
    from combined
    group by airport_code, flight_date
),

weather_daily as (
    select
        airport_code,
        reading_date,
        min_temp_c,
        max_temp_c,
        precipitation_mm,
        max_snow_mm,
        avg_wind_direction,
        avg_wind_speed_kmh,
        wind_peakgust_kmh
    from {{ ref('prep_weather_daily') }}
)

select
    w.airport_code,
    w.reading_date,

    ads.unique_connections,
    ads.total_planned_flights,
    ads.total_cancelled,
    ads.total_diverted,
    ads.total_actual_flights,
    ads.unique_airplanes,
    ads.unique_airlines,

    w.min_temp_c,
    w.max_temp_c,
    w.precipitation_mm,
    w.max_snow_mm,
    w.avg_wind_direction,
    w.avg_wind_speed_kmh,
    w.wind_peakgust_kmh
from weather_daily w
left join airport_daily_stats ads
    on w.airport_code = ads.airport_code
    and w.reading_date = ads.reading_date
