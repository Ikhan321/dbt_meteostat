-- models/mart/mart_weather_weekly.sql
with daily as (
    select
        airport_code,
        reading_date,
        avg_temp_c,
        min_temp_c,
        max_temp_c,
        precipitation_mm,
        max_snow_mm,
        avg_wind_direction,
        avg_wind_speed_kmh,
        wind_peakgust_kmh,
        avg_pressure_hpa,
        sun_minutes
    from {{ ref('prep_weather_daily') }}
),

weekly as (
    select
        airport_code,
        date_trunc('week', reading_date)::date as week_start,

        avg(avg_temp_c) as avg_temp_c,
        min(min_temp_c) as min_temp_c,
        max(max_temp_c) as max_temp_c,

        sum(precipitation_mm) as total_precipitation_mm,
        max(max_snow_mm) as max_snow_mm,

        avg(avg_wind_direction) as avg_wind_direction,
        avg(avg_wind_speed_kmh) as avg_wind_speed_kmh,
        max(wind_peakgust_kmh) as max_wind_peakgust_kmh,

        avg(avg_pressure_hpa) as avg_pressure_hpa,
        sum(sun_minutes) as total_sun_minutes

    from daily
    group by airport_code, date_trunc('week', reading_date)
)

select *
from weekly
