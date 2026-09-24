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

airport_daily_stats as (
    select
        fd.flight_date as reading_date,
        a.faa as airport_code,
        a.name as airport_name,
        a.city,
        a.country,

        count(distinct case when fd.origin = a.faa then fd.dest end) as unique_departure_connections,
        count(distinct case when fd.dest = a.faa then fd.origin end) as unique_arrival_connections,

        count(case when fd.origin = a.faa or fd.dest = a.faa then 1 end) as total_planned_flights,

        sum(case when fd.origin = a.faa or fd.dest = a.faa then coalesce(fd.cancelled,0) end) as total_cancelled,
        sum(case when fd.origin = a.faa or fd.dest = a.faa then coalesce(fd.diverted,0) end) as total_diverted,

        sum(
            case
                when (fd.origin = a.faa or fd.dest = a.faa)
                     and coalesce(fd.cancelled,0)=0
                     and coalesce(fd.diverted,0)=0
                then 1
            end
        ) as total_actual_flights,

        count(distinct case when fd.origin = a.faa or fd.dest = a.faa then fd.tail_number end) as unique_airplanes,
        count(distinct case when fd.origin = a.faa or fd.dest = a.faa then fd.airline end) as unique_airlines

    from {{ ref('prep_airports') }} a
    left join flights_daily fd
        on fd.origin = a.faa or fd.dest = a.faa
    group by fd.flight_date, a.faa, a.name, a.city, a.country
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
),

mart as (
    select
        w.airport_code,
        w.reading_date,

        ads.unique_departure_connections,
        ads.unique_arrival_connections,
        ads.total_planned_flights,
        ads.total_cancelled,
        ads.total_diverted,
        ads.total_actual_flights,
        ads.unique_airplanes,
        ads.unique_airlines,
        ads.airport_name,
        ads.city,
        ads.country,

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
)

select *
from mart
