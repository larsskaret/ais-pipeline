# AIS Data pipeline 

First thing first: I'm required to announce that I am not affiliated with the data source - The Danish Maritime Authority.

This is a data pipeline that daily retrieves zip files from a source web page and stores it in a cloud datalake and a data warehouse. The data is then transformed and prepared for presentation. Finally, the data is presented on a dashboard.

The infrastructure is created running Terraform from GitHub Codespaces. The entire infrastructure will be created running one script file (see instructions below).

The pipeline code is located on a compute engine in Google Cloud that is scheduled to be powered on a limitied amount of time every day in order to save cost. Running the code is orchestrated from Prefect Cloud.

## Context

This is the final project for the DataTalks.Club Data Engineering Zoomcamp. It's a free, practical, 10-week long course about the main concepts in Data Engineering.

https://github.com/DataTalksClub/data-engineering-zoomcamp

The project adheres to some criteria as described [here](Criteria.md).

## What is AIS?

[From wikipedia:](https://en.wikipedia.org/wiki/Automatic_identification_system)

The automatic identification system (AIS) is an automatic tracking system that uses transceivers on ships and is used by vessel traffic services (VTS). When satellites are used to receive AIS signatures, the term Satellite-AIS (S-AIS) is used. AIS information supplements marine radar, which continues to be the primary method of collision avoidance for water transport. Although technically and operationally distinct, the ADS-B system is analogous to AIS and performs a similar function for aircraft.

## Data - practical info

The data is stored as zipped csv files on the source web page. Data is available in day format from 2022 11 01. Latest data is 3-4 days old. Earlier data than November 2022 is stored per month. Data size is about 2 GB per day (unzipped). This project only allows for retrieval of daily data.

AIS data is provided by the vessels. In practice this means that the quality of the data can vary. For example the AIS sender can be made to send false positions.

Not all vessels carry an AIS sender.

## Problem description

The Danish Maritime Authority publish around 10 million AIS messages per day (3 days old data). This projects seeks to allow investigating the AIS data to better understand vessel traffic in Danish waters.

Some questions we want to answer/investigations we want to make:
1. Under what [flag](https://en.wikipedia.org/wiki/Flag_state) are the ships sailing? Show the most common flags for the current time period (ie, the data you have retrieved).
2. Choose a vessel and track it's location based on it's identification number (mmsi)
3. In the vicinity of Copenhagen, how many vessels are sending AIS messages?
4. How many vessels report carrying cargo that: *justify the prohibition of the discharge into the marine environment (Category X)*
5. Create a heat map to see the traffic density.

## Technologies

GitHub:
    - repository to host source code
    - codespaces for execution environment of IaC

Terraform: Infrastructure as Code (IaC)

prefect: Orchestration tool

python

- libs: pandas, prefect, dbt++
    
- extract data, load to Google cloud

dbt core: data build tool - transformation

Google Cloud: Google Cloud storage, BigQuery, Compute engine (VM)

Google Looker Studio: Dashboard.

## Repo content

I have divided the files into codespace and compute engine. This is perhaps a bit unorthodox, but is based on where the files will be stored when the project is up and running.

codespaces contains 
- the IaC, 
- .env.example
- a script that will run/setup almost everything that is needed for this project.

compute_engine contains 
- prefect related files - flows and block creation
- dbt project
- requirements.txt - python libs we need
- a script for the compute engine that will be automatically executed by Terraform. A compute engine is a virtual machine residing in the google cloud.

## Architecture

![arch](/assets/images/architecture.png)

## Partitioning and clustering

Depending on what we want to query, it might be we should partition and cluster with opposite columns.

We want to parition on a column we often filter on (where ...) and we want to cluster by a column we often sort by (order by ...)

If we want to track a vessel location, `where mmsi = x`, we should partition by mmsi (vessel id) and cluster by date (order by timestamp)
But we would still probably want to filter the date as well? To track a vessel within certain limits.

If we want to know the big picture at certain time, `where timestamp = x`, we should partition by timestamp and cluster by mmsi (order by mmsi).

When we partition on an integer (mmsi) we decide min, max and step. Which makes it possible to add several mmsi in the same partition. 

Since this project seeks to allow investigating the AIS data to better understand vessel traffic in Danish waters, I came to the conclusion that filtering on date would be the most common of the two. Therefore, the fact_ais table is paritioned on timestamp (day) and clustered by mmsi and timestamp.

Note: after this decision was made, the pipeline was changed to make mmsi a string data type.

## Dashboard

### Heatmap

![dash1](/assets/images/dashboard_1.png)

### Vessel tracking

![dash2](/assets/images/dashboard_2.png)

## Recreate

I have made an effort to make it easy to recreate the project. You will have to use GitHub Codespaces. (If stuck, you can reach out to me at Slack, DataTalks.Club, Lars Skaret).

1. Prerequisites/accounts you need:
    - GitHub account
    
    - [Google Cloud](https://cloud.google.com/)

        - With billing enabled and only one billing account. 
        - Not more than 4 projects linked to your billing account. This caused problems for me, but there might be a setting somewhere in Google Cloud to adjust this setting.
      
    - [Prefect Cloud](https://app.prefect.cloud/)
    
    - [Google Looker Studio](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwiEnYbz-57-AhVHQ_EDHQIUAwsQjBB6BAgNEAE&url=https%3A%2F%2Flookerstudio.google.com%2F%3Frequirelogin%3D1&usg=AOvVaw1T37z_54OF7STAOCECn7Hg)

        - Only if you want to recreate the dashboard.
    
2. Open the repo in codespace, the green Code button, then Codespaces, then plus.

![codespaces](/assets/images/codespaces.png)

3. In the codespace directory, copy or rename .env.example to .env. Feel free to change the variables, but there is a slight chance that there is a hard coded variable name somewhere that can cause problems.

4. In the .env file, add your prefect API key from prefect cloud. If you don't have one stored somewhere, you have to make a new. 

    - [Instructions](https://docs.prefect.io/ui/cloud-api-keys/)

5. In the terminal: `cd codespace`

6. Run the command `. ./init_codespace.sh` (notice the first dot)

    - You will be asked to log in to Google twice (for two different gcloud operations). Please be careful when pasting the keys as I have not addded any safety nets for failing functions.

    - You will be asked for a passphrase for an ssh key. You can use an empty one.

    - You will be asked to accept the terraform apply. I have done this so you can verify what is created. The project contains two Terraform modules/projects. The first one creates the Google Cloud projects and sets up the service accounts, APIs etc. This Terraform module uses your Google Cloud account for verficiation. The second module creates the GCS bucket, BigQuery and Compute engine. It uses a Terraform service account credentials key for verification.

    - When the script is finished, everything should be ready to run flows from prefect cloud.

    - The data source is updated every day. The prefect flow is scheduled to run 06:00 AM (Europe/Paris) every day. To save cost, the compute engine is scheduled to wake up at 05:30 AM and shut down at 06:45 AM every day.
    
    - If the script fails any of the steps, feel free to run it again, but you should clear all #Automated variables in .env. If this doesn't work, try to copy paste one command at the time from the script.

    - **Important** If you run a flow for the same day several times, the BigQuery table will be appended to with the same data.

    - **Important** The tables produced by dbt are incremental based on dates. This means that if you try to add data that is older than the existing, it will not be included. 
  
  
7. If you want to explore (or fix...) the compute engine you can use ssh. From codespaces this command should work (given the .env vars are exported):

    - `gcloud compute ssh ais@$GCP_COMPUTE_ENGINE_NAME --ssh-key-file=.ssh/google_compute_engine --project=$GCP_PROJECT_ID`

    - If the .env vars are not exported, run this from codespace dir: `set -o allexport && source .env && set +o allexport`

    - On the compute engine, the [prefect agent](https://docs.prefect.io/latest/concepts/work-pools/) runs in tmux session:

        - `tmux attach-session -t pf_session`

        - To exit session: `ctrl+b d`

        - To start a new window (shell prompt) ctrl+b c. You will then have a shell with the env vars.

8. To shut down compute engine, run `terraform apply --var=compute_status='TERMINATED'` in the terraform_gcp_resuources folder

    - To turn the compute engine back on run `terraform apply` in the same folder (defaults to 'RUNNING')

    - Since Google cloud is configured to start and stop the compute engine every day, you can shut it down when you are finished.

9. If you decided to publish the repo somewhere, double check that you don't accidentaly added any secrets to .env.example or somehow the .ssh and .JSON keys/secrets.

10. Now for the most manual part of the project, the dashboard.

    - Here is mine, you should be able to select date ranges and mmsi number.

        - https://lookerstudio.google.com/s/odf4lHd0GnE

    - If you want to go through the trouble and make your own, here are some tips:

    - You have to register to start using it.

    - Some initial guidelines: https://support.google.com/looker-studio/answer/12141699?hl=en

    - Data is coming from BigQuery.

    - I think its a good idea to copy my dashboard and work from there. I have not done this before, so can't give detailed instructions.


11. To remove everything, you can run `terraform destroy` in both terraform modules/directories (resources first and then project). 


## TIP

If you can't find your project on the GCP UI, choose the **ALL** tab.

![Tip](/assets/images/choose_project.png)

## Todo

- Improve documentation
- Prettify and improve dashboard
- Downsample data to improve dashboard maps response time?
- Fix pip wheel error
- Project somewhat rough around the edges
- Scalability
    - example: more env variables, less hard coded
- Host prefect flows on github (should be simple to achieve this)
    - and generally make it easier to develop/change the code, including dbt.
- CI/CD
- Implement testing
- Standarize variable names.
- Use Docker, more robust and scalable setup
- Configure flow to be able to not download data if data already exists
- Flows are nameed etl, but in reality it's elt...
- Prune the requirements.txt file
- And much more :)

## Data source information - licences
Contains data from the Danish Maritime Authority that is used in accordance with the conditions for the use of Danish public data.

More information: 

[Conditions for the use of data](https://dma.dk/safety-at-sea/navigational-information/download-data/conditions-for-the-use-of-data)


[AIS data management policy](https://dma.dk/safety-at-sea/navigational-information/ais-data/ais-data-management-policy-)

Data source:
https://dma.dk/safety-at-sea/navigational-information/ais-data
Direct link to data: https://web.ais.dk/aisdata/

---

*Quote*
### 3. Historical AIS data

You can get access to continuously updated historical AIS data for free. AIS data are saved as so-called CSV files. In order to be able to use historical AIS data, you must have a special application capable of handling and converting data into a user friendly presentation. 

*Quote end*

---



