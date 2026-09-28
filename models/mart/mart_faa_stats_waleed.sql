WITH departures AS (
    SELECT
        origin AS faa,
        COUNT(DISTINCT dest) AS unique_departure_connections,
        COUNT(*) AS planned_departures,
        COUNT(*) FILTER (WHERE cancelled = 1) AS cancelled_departures,
        COUNT(*) FILTER (WHERE diverted = 1) AS diverted_departures,
        COUNT(*) FILTER (WHERE cancelled = 0) AS occurred_departures,
        COUNT(DISTINCT tail_number) AS unique_airplanes_departures,
        COUNT(DISTINCT airline) AS unique_airlines_departures
    FROM {{ ref('prep_flights') }}
    GROUP BY origin
),
arrivals AS (
    SELECT
        dest AS faa,
        COUNT(DISTINCT origin) AS unique_arrival_connections,
        COUNT(*) AS planned_arrivals,
        COUNT(*) FILTER (WHERE cancelled = 1) AS cancelled_arrivals,
        COUNT(*) FILTER (WHERE diverted = 1) AS diverted_arrivals,
        COUNT(*) FILTER (WHERE cancelled = 0) AS occurred_arrivals,
        COUNT(DISTINCT tail_number) AS unique_airplanes_arrivals,
        COUNT(DISTINCT airline) AS unique_airlines_arrivals
    FROM {{ ref('prep_flights') }}
    GROUP BY dest
),
combined AS (
    SELECT
        COALESCE(d.faa, a.faa) AS faa,
        COALESCE(d.unique_departure_connections, 0) AS unique_departure_connections,
        COALESCE(a.unique_arrival_connections, 0) AS unique_arrival_connections,
        COALESCE(d.planned_departures, 0) + COALESCE(a.planned_arrivals, 0) AS total_flights_planned,
        COALESCE(d.cancelled_departures, 0) + COALESCE(a.cancelled_arrivals, 0) AS total_flights_cancelled,
        COALESCE(d.diverted_departures, 0) + COALESCE(a.diverted_arrivals, 0) AS total_flights_diverted,
        COALESCE(d.occurred_departures, 0) + COALESCE(a.occurred_arrivals, 0) AS total_flights_occurred,
        ROUND((COALESCE(d.unique_airplanes_departures, 0) + COALESCE(a.unique_airplanes_arrivals, 0)) / 2.0, 2) AS avg_unique_airplanes,
        ROUND((COALESCE(d.unique_airlines_departures, 0) + COALESCE(a.unique_airlines_arrivals, 0)) / 2.0, 2) AS avg_unique_airlines
    FROM departures d
    FULL OUTER JOIN arrivals a ON d.faa = a.faa
)
SELECT
    c.faa,
    ap.name,
    ap.city,
    ap.country,
    c.unique_departure_connections,
    c.unique_arrival_connections,
    c.total_flights_planned,
    c.total_flights_cancelled,
    c.total_flights_diverted,
    c.total_flights_occurred,
    c.avg_unique_airplanes,
    c.avg_unique_airlines
FROM combined c
LEFT JOIN {{ ref('prep_airports') }} ap ON ap.faa = c.faa
ORDER BY c.faa
