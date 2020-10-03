# DSS deployment scripts

A set of scripts that deploy [dss](http://github.com/CurioTeam/dss) to an
Ethereum chain of your choosing.

## Curio Deployment Guide

### Requirements:

* Ubuntu 18.04 LTS
* A user in the `sudoers` group

### Creating a new user

* Create a new user `adduser ubuntu`
* Add the user to `sudoers` group `usermod -aG sudo ubuntu`
* Optionally, if you don't want to enter your password each time the installation process asks, run `sudo visudo`
* Add the following line at the end of the file: `ubuntu ALL=(ALL) NOPASSWD: ALL`

### Preparing deployment environment
* Install NIX environment `curl -L https://nixos.org/nix/install | sh`
* Run this or login again to use Nix `. "$HOME/.nix-profile/etc/profile.d/nix.sh"`
* Clone this repo and cd into it `git clone https://github.com/CurioTeam/dss-deploy-scripts && cd dss-deploy-scripts`
* Drop into a Nix Bash shell with all dependency installed (will take 1-3 hours for the first run depending on your system) `nix-shell --pure`
* Use ETH v3 encoded private key and copy JSON part to `./keystore/me.json`
* Copy the password from the step above to `./keystore/pwd`

### Deploy

In the following script replace
* `0x515e7e1b2546d9e2bbe571bd3d9405bc1c4dd701` with your address encoded into ETH v3 file
* `https://kovan.infura.io/v3/your-infura-key` with a correct ETH RPC endpoint

and run the following command:

```sh
ETH_FROM=0x515e7e1b2546d9e2bbe571bd3d9405bc1c4dd701 \
ETH_PASSWORD=./keystore/pwd \
ETH_KEYSTORE=./keystore \
ETH_RPC_URL=https://kovan.infura.io/v3/your-infura-key \
TMPDIR=/tmp \
dss-deploy kovan -f ./config/custom.json
```

## Kovan Deployment

* The complete list of the deployed contracts: https://github.com/CurioTeam/dss-deploy-scripts/blob/master/out/addresses.json
* The rest of the deployment artifacts: https://github.com/CurioTeam/dss-deploy-scripts/tree/master/out

You can claim some test CT1 and MKR tokens at the faucet using etherscan.io interface. To do this go to the [faucet](https://kovan.etherscan.io/address/0xa92ece98fd547d8052f92c7c7a5a6058475a592a#writeContract) and scroll down to the `gulp` method. Specify a token address, click `Write` button and then confirm the transaction using Metamask. Use the following addresses for test tokens:
* CT1: 0xBfF814EFBd42b2c9739750876EEc0451F9Bb9555
* MKR: 0x638D3d19aF9E1AcE2944976A1A99bF01Cf2FAdAB


## Description

This repo is composed of two steps:

* Bash [scripts](/scripts) to modify the state of the base system

At the end of the first step, the addresses of deployed contracts are written to
an `out/addresses.json` file. The scripts read those addresses and use `seth`
and `dapp` to modify the deployment, using the values in `out/config.json`.

## Installing

The only way to install everything necessary to deploy is Nix. Run

```
$ nix-shell --pure
```

to drop into a Bash shell with all dependency installed.

### Ethereum node

You'll also need an Ethereum RPC node to connect to. Depending on your usecase, this
could be a local node (e.g. `dapp testnet`) or a remote one.

## Configuration

There are 2 main pieces of configuration necessary for a deployment:

* Ethereum account configuration
* Chain configuration

#### Account configuration

`seth` relies on the presence of environment variables to know which Ethereum account to
use, which RPC server to talk to, etc.

If you're using `nix-shell`, these variables are set automatically for you in
[shell.nix](./shell.nix).

But you can also configure the below variables manually:

- `ETH_FROM`: address of deployment account
- `ETH_PASSWORD`: path of account password file
- `ETH_KEYSTORE`: keystore path
- `ETH_RPC_URL`: URL of the RPC node

### Chain configuration

Some networks have a default config file at `config/<NETWORK>.json`, which will be used if non custom config values are set.
A config file can be passed via param with flag `-f` allowing to execute the script in any network (e.g. `dss-deploy testchain -f <CONFIG_FILE_PATH>`).
As other option, custom config values can be loaded as an environment variable called `DDS_CONFIG_VALUES`.
File passed by parameter overwrites the environment variable.

Below is the expected structure of such a config file:

```
{
  "description": "",
  "omniaFromAddr": "<Address being used by Omnia Service (only for testchain)>",
  "omniaAmount": "<Amount in ETH to be sent to Omnia Address (only for testchain)>",
  "pauseDelay": "<Delay of Pause contract in seconds>",
  "vat_line": "<General debt ceiling in CSC unit>",
  "vow_wait": "<Flop delay in seconds>",
  "vow_sump": "<Flop fixed bid size in CSC unit>",
  "vow_dump": "<Flop initial lot size in MKR unit>",
  "vow_bump": "<Flap fixed lot size in CSC unit>",
  "vow_hump": "<Flap Surplus buffer in CSC unit>",
  "jug_base": "<Base component of stability fee in percentage per year (e.g. 2.5)>",
  "pot_dsr": "<Csc Savings Rate in percentage per year (e.g. 2.5)>",
  "end_wait": "<Global Settlement cooldown period in seconds>",
  "esm_pit": "<Pit address to send MKR to be burnt when ESM is fired>",
  "esm_min": "<Minimum amount to trigger ESM in MKR unit>",
  "flap_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flap_ttl": "<Max time between bids in seconds>",
  "flap_tau": "<Max auction duration in seconds>",
  "flop_beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
  "flop_pad": "<Increase of lot size after `tick` in percentage (e.g. 50)>",
  "flop_ttl": "<Max time between bids in seconds>",
  "flop_tau": "<Max auction duration in seconds>",
  import: {
    "gov": "<GOV token address (if there is an existing one to import)>",
    "authority": "<Authority address (if there is an existing one to import)>",
    "proxyRegistry": "<Proxy Registry address (if there is an existing one to import)>",
    "faucet": "<Faucet address (if there is an existing one to import)>"
  },
  "tokens": {
    "<ETH|COL>": {
      "import": {
        "gem": "<Gem token address (if there is an existing one to import)>",
        "pip": "<Price feed address (if there is an existing one to import)>"
      },
      "pipDeploy": { // Only used if there is not a pip imported
        "osmDelay": "<Time in seconds for the OSM delay>",
        "type": "<median|value>",
        "price": "<Initial oracle price (only if type == "value")>",
        "signers": [
            <Set of signer addreeses (only if type == "median")>
        ]
      },
      "ilks": {
        "A": {
          "mat": "<Liquidation ratio value in percentage (e.g. 150)>",
          "line": "<Debt ceiling value in CSC unit>",
          "dust": "<Min amount of debt a CDP can hold in CSC unit>"
          "duty": "<Collateral component of stability fee in percentage per year (e.g. 2.5)>",
          "chop": "<Liquidation penalty value in percentage (e.g. 12.5)>",
          "lump": "<Liquidation Quantity in Collateral Unit>",
          "beg": "<Minimum bid increase in percentage (e.g. 5.5)>",
          "ttl": "<Max time between bids in seconds>",
          "tau": "<Max auction duration in seconds>"
        }
      }
    }
  }
}
```

## Default config files

Currently, there are default config files for 3 networks:

* a local testchain (e.g. `dapp testnet`)
* Kovan
* Mainnet

### Deploy on local testchain with default config file

`dss-deploy testchain`

It is possible to pass a value to define a testing scenario via `-c` flag (e.g. `dss-deploy testchain -c crash-bite`)

The only case currently available is:

- `crash-bite`

### Deploy on Kovan with default config file

`dss-deploy kovan`

### Deploy on Mainnet with default config file

`dss-deploy main`

### Deploy on any network passing a custom config file

`dss-deploy <NETWORK> -f <CONFIG_FILE_PATH>`

### Output

Successful deployments save their output to the following files:

- `out/addresses.json`: addresses of all deployed contracts
- `out/config.json`: copy of the configuration file used for the deployment
- `out/abi/`: JSON representation of the ABIs of all deployed contracts
- `out/bin/`: .bin and .bin-runtime files of all deployed contracts
- `out/meta/`: meta.json files of all deployed contracts
- `out/dss-<NETWORK>.log`: output log of deployment

### Helper scripts

The `auth-checker` script loads the addresses from `out/addresses.json` and the config file from `out/config.json` and verifies that the deployed authorizations match what is expected.

## Nix

To enable full reproducibility of our deployments, we use Nix.

This command will drop you in a shell with all dependencies and environment
variables definend:

```
nix-shell --pure
```

You can even run deploy scripts without having to clone this repo:

```
nix run -f https://github.com/CurioTeam/dss-deploy-scripts/tarball/master -c dss-deploy testchain
```

Dependencies are managed through a central repository referenced in
[`nix/pkgs.nix`](nix/pkgs.nix) and the main Nix expression to build this
repo is in [`default.nix`](default.nix).

## Smart Contract Dependencies

To update smart contract dependencies use `dapp2nix`:

```sh
nix-shell --pure
dapp2nix help
dapp2nix list
dapp2nix up vote-proxy <COMMIT_HASH>
```

To clone smart contract dependencies into working directory run:

```sh
dapp2nix clone-recursive contracts
```

## Additional Documentation

- `dss-deploy` [source code](https://github.com/CurioTeam/dss-deploy)
- `dss` is documented in the [wiki](https://github.com/CurioTeam/dss/wiki) and in [DEVELOPING.md](https://github.com/CurioTeam/dss/blob/master/DEVELOPING.md)

## TODO

- More cases to test scenarios for testchain script
