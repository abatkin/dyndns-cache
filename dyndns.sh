#!/bin/sh

DYNDNS_SETTINGS_FILE="${DYNDNS_SETTINGS_FILE:-$HOME/.config/dyndns-settings}"
if [[ ! -f "${DYNDNS_SETTINGS_FILE}" ]]; then
  echo "No settings file found at $DYNDNS_SETTINGS_FILE"
else
  echo "Loading settings from $DYNDNS_SETTINGS_FILE"
  source "${DYNDNS_SETTINGS_FILE}"
fi


DYNDNS_CACHE=${DYNDNS_CACHE:-$HOME/.cache/dyndns}

OLD_IP=
if [[ -f "${DYNDNS_CACHE}" ]]; then
  echo "Loading old IP from ${DYNDNS_CACHE}"
  OLD_IP="$(cat ${DYNDNS_CACHE})"
fi

CURRENT_IP=$(routeros-utils --host "${ROUTEROS_HOST}" --username "${ROUTEROS_USERNAME}" --password "${ROUTEROS_PASSWORD}" --command external-ip)

echo "OLD_IP=$OLD_IP"
echo "CURRENT_IP=$CURRENT_IP"

if [[ "${OLD_IP}" != "${CURRENT_IP}" ]]; then
  echo "Updating DNS"
  route53-util --region "${R53_REGION}" --profile "${R53_PROFILE}" update-record --action UPSERT --comment "updated by simple-dyndns" --name "${R53_DNS_NAME}" --type A --zone "${R53_ZONE_ID}" --value "${CURRENT_IP}" --ttl "${R53_TTL:-60}"
  if [[ $? == 0 ]]; then
    echo "Success!"
    mkdir -p "$(dirname ${DYNDNS_CACHE})"
    echo "${CURRENT_IP}" > "${DYNDNS_CACHE}"
  else
    echo "Failed!"
    exit 1
  fi
fi


