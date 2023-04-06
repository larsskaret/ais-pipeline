# AIS Data pipeline 

First thing first: I'm required to announce that I am not affiliated with the data source - Danish Maritime Authority.

This is the final project for the DataTalks.Club Data Engineering Zoomcamp.

https://github.com/DataTalksClub/data-engineering-zoomcamp

This is a data pipeline that daily retieves data from a source and stores it in a cloud datalake and a data warehouse. The data is then transformed and prepared for presentation. Finally, the data is presented on a dashboard.

## What is AIS?

[From wikipedia](https://en.wikipedia.org/wiki/Automatic_identification_system):

The automatic identification system (AIS) is an automatic tracking system that uses transceivers on ships and is used by vessel traffic services (VTS). When satellites are used to receive AIS signatures, the term Satellite-AIS (S-AIS) is used. AIS information supplements marine radar, which continues to be the primary method of collision avoidance for water transport. Although technically and operationally distinct, the ADS-B system is analogous to AIS and performs a similar function for aircraft.

## Data - practical info

The data is stored as zipped csv files on the source web. Data is available in day format from 2022 11 01. Latest data is 3-4 days old. Earlier data then November 2022 is stored per month. Data size is about 2 GB per day (unzipped)

## Problem description

This projects seeks to allow investigating the AIS data for Denmark.

Some questions we want to answer/investigations we want to make:
1. Under what flag are the ships sailing? Show the most common flags for the current time period (ie, the data you have retrieved).
2. One a particular time period, choose a vessel and track it's location based on it's identification number (mmsi)
3. In the vicinity of Copenhagen, how many vessels are sending AIS messages?
4. How many vessels report carrying cargo that: *justify the prohibition of the discharge into the marine environment (Category X)*
5. Create a heat map to see where the the traffic is most dense.


AIS data is provided by the vessels. In practice this means that the quality of the data can vary. For example the AIS sender can be made to send false positions.

Not all vessels carry an AIS sender.



## Technologies

GitHub: host source code, and codespaces for execution environment of IaC

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

## Dashboard

### Heatmap

![dash1](/assets/images/dashboard_1.png)

### Vessel tracking

![dash2](/assets/images/dashboard_2.png)

## Recreate

I have made an effort to make it easy to recreate the project. I hope it works. You will have to use GitHub Codespaces.

1. Prerequisites/accounts you need:
    - GitHub
    
    - Google Cloud 

        - With billing enabled and only one billing account. 
        - 1-4 projects linked to your billing account (at least, I had problems with this - trial account).
      
    - Prefect Cloud
    
    - Google Looker Studio (Dashboard)
    
2. Open the repo in codespace (Green Code button) 

3. In the codespace directory, copy or rename .env.example to .env. Feel free to rename the variables, but I'm not 100 % certain there are no hard coded version of one of the variables that can cause problems.

4. In the .env file, add your prefect API key from prefect cloud. If you don't have one stored somewhere, you have to make a new. 

[Instructions](https://docs.prefect.io/ui/cloud-api-keys/)

5. Run the command `. ./init_codespace.sh` -notice the first dot

    - You will be asked to log in to google twice (for two different gcloud operations). Please be careful when pasting the keys as I have not addded any safety nets for failing functions.

    - You will be asked for a passphrase for ssh key. I can use an empty one.

    - You will be asked to accept the terraform apply. I have done this so you can verify what is created.

    - When the script is finished, everything should be ready to run flows from prefect cloud.

    - The data source is updated every day. The prefect flow is scheduled to run 06:00 AM (Europe/Paris) every day. To save cost, the compute engine is scheduled to wake up at 05:30 AM and shut down at 06:30 AM every day.

    - If you run a flow for the same day several times, the BigQuery table will be appended to with the same data.
  
  
6. If you want to explore (or fix...) the compute engine - ssh

    - `gcloud compute ssh ais@$GCP_COMPUTE_ENGINE_NAME --ssh-key-file=.ssh/google_compute_engine --project=$GCP_PROJECT_ID`

    - The agent runs in tmux session:

        - `tmux attach-session -t pf_session`

    - To exit session: `ctrl+b d`

    - To start a new window (shell prompt) ctrl+b c. You will then have a shell with the env vars.

7. To shut down compute engine, run `terraform apply --var=compute_status='TERMINATED'` in the terraform_gcp_resuources folder

    - To turn the compute engine back on run `terraform apply` in the same folder (defaults to 'RUNNING')

8. If you decided to commit and sync the repo somewhere, double check that you don't accidentaly added any secrets to .env.example or somehow the .ssh and .JSON keys/secrets 

9. Now for the most manual part of the project, the dashboard.

    - Here is mine, you should be able to select date ranges and mmsi number.

        - https://lookerstudio.google.com/s/odf4lHd0GnE

    - If you want to go through the trouble and make your own, here are some tips:

    - You have to register to start using it.

    - Some initial guidelines: https://support.google.com/looker-studio/answer/12141699?hl=en

    - Data is coming from BigQuery.

    - I think its a good idea to copy my dashboard and work from there. I have not done this before, so can't give detailed instructions.


10. To remove everything, you can run `terraform destroy` in both terraform modules/directories (resources first and then project). 


## TIP

If you can't find your project on the GCP UI, choose the **ALL** tab.

![Tip](/assets/images/choose_project.png)

## Todo and considerations

- Better documentation
- Prettify dashboard
- pip wheel error
- project somewhat rough around the edges
- Scalability
    - example: more env variables, less hard coded
- ost flows on github (should be simple to achieve this)
    - and generally make it easier to develop/change the code, including dbt.
- CI/CD
- Use Docker, more robust and scalable setup
- Configure flow to be able to not download data if data already exists
- Flows are nameed etl, but in reality it's elt...
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



