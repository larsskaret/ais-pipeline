# script is copied from https://github.com/discdiver/prefect-zoomcamp/blob/main/blocks/make_gcp_blocks.py
import json
import os
from prefect_gcp import GcpCredentials
from prefect_gcp.cloud_storage import GcsBucket

# alternative to creating GCP blocks in the UI
# IMPORTANT - do not store credentials in a publicly available repository!

cred_block_name = os.getenv("PREFECT_GCP_CRED_BLOCK")
bucket_block_name = os.getenv("PREFECT_GCP_BUCKET_BLOCK")
bucket_name = os.getenv("GCP_DATALAKE_BUCKET")

with open('../'+os.getenv("GCP_PREFECT_JSON_LOCATION")) as file:
    pref_cred = json.load(file)
    
credentials_block = GcpCredentials(
    service_account_info = pref_cred
)
credentials_block.save(cred_block_name, overwrite=True)


bucket_block = GcsBucket(
    gcp_credentials = GcpCredentials.load(cred_block_name),
    bucket=bucket_name,
)
bucket_block.save(bucket_block_name, overwrite=True)