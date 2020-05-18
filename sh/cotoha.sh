#!/bin/sh

# dnf install -y jq

CLIENT_ID="clientId"
CLIENT_SECRET="clientSecret"

get_access_token() {
  local HEADER="Content-Type: application/json"
  local URL="https://api.ce-cotoha.com/v1/oauth/accesstokens"
  local BODY='{"grantType":"client_credentials","clientId":"'${CLIENT_ID}'","clientSecret":"'${CLIENT_SECRET}'"}'

  RES=$(curl -s -X POST -H "${HEADER}" -d $BODY $URL)
  access_token=$(echo $RES | jq ".access_token")

  echo $access_token | sed "s/\"//g"
}

similarity() {
  s1=$1
  s2=$2
  type=$3
  dic_type=$4
  access_token=$(get_access_token)

  local HEADER1="Content-Type: application/json;charset=UTF-8"
  local HEADER2="Authorization: Bearer ${access_token}"
  local URL="https://api.ce-cotoha.com/api/dev/nlp/v1/similarity"
  local BODY='{"s1":"'${s1}'","s2":"'${s2}'","type":"'${type}'","dic_type":"'${dic_type}'"}'

  RES=$(curl -s -X POST -H "${HEADER1}" -H "${HEADER2}" -d "${BODY}" $URL)

  echo $RES
}

similarity $@
