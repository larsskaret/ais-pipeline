PROJECT_ID=ais-project-$RANDOM
       
while : ; do
    echo -e "[1] Create a new project (ID: ${PROJECT_ID})."
    echo -e "[2] Use an existing project. Will take you to GCP interactive mode (gcloud init)."
    echo -e "[q] Quit\n"
    read -r INPUT

    if [[ "$INPUT" == "q" ]]
    then
        echo -e "Exit\n"
        break
    elif [[ "$INPUT" == "1" ]] 
    then
        echo -e "Project id: ${PROJECT_ID}"
        echo -e "Project name: ais-project\n"
        gcloud projects create $PROJECT_ID --name="ais-project" --verbosity=none --set-as-default
        if [ $? -eq 0 ] 
        then
            echo -e "Successfully created project\n" 
            break
        else 
            echo -e "Unsuccessfull\n"
        fi
    elif [[ "$INPUT" == "2" ]] 
    then
        gcloud init
        PROJECT_ID=$(gcloud config get-value project)
        echo -e "Current project is ${PROJECT_ID}"
    else
        echo -e "Try again.\n"
    fi
done