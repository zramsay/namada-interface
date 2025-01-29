#!/bin/bash

set -e

RECORD_FILE=tmp.rf.$$
CONFIG_FILE=`mktemp`

rcd_name=$(jq -r '.name' package.json | sed 's/null//' | sed 's/^@//')
rcd_app_version=$(jq -r '.version' package.json | sed 's/null//')

cat <<EOF > "$CONFIG_FILE"
services:
  registry:
    rpcEndpoint: '${CERC_REGISTRY_RPC_ENDPOINT:-http://testnet-a-1.dev.vaasl.io:26657}'
    gqlEndpoint: '${CERC_REGISTRY_GQL_ENDPOINT:-http://testnet-a-1.dev.vaasl.io:9473/api}'
    chainId: ${CERC_REGISTRY_CHAIN_ID:-laconic-08062024}
    gas: 900000
    fees: 900000alnt
EOF

if [ -z "$CERC_REGISTRY_APP_LRN" ]; then
  authority="vaasl"
  app=$(echo "$rcd_name" | cut -d'/' -f2-)
  CERC_REGISTRY_APP_LRN="lrn://$authority/applications/$app"
fi

# Get payment address for deployer
paymentAddress=$(laconic -c $CONFIG_FILE registry name resolve "$DEPLOYER_LRN" | jq -r '.[0].attributes.paymentAddress')
paymentAmount=$(laconic -c $CONFIG_FILE registry name resolve "$DEPLOYER_LRN" | jq -r '.[0].attributes.minimumPayment' | sed 's/alnt//g')
# Pay deployer if paymentAmount is not null
if [[ -n "$paymentAmount" && "$paymentAmount" != "null" ]]; then
  payment=$(laconic -c $CONFIG_FILE registry tokens send --address "$paymentAddress" --type alnt --quantity "$paymentAmount" --user-key "$CERC_REGISTRY_USER_KEY" --bond-id "$CERC_REGISTRY_BOND_ID")

  # Extract the transaction hash
  txHash=$(echo "$payment" | jq -r '.tx.hash')
  echo "Paid deployer with txHash as $txHash"

else
  echo "Payment amount is null; skipping payment."
fi

# Generate application-deployment-request.yml
cat <<EOF | sed '/.*: ""$/d' > "$RECORD_FILE"
record:
  type: ApplicationDeploymentRequest
  version: '1.0.0'
  name: "$rcd_name@$rcd_app_version"
  application: "$CERC_REGISTRY_APP_LRN@$rcd_app_version"
  deployer: $DEPLOYER_LRN
  dns: $CERC_REGISTRY_DEPLOYMENT_HOSTNAME
  config:
    env:
      LACONIC_HOSTED_CONFIG_laconicd_chain_id: laconic-testnet-2
  meta:
    note: "Added by CI @ `date`"
    repository: "`git remote get-url origin`"
    repository_ref: "${GITHUB_SHA:-`git log -1 --format="%H"`}"
  payment: $txHash
EOF


cat $RECORD_FILE
RECORD_ID=$(laconic -c $CONFIG_FILE registry record publish \
  --filename $RECORD_FILE \
  --user-key "${CERC_REGISTRY_USER_KEY}" \
  --bond-id ${CERC_REGISTRY_BOND_ID} | jq -r '.id')
echo $RECORD_ID

rm -f $RECORD_FILE $CONFIG_FILE

