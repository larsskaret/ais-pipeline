import os
import argparse
import pandas as pd

from datetime import date, timedelta
from pathlib import Path
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp import GcpCredentials
from prefect_dbt import DbtCoreOperation

from global_vars import BLOCK_GCS_BUCKET, COLUMN_NAMES_DK, GCS_BUCKET_LOC_DK, SCHEMA_DK, \
BLOCK_GCP_CRED, GCP_TABLE_DK, GCP_PROJECT_ID,  BQ_SCHEMA_DK

@task(retries=3)
def fetch(dataset_url: str) -> pd.DataFrame:
    """Read ais data from web into pandas DataFrame."""
    print(f"Url to download {dataset_url}")
    df = pd.read_csv(dataset_url, na_values="Unknown")
    return df


@task(log_prints=True)
def clean_col_dtype(df=pd.DataFrame) -> pd.DataFrame:
    """Clean column names and dtype."""

    df.columns = COLUMN_NAMES_DK
    df = df.astype(SCHEMA_DK)
    print(f"columns: {df.dtypes}")
    print(f"rows: {len(df)}")
    return df


@task(log_prints=True)
def write_local(df: pd.DataFrame) -> Path:
    """Write DataFrame out locally as parquet file."""
    path = Path("temp.parquet")
    df.to_parquet(path, compression="snappy")
    return path

@task()
def write_gcs(loc_path: Path, gcs_path: Path) -> None:
    """Upload local parquet file to GCS."""

    gcs_block = GcsBucket.load(BLOCK_GCS_BUCKET)
    gcs_block.upload_from_path(from_path=loc_path, to_path=gcs_path)
    return

@task(log_prints=True)
def write_bq(df: pd.DataFrame) -> None:
    """Write DataFrame to BiqQuery."""

    gcp_credentials_block = GcpCredentials.load(BLOCK_GCP_CRED)
    print(f"BigQuery destination table: {GCP_TABLE_DK}")
    df.to_gbq(
        destination_table=GCP_TABLE_DK,
        project_id=GCP_PROJECT_ID,
        credentials=gcp_credentials_block.get_credentials_from_service_account(),
        chunksize=500_000,
        if_exists="append",
        table_schema=BQ_SCHEMA_DK,
    )
    print(f"Wrote {len(df)} lines to table {GCP_TABLE_DK} for GCP prject {GCP_PROJECT_ID}.")

@task
def dbt_transform() -> None:
    """Run the dbt transformations."""

    dbt_path = f"{os.path.expanduser('~')}/{os.getenv('DBT_PROJECT_PATH')}"

    dbt_op = DbtCoreOperation(
        commands=["dbt deps", "dbt build --var 'is_test_run: false' --target 'prod'"],
        working_dir=dbt_path,
        project_dir=dbt_path,
        profiles_dir=dbt_path,
    )

    dbt_op.run()

@flow(log_prints=True)
def etl_ais_dk(year: int = 0, month: int = 0, day: int = 0) -> None:
    """Extract data from web and place it in GCS and BigQuery.
    Oldest data in day format is 2022.11.01
    Newest data is 3 or 4 days old, depending on time zone.
    Date will not be checked."""  
    #Using silly workaround. Should do a proper check. Perhaps use date format.
    if year != 0 and month != 0 and day != 0:
        dataset_file = f"aisdk-{year}-{month:02}-{day:02}"
        
        dataset_url = f"https://web.ais.dk/aisdata/{dataset_file}.zip"
        gcs_path = f"{GCS_BUCKET_LOC_DK}/{year}/{month}/{dataset_file}.parquet"

        df = fetch(dataset_url)
        df_clean = clean_col_dtype(df)
        path = write_local(df_clean)
        write_gcs(path, gcs_path)
        write_bq(df_clean)
        os.system(f"rm {path}")
        dbt_transform()

    else:
        print(f"Improper input y/m/d: {year}/{month}/{day}.")



def daterange(start_date, end_date):
    for n in range(int((end_date - start_date).days)):
        yield start_date + timedelta(n)

@flow(log_prints=True)
def etl_ais_dk_date(start_date: date = date(1,1,1), end_date: date = date(1,1,1)) -> None:
    """Specify start_date and end_date, will be checked."""

    if (start_date >= date(2022,11,1) and
        end_date <= (date.today() - timedelta(4)) and
        start_date < end_date):

        for dl_date in daterange(start_date, end_date):
            etl_ais_dk(dl_date.year, dl_date.month, dl_date.day)
    else:
        print("Day format data: Earliest date is 2022.11.01 and latest date is 4 days before today.")



@flow(log_prints=True)
def etl_ais_dk_std(dl_date: date = date(1,1,1)) -> None:
    """Extract data form 4 days ago."""
    if(dl_date == date(1,1,1)):
        dl_date = date.today() - timedelta(4)

    if dl_date < date(2022,11,1) or dl_date > (date.today() - timedelta(4)):
        print("Day format data: Earliest date is 2022.11.01 and latest date is 4 days before today.")
    else:
        etl_ais_dk(dl_date.year, dl_date.month, dl_date.day) 

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument('--dl_date', required=False, default=date(1,1,1), help='Date to download, default: 4 days before today.')
    args = parser.parse_args()
    
    etl_ais_dk_std(args.dl_date)
