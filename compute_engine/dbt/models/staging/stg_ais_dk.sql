{{ 
    config(materialized='incremental') 
}}

select
    {{ dbt_utils.surrogate_key(['mmsi', 'timestamp', 'lat', 'lon']) }} as ais_id,
    timestamp,
    source_type,
    mmsi,
    CAST(LEFT(CAST(mmsi as string), 3) AS INT) as mid, --CAST(FLOOR(mmsi/1000000) AS INT) as mid,--
    lat,
    lon,
    CONCAT(lat, ",", lon) as loc, --ST_GEOGPOINT(lon, lat)
    nav_status,
    rot,
    sog,
    cog,
    heading,
    imo,
    callsign,
    name,
    ship_type,
    cargo_type,
    destination,
    eta,

from {{ source('staging', 'dk') }}

where
  lon > 2 and
  lon < 18 and 
  lat > 52 and
  lat < 60 and
  length(mmsi) = 9

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  where timestamp > (select max(timestamp) from {{ this }})

{% endif %}

{% if var('is_test_run', default=true) %}

  limit 1000

{% endif %}