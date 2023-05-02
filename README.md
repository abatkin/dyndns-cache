# Simple Dynamic DNS client

**Warning:** This works for me. It's really rough, does very little error checking and isn't customizable. I'm open to PRs, as long as it still works for me. Throw it into a crontab and run however often you want.

## Requirements

* Mikrotik router
* DNS hosted with AWS Route53
* My `route53-util` and `routeros-utils` in your path

## How it works

* Using `routeros-utils`, query the router for the external IP address
* Check against cache to see if that is different from what we expected
* If necessary, use `route53-util` to update the appropriate Route53 record with the new IP address and save that address to our cache

## Configuration

The default configuration file is located at `~/.config/dyndns-settings`. You can override this by setting the environment variable `DYNDNS_SETTINGS_FILE`.

Technically, the configuration file is simply a bunch of environment variables that are sourced by the script, which also means that you could set them some other way and it will work just fine.

### Required variables

* `ROUTEROS_HOST` - Hostname or IP address of Mikrotik router
* `ROUTEROS_USERNAME` - Username with API access to router
* `ROUTEROS_PASSWORD` - Password for user
* `R53_REGION` - AWS region to use for Route53
* `R53_PROFILE` - AWS Profile to use (for loading credentials)
* `R53_DNS_NAME` - DNS record to update
* `R53_ZONE_ID` - Route53 Hosted Zone ID

### Optional Variables

* `DYNDNS_CACHE` - Cache file to store IP Address - defaults to `~/.cache/dyndns`
* `R53_TTL` - TTL of the A record to be created/updated - defaults to 60

### IAM Permissions

I run this with an IAM User that has only the following policy statements:

```
{
    "Sid": "Route53GetChange",
    "Effect": "Allow",
    "Action": [
        "route53:GetChange"
    ],
    "Resource": [
        "arn:aws:route53:::change/*"
    ]
},
{
    "Sid": "Route53Zone",
    "Effect": "Allow",
    "Action": [
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets"
    ],
    "Resource": [
        "arn:aws:route53:::hostedzone/<ZONE ID HERE>"
    ]
}
```
## Running in Docker

After building, you will need to mount an AWS credentials file, the settings file, and probably the cache file, and set the respective environment variables. For example:

```
docker container run --rm -it \
    -v ~/aws-dns-creds.txt:/root/.aws/credentials \
    -v ~/dyndns-settings.txt:/dyndns-settings.txt \
    -e DYNDNS_SETTINGS_FILE=/dyndns-settings.txt \
    -v ~/dyndns-cache:/dyndns-cache \
    -e DYNDNS_CACHE=/dyndns-cache/ip.txt \
    container:tag
```



