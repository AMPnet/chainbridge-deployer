#!/usr/bin/env bash

set -e

SRC_GATEWAY=https://rpc.goerli.mudit.blog
DST_GATEWAY=https://rpc.goerli.mudit.blog

SRC_ADDR="0x865f603F42ca1231e5B5F90e15663b0FE19F0b21"
SRC_PK="..."
DST_ADDR="0x865f603F42ca1231e5B5F90e15663b0FE19F0b21"
DST_PK="..."

GAS_PRICE=$(numfmt --from=si 1G)
SRC_TOKEN="0xaFF4481D10270F50f203E0763e2597776068CBc5"
RESOURCE_ID="0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce00"

# deploy contracts on source chain
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice $GAS_PRICE deploy --bridge --erc20Handler --relayers $SRC_ADDR --relayerThreshold 1 --chainId 0

# TODO read output based on deploy-example-out-1.txt

SRC_BRIDGE="0x9D926752133d58031Aea62D221f94Dc79Fb6E7C3"
SRC_HANDLER="0xF5109581d07B9F399012C46328A11928D606CE2F"

# configure contracts on source chain
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice $GAS_PRICE bridge register-resource --bridge $SRC_BRIDGE --handler $SRC_HANDLER --resourceId $RESOURCE_ID --targetContract $SRC_TOKEN

# deploy contracts on destination chain
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice $GAS_PRICE deploy --bridge --erc20 --erc20Handler --relayers $DST_ADDR --relayerThreshold 1 --chainId 1

# TODO read output based on deploy-example-out-2.txt

DST_BRIDGE="0x8EaCbAB14a8153b3344F9592DEC910ECe49149D1"
DST_HANDLER="0x5F35427F36086452078165AcaEe2F92e29311A16"
DST_TOKEN="0xE4c5741431334359c4654704Ba851EE3E450a16f"

# configure contracts on destination chain
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice $GAS_PRICE bridge register-resource --bridge $DST_BRIDGE --handler $DST_HANDLER --resourceId $RESOURCE_ID --targetContract $DST_TOKEN

# register token as mintable/burnable
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice $GAS_PRICE bridge set-burn --bridge $DST_BRIDGE --handler $DST_HANDLER --tokenContract $DST_TOKEN

# give permission to mint new bridged tokens
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice $GAS_PRICE erc20 add-minter --minter $DST_HANDLER --erc20Address $DST_TOKEN

# create ChainBridge config file (we must use WS/WSS for endpoints)
echo "{
  \"chains\": [
    {
      \"name\": \"Goerli\",
      \"type\": \"ethereum\",
      \"id\": \"0\",
      \"endpoint\": \"$SRC_GATEWAY\",
      \"from\": \"$SRC_ADDR\",
      \"opts\": {
        \"bridge\": \"$SRC_BRIDGE\",
        \"erc20Handler\": \"$SRC_HANDLER\",
        \"genericHandler\": \"$SRC_HANDLER\",
        \"gasLimit\": \"1000000\",
        \"maxGasPrice\": \"10000000000\"
      }
    },
    {
      \"name\": \"Rinkeby\",
      \"type\": \"ethereum\",
      \"id\": \"1\",
      \"endpoint\": \"$DST_GATEWAY\",
      \"from\": \"$DST_ADDR\",
      \"opts\": {
        \"bridge\": \"$DST_BRIDGE\",
        \"erc20Handler\": \"$DST_HANDLER\",
        \"genericHandler\": \"$DST_HANDLER\",
        \"gasLimit\": \"1000000\",
        \"maxGasPrice\": \"10000000000\"
      }
    }
  ]
}" >> config.json

# import private key (inside ChainBridge Docker container)
./bridge accounts import --privateKey $SRC_PK

### example token bridging - this should be on frontend side ###
# approve bridge to spend out tokens
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice $GAS_PRICE erc20 approve --amount 100 --erc20Address $SRC_TOKEN --recipient $SRC_HANDLER

# bridge tokens
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice $GAS_PRICE erc20 deposit --amount 100 --dest 1 --bridge $SRC_BRIDGE --recipient $DST_ADDR --resourceId $RESOURCE_ID
