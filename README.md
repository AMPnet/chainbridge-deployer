# ChainBridge Deployer

List of commands to set-up ChainBridge can be found in `cb-cli-docker/deploy-bridge-contracts.sh`. This was tested on
Görli testnet only, and there were some problems with consistently deploying contracts and connecting to RPC WS API.
On other networks (Rinkeby, Kovan and Mumbai) `cb-sol-cli` was not able to deploy contracts at all - it was just hanging
indefinitely. So we should look into deploying the contracts ourselves, since output of `cb-sol-cli` is not formatted
to easily extract deployed contract addresses anyway (see `cb-cli-docker/deploy-example-out-1.txt` and
`cb-cli-docker/deploy-example-out-2.txt`). This would also mean that we don't need to use `cb-sol-cli` at all.

The steps necessary to set up asset bridging are:
- deploy bridge contract on source chain (and specify initial relayer addresses)
- deploy ERC20 handler on source chain
- deploy bridge contract on destination chain (and specify initial relayer addresses)
- deploy ERC20 handler on destination chain

Steps to register asset:
- register asset resource on source chain
- deploy mirrored asset on destination chain
- register (mirrored) asset on destination chain
- register mirrored asset as mintable/burnable
- add permissions to mint mirrored asset (give this to destination relayer(s))

Steps to run ChainBridge:
- generate JSON config from deployed bridge and handler cotnracts
- set up private keys for relayer(s)
- start ChainBridge relayer(s)

Assets can be bridged by interacting with bridge contracts on both chains.
