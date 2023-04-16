# Rehydrated

This project rides on the shoulders of the most lightweight ACME-compliant certificate requesting tool there is,

[dehydrated.io](https://dehydrated.io)

Go buy them a beer if you enjoy their software.


## How to use

Either use the ready-made multi-platform container image hosted at

    ghcr.io/chrisbraucker/rehydrated

and take a look at the [docker-compose.yml](./docker-compose.yml) for hints,
or use [dehydrated](github.com/dehydrated-io/dehydrated) as is and the scripts in the `hooks/` directory as hooks for dehydrated as stated in their README.

There are a handful of configuration variables that should be mentioned:

Variable                 | Default value     | Notes
-------------------------|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------
REHYDRATED_RECORD_TTL    | `60`              | DNS record TTL in seconds
REHYDRATED_RENEWAL_SLEEP | `60`              | Script sleep time between creation of DNS record and ACME verification
REHYDRATED_NODE_NAME     | `_acme-challenge` | TXT record name of the challenge
REHYDRATED_DEBUG         | `0`               | Set this to anything that is not the empty string, `0`, `FALSE`, `False`, `false`, `F` or `f` to enable debug messages in the log output


## Supported DNS providers

- [dynu.com](https://dynu.com)
- [cloudflare.com](https://cloudflare.com)


# Contributing and feature requests

This is a hobby project I maintain in my free time, mainly for the services I use and provide to friends and family.
Feel free to open an issue or file a PR with bugs or changes you'd like addressed, but don't expect me to reinvent the wheel here.

There are lots more comprehensive libraries and programs available, such as the official [certbot](https://github.com/certbot/certbot) and [lexicon](https://github.com/AnalogJ/lexicon), which provide these services in a more all-round but less resource-conserving manner.

Go check them out, they are great pieces of technology!
