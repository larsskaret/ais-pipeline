#!/bin/bash
if [[ ! -f ./startup_flag ]]; then 

    echo Installing components...
    #Python requirements
    #sudo apt update && sudo apt --yes upgrade
    #sudo apt --yes install python3-pip
    #pip3 install --user -r ./requirements --use-pep517

    
    #Install
    #Skip Anaconda? - https://docs.anaconda.com/anaconda/install/silent-mode/
    cd ..
    cd ..
    wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh

    bash Anaconda3-2022.10-Linux-x86_64.sh
 
    source .bashrc
    
    cd ais-pipeline
    conda create -n ais-env
    conda activate ais-env
    conda install pip
    pip install -r compute_engine/requirements

    #Python libraries: in requirements
    #Docker?
    #Piperider?
    #If spark: java setup

    touch ./startup_flag

fi

echo Executing program startup
#git clone?
#Not sure about this:
#prefect orion start & prefect agent start default & wait
#Perform initial EL with python code -> pandas, pyarrow, polars, spark? 
#source->bucket_raw (CSV) WHAT TO USE? wget and 
# -> bucket_pq -> bq -> bq_dbt (production?)
#dbt and prefect https://prefecthq.github.io/prefect-dbt/
#https://www.prefect.io/guide/blog/flow-of-flows-orchestrating-elt-with-prefect-and-dbt/~~


