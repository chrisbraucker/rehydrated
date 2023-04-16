#!/usr/bin/env bash
# -*- coding: utf8 -*-

# rehydrated by chrisbraucker
#
# This script is licensed under The MIT License (see LICENSE for more information).

set -o errtrace
set -o errexit
set -o nounset
set -o pipefail

# Endpoints, in printf format
API='https://api.dynu.com/v2'
DOMAINS_EP="$API/dns"
RECORDS_EP="$DOMAINS_EP/%s/record"
RECORD_EP="$RECORDS_EP/%s"

source "functions"

# configuration defined in `./functions`
#RECORD_TTL
#RENEWAL_SLEEP
#RECORD_NODE_NAME
#DEBUG


deploy_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    if [[ -z "$DOMAIN" || -z "$TOKEN_FILENAME" || -z "$TOKEN_VALUE" ]]; then
      log "deploy_challenge" "At least one required input is empty"
      if debugging; then
        [[ -z "$TOKEN_VALUE" ]] && log "deploy_challenge" "DEBUG: \$TOKEN_VALUE is empty"
        [[ -z "$TOKEN_FILENAME" ]] && log "deploy_challenge" "DEBUG: \$TOKEN_FILENAME is empty"
        [[ -z "$DOMAIN" ]] && log "deploy_challenge" "DEBUG: \$DOMAIN is empty"
      fi
      exit 1
    fi

    if [[ -z "$API_KEY" ]]; then
      log "deploy_challenge" "Required Environment Variable \$API_KEY is missing"
      exit 1
    fi

    log "deploy_challenge" "DOMAIN: $DOMAIN"
    if debugging; then log "deploy_challenge" "TOKEN: $TOKEN_VALUE"; fi

    # get the domain ID
    domainData=$(curl -sS -XGET "$DOMAINS_EP" \
                 -H 'Accept: application/json' \
                 -H "API-Key: $API_KEY" \
                 | jq ".domains[] | select(.name==\"$DOMAIN\")")
    domainId=$(echo "$domainData" | jq ".id")

    if debugging; then log "deploy_challenge" "Resolved DomainID: $domainId"; fi

    # create a record
    # shellcheck disable=SC2059
    RECORDS_PATH=$(printf "$RECORDS_EP" "$domainId")
    DATA="{
    \"nodeName\": \"$RECORD_NODE_NAME\",
    \"recordType\": \"TXT\",
    \"ttl\": $RECORD_TTL,
    \"state\": true,
    \"textData\": \"$TOKEN_VALUE\"
    }"

    log "deploy_challenge" "POST $RECORDS_PATH"
    if debugging; then log "deploy_challenge" "DEBUG: DATA ($DATA)"; fi

    recordId=$(curl -sS -XPOST "$RECORDS_PATH" \
                 -H 'Accept: application/json' \
                 -H "API-Key: $API_KEY" \
                 --data "$DATA" \
                 | jq '.id')
    echo -n "$recordId" > "$TOKEN_FILENAME.txt"

    if debugging; then log "deploy_challenge" "Created '$TOKEN_FILENAME.txt' and wrote Record: $recordId"; fi

    log "deploy_challenge" "Sleeping for $((RECORD_TTL + RENEWAL_SLEEP)) seconds"
    sleep $((RECORD_TTL + RENEWAL_SLEEP))
    log "deploy_challenge" "Done."
}

clean_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    if [[ -z "$DOMAIN" || -z "$TOKEN_FILENAME" || -z "$TOKEN_VALUE" ]]; then
      log "clean_challenge" "At least one required input is empty"
      if debugging; then
        [[ -z "$TOKEN_VALUE" ]] && log "clean_challenge" "DEBUG: \$TOKEN_VALUE is empty"
        [[ -z "$TOKEN_FILENAME" ]] && log "clean_challenge" "DEBUG: \$TOKEN_FILENAME is empty"
        [[ -z "$DOMAIN" ]] && log "clean_challenge" "DEBUG: \$DOMAIN is empty"
      fi
      exit 1
    fi

    if [[ -z "$API_KEY" ]]; then
      log "deploy_challenge" "Required Environment Variable \$API_KEY is missing"
      exit 1
    fi

    # get the record ID from file
    recordId=$(cat "$TOKEN_FILENAME.txt")

    log 'clean_challenge' "DOMAIN: $DOMAIN"
    if debugging; then log 'clean_challenge' "From '$TOKEN_FILENAME.txt' read Record: $recordId"; fi

    # get the domain ID
    domainId=$(curl -sS -XGET "$DOMAINS_EP" \
                 -H 'Accept: application/json' \
                 -H "API-Key: $API_KEY" \
                 | jq ".domains[] | select(.name==\"$DOMAIN\").id")

    if debugging; then log 'clean_challenge' "Resolved DomainId: $domainId"; fi

    # delete the record
    # shellcheck disable=SC2059
    RECORD_PATH=$(printf "$RECORD_EP" "$domainId" "$recordId")
    log 'clean_challenge' "DELETE $RECORD_PATH"
    output=$(curl -sS -XDELETE "$RECORD_PATH" \
                  -H 'Accept: application/json' \
                  -H "API-Key: $API_KEY")
    if debugging; then log 'clean_challenge' "Deleted Record: $recordId, returned: $output"; fi
    rm "$TOKEN_FILENAME.txt"
    if debugging; then log 'clean_challenge' "Removed '$TOKEN_FILENAME.txt'"; fi
    log "clean_challenge" "Done."
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge)$ ]]; then
  "$HANDLER" "$@"
else
  if debugging; then log "main" "got unused command '$HANDLER'"; fi
fi
