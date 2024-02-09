# FQDN Firewall example

This example denies all HTTP/S requests, except for traffic to `xebia.com`.

```bash
# Valid request
laurensknoll@client:~$ curl -o /dev/null -s -w "%{http_code}\n" --connect-timeout 5 https://xebia.com
200 -- HTTP OK

# Invalid request
laurensknoll@client:~$ curl -o /dev/null -s -w "%{http_code}\n" --connect-timeout 5 https://www.google.com
000 -- Connect timeout
```

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

    Send a valid request:

    ```bash
    curl https://xebia.com/
    ```

    Send an invalid request:

    ```bash
    curl https://www.google.com/
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