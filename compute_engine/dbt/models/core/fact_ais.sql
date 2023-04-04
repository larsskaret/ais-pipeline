{{ config(
    materialized='incremental',
    partition_by={
      "field": "timestamp",
      "data_type": "timestamp",
      "granularity": "day"
    },
    cluster_by = ["mmsi", "timestamp"],
)}}

with ais_dk_data as (
    select *
    from {{ ref('stg_ais_dk') }}
), 

country as (
    select *
    from {{ ref('country_lookup') }}
)

select 
    ais_dk_data.ais_id,
    ais_dk_data.timestamp,
    ais_dk_data.source_type,
    ais_dk_data.mmsi,
    ais_dk_data.lat,
    ais_dk_data.lon,
    ais_dk_data.loc,
    ais_dk_data.nav_status,
    ais_dk_data.rot,
    ais_dk_data.sog,
    ais_dk_data.cog,
    ais_dk_data.heading,
    ais_dk_data.imo,
    ais_dk_data.callsign,
    ais_dk_data.name,
    ais_dk_data.ship_type,
    ais_dk_data.cargo_type,
    ais_dk_data.destination,
    ais_dk_data.eta,
    country.country_name,
    
from 
    ais_dk_data
    left outer join country
    on ais_dk_data.mid = country.mid

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  where timestamp > (select max(timestamp) from {{ this }})

{% endif %}