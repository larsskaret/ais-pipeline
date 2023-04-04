import os

GCP_TABLE_DK = os.getenv("GCP_BQ_DATASET")+'.'+os.getenv("GCP_BQ_TABLE_DK")#In bigquery: dataset.table
GCP_PROJECT_ID = os.getenv("GCP_PROJECT_ID")
BLOCK_GCP_CRED = os.getenv("PREFECT_GCP_CRED_BLOCK")
BLOCK_GCS_BUCKET = os.getenv("PREFECT_GCP_BUCKET_BLOCK") 
GCS_BUCKET_LOC_DK = os.getenv("GCP_DATALAKE_PATH_DK")

#Connect this to terraform somehow?
SCHEMA_DK = {
    'timestamp'     : 'datetime64[ns]',
    'source_type'   : 'string',
    'mmsi'          : 'string',
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

BQ_SCHEMA_DK = [
    {'name':'timestamp',     'type': 'datetime'},
    {'name':'source_type',   'type': 'string'},
    {'name':'mmsi',          'type': 'string'},
    {'name':'lat',           'type': 'float64'},
    {'name':'lon',           'type': 'float64'},
    {'name':'nav_status',    'type': 'string'},
    {'name':'rot',           'type': 'float64'},
    {'name':'sog',           'type': 'float64'},
    {'name':'cog',           'type': 'float64'},
    {'name':'heading',       'type': 'float64'},
    {'name':'imo',           'type': 'int64'},
    {'name':'callsign',      'type': 'string'},
    {'name':'name',          'type': 'string'},
    {'name':'ship_type',     'type': 'string'},
    {'name':'cargo_type',    'type': 'string'},
    {'name':'width',         'type': 'float64'},
    {'name':'length',        'type': 'float64'},
    {'name':'pfd_type',      'type': 'string'},
    {'name':'draught',       'type': 'float64'},
    {'name':'destination',   'type': 'string'},
    {'name':'eta',           'type': 'datetime'},
    {'name':'data_source',   'type': 'string'},
    {'name':'a',             'type': 'float64'},
    {'name':'b',             'type': 'float64'},
    {'name':'c',             'type': 'float64'},
    {'name':'d',             'type': 'float64'}
    ]
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