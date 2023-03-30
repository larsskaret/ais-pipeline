import os

GCS_TABLE_DK = os.getenv("GCP_DATALAKE_PATH_DK")+'.'+os.getenv("GCP_BQ_TABLE_DK")#In bigquery: dateset.table
GCS_PROJECT_ID = os.getenv("GCS_PROJECT_ID")
BLOCK_GCP_CRED = os.getenv("PREFECT_GCP_CRED_BLOCK")
BLOCK_GCS_BUCKET = os.getenv("PREFECT_GCP_BUCKET_BLOCK") 
GCS_BUCKET_LOC_DK = os.getenv("GCP_DATALAKE_PATH_DK")

#Connect this to terraform somehow?
SCHEMA_DK = {
    'timestamp'     : 'datetime64[ns]',
    'source_type'   : 'string',
    'mmsi'          : 'Int64',
    'lat'           : 'float64',
    'lon'           : 'float64',
    'nav_status'    : 'string',
    'rot'           : 'float64',
    'sog'           : 'float64',
    'cog'           : 'float64',
    'heading'       : 'float64',
    'imo'           : 'Int64',
    'callsign'      : 'string',
    'name'          : 'string',
    'ship_type'     : 'string',
    'cargo_type'    : 'string',
    'width'         : 'float64',
    'length'        : 'float64',
    'pfd_type'      : 'string',
    'draught'       : 'float64',
    'destination'   : 'string',
    'eta'           : 'datetime64[ns]',
    'data_source'   : 'string',
    'a'             : 'float64',
    'b'             : 'float64',
    'c'             : 'float64',
    'd'             : 'float64'
    }

#Connect this to terraform somehow?
COLUMN_NAMES_DK = [
    'timestamp',
    'source_type',
    'mmsi',
    'lat',
    'lon',
    'nav_status',
    'rot',
    'sog',
    'cog',
    'heading',
    'imo',
    'callsign',
    'name',
    'ship_type',
    'cargo_type',
    'width',
    'length',
    'pfd_type',
    'draught',
    'destination',
    'eta',
    'data_source',
    'a',
    'b',
    'c',
    'd'
]