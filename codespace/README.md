Instruction below only applies after successfully terraforming GCP project.

**To start up or shut down the compute engine from the command line**

Go to the terraform folder.
To start: `terraform apply -var="compute_status=RUNNING`
To stop:  `terraform apply -var="compute_status=TERMINATED`

**To ssh into the compute engine**

Go to codespace folder
...