#!/bin/bash

#Workaround for slow processing triggers for man-db
sudo touch /var/lib/man-db/auto-update

sudo apt update
sudo apt -y upgrade

cd ais_pipeline
#.env location should come from env variable
set -o allexport && source .secrets/.env && set +o allexport
echo "Here: 1"
sudo apt install python3.8-venv -y
python3 -m venv ais-env
source ais-env/bin/activate

#Is pip installed?
sudo apt install pip -y
pip install -r requirements.txt

#Prefect
prefect cloud login -k $"PREFECT_KEY"

#Create blocks
python3 create_gcp_blocks.py

#prefect deployment - should connect these to github
prefect deployment build etl_ais_dk.py:etl_ais_dk_std \
--name "etl_ais_dk" \
--work-queue $"PREFECT_QUEUE" \
--cron "0 6 * * *" \
--apply

#To download data for multiple consecutive days.
prefect deployment build etl_ais_dk.py:etl_ais_dk_date \
--name "etl_ais_dk_date" \
--work-queue $"PREFECT_QUEUE" \
--description "Call this from prefect cloud to download data for several days. Earliest 2022 11 01, latest 4 days ago." \
--apply

#prefect agent
tmux new-session -d -s pf_session 'prefect agent start -q $"PREFECT_QUEUE"'

