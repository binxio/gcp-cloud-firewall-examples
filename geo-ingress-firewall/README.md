# Geolocation firewall example

This example uses [country codes](https://cloud.google.com/firewall/docs/firewall-policies-rule-details#geo-location-object) to allow SSH access from certain regions.


## Deployment

Use Terraform to deploy the example setup.

1. Set the required Terraform variables

    [variables.tf](variables.tf)

2. Deploy the example infrastructure

    ```bash
    terraform init
    terraform apply
    ```

3. Try it for yourself

    If you're in the Netherlands, you can login to the VM:

    ```bash
    gcloud compute ssh client --project <project_id>
    ```


## Clean up

Use Terraform to destroy the example setup.

1. Set the required Terraform variables

    [variables.tf](variables.tf)

2. Destroy the example infrastructure

    ```bash
    terraform init
    terraform destroy
    ```