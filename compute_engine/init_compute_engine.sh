#!/bin/bash

#Workaround for slow processing triggers for man-db
sudo touch /var/lib/man-db/auto-update

sudo apt update
sudo apt -y upgrade

#.env location should come from env variable
set -o allexport && source .env && set +o allexport

sudo apt install python3.8-venv -y
#venv name should be in .env?
python3 -m venv ais-env
source ais-env/bin/activate

#Is pip installed?
sudo apt install pip -y
pip install -r requirements.txt

#Prefect
prefect cloud login -k $PREFECT_KEY

#Create blocks
python3 prefect/create_gcp_blocks.py

#prefect deployment - should connect these to github and use env vars for work queue and timezone
prefect deployment build prefect/etl_ais_dk.py:etl_ais_dk_std \
--name "etl_ais_dk" \
--work-queue default \
--cron "0 6 * * *" \
--timezone 'Europe/Paris' \
--apply

#To download data for multiple consecutive days. Should use env vars for work queue.
prefect deployment build prefect/etl_ais_dk.py:etl_ais_dk_date \
--name "etl_ais_dk_date" \
--work-queue default \
--apply

#prefect agent
tmux new-session -d -s pf_session 'prefect agent start -q default'