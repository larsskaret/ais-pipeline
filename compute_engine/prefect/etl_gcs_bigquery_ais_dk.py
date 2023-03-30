from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp import GcpCredentials

from settings import SCHEMA_DK, COLUMN_NAMES_DK, BLOCK_GCS_BUCKET, GCS_BUCKET_LOC_DK, \
    GCS_TABLE_DK, BLOCK_GCP_CRED, GCS_PROJECT_ID

@task(retries=3)
def extract_from_gcs(year: int, month: int, day: int) -> Path:
    """Download trip data from GCS"""
    dataset_file = f"aisdk-{year}-{month:02}-{day:02}"
    gcs_path = f"{GCS_BUCKET_LOC_DK}/{year}/{month}/{dataset_file}.parquet"
    gcs_block = GcsBucket.load(BLOCK_GCS_BUCKET)

    gcs_block.get_directory(from_path=gcs_path, local_path=f"../data/")
    return Path(f"../data/{gcs_path}")



@task()
def write_bq(df: pd.DataFrame) -> None:
    """Write DataFrame to BiqQuery"""

    gcp_credentials_block = GcpCredentials.load(BLOCK_GCP_CRED)

    df.to_gbq(
        destination_table=GCS_TABLE_DK,
        project_id=GCS_PROJECT_ID,
        credentials=gcp_credentials_block.get_credentials_from_service_account(),
        chunksize=500_000,
        if_exists="append",
    )


@flow(log_prints=True)
def etl_gcs_to_bq(year: int, month: int, day: int) -> int:
    """Main E(T)L flow to load data into Big Query"""

    path = extract_from_gcs(year, month, day)
    df = pd.read_parquet(path, use_nullable_dtypes=True)
    print(df.head())
    write_bq(df)
    return len(df)

@flow(log_prints=True)
def etl_parent_flow(
    months: list[int] = [1, 2], year: int = 2021, color: str = "yellow"
):
    #rows = 0
    #for month in months:
     #   rows += etl_gcs_to_bq(year, month, color)
    #print(f"Rows: {rows}")
    etl_gcs_to_bq(2023, 1, 27)


if __name__ == "__main__":
    etl_parent_flow()