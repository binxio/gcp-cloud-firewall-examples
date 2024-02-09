# Threat intelligence firewall example

This example denies all requests to malicious IP addresses known to Google. The exact list of addresses is not known to me, but addresses mentioned on [Project Honeypot](https://www.projecthoneypot.org/list_of_ips.php) and/or [Talos intelligence](https://www.talosintelligence.com/documents/ip-blacklist) tend to fail.

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

    Log in to the client VM:

    ```bash
    gcloud compute ssh client --tunnel-through-iap --project <project_id>
    ```

    Send a valid requests:

    ```bash
    curl https://xebia.com/
    ```

    Connect to malicious addresses using whatever tool you like :-)

## Clean up

Use Terraform to destroy the example setup.

1. Set the required Terraform variables

    [variables.tf](variables.tf)

2. Destroy the example infrastructure

    ```bash
    terraform init
    terraform destroy
    ```