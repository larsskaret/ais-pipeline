from pathlib import Path
import pandas as pd
from prefect import flow, task
from datetime import date
import datetime
from prefect_gcp.cloud_storage import GcsBucket
from random import randint
import os

from global_vars import SCHEMA_DK, COLUMN_NAMES_DK, BLOCK_GCS_BUCKET, GCS_BUCKET_LOC_DK

@task(retries=3)
def fetch(dataset_url: str) -> pd.DataFrame:
    """Read ais data from web into pandas DataFrame"""
    df = pd.read_csv(dataset_url, na_values='Unknown')
    return df

@task(log_prints=True)
def clean_col_dtype(df=pd.DataFrame) -> pd.DataFrame:
    """Clean column names and dtype"""

    df.columns = COLUMN_NAMES_DK
    df = df.astype(SCHEMA_DK)
    print(f"columns: {df.dtypes}")
    print(f"rows: {len(df)}")
    return df

@task(log_prints=True)
def write_local(df: pd.DataFrame) -> Path:
    """Write DataFrame out locally as parquet file"""

    df.to_parquet("temp.parquet", compression="snappy")
    return 1

@task()
def write_gcs(gcs_path: Path) -> None:
    """Upload local parquet file to GCS"""

    gcs_block = GcsBucket.load(BLOCK_GCS_BUCKET)
    gcs_block.upload_from_path(from_path="temp.parquet", to_path=gcs_path)
    #gcs_block.upload_from_dataframe(df, to_path = gcs_path, serialization_format='parquet_snappy')
    return
 
@flow()
def etl_web_to_gcs_ais_dk(start_date: datetime.date = date.today(), history: int = 1) -> None:
    """
    The main ETL function
    TODO: Arguments, start date and stop date
    to fetch data from.
    """
  
    h = datetime.timedelta(days=history)
    
    for i in range(history):
        #Newest data is 3 days old
        cur_date = start_date - datetime.timedelta(days=i+3)
        year = cur_date.year
        month = cur_date.month
        day = cur_date.day
    
        dataset_file = f"aisdk-{year}-{month:02}-{day:02}"
        print(dataset_file)
        dataset_url = f"https://web.ais.dk/aisdata/{dataset_file}.zip"
        #https://web.ais.dk/aisdata/aisdk-2023-01-01.zip
        gcs_path = f"{GCS_BUCKET_LOC_DK}/{year}/{month}/{dataset_file}.parquet"

        df = fetch(dataset_url)
        df_clean = clean_col_dtype(df)
        path = write_local(df_clean)
        write_gcs(gcs_path)
        os.system("rm temp.parquet")


if __name__ == "__main__":
    etl_web_to_gcs_ais_dk()