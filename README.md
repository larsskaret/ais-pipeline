# Under construction!

# ais_pipeline
Data pipeline for the Datatalks.club DE Zoomcamp final project. 


If you can't find your project on the GCP UI, choose the **ALL** tab.

![Tip](/assets/images/choose_project.png)

The start script will create 

To turn off the Compute engine

```
resource "google_compute_instance" "instance_ais" {
  name         = "ais-compute-1"
  machine_type = "e2-standard-4"
  tags         = ["allow-ssh"]

  [...]

  desired_status = "TERMINATED"
}
```

To turn it back on, use RUNNING instead of terminated

