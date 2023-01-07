# Bitcoin Core Node Builder

Spin up a secure Bitcoin Core node with ease.

## What Does This Script Do?

The script will perform the following actions:
1. Run system updates.
2. Download, verify, and extract [Bitcoin Core](https://bitcoincore.org/en/download/`).
3. Create a config file to run a 25 GB prune in blocksonly mode.
4. Prevent the computer from sleep, suspend, or hibernate due to inactivity. The user must first press `Enter/return` at this step to confirm.
5. Launch `bitcoin-qt`.
6. While the initial block download runs, display the percent synced (e.g. 34%) to the user.
7. After the initial block download completes, have the user press Enter to complete the script.

## What Files Does the Script Touch?

The script modifies the following files:
- Anything affected by standard system upgrades or by installing the dependencies
- The Bitcoin Core compressed tarball: `$HOME/*.tar.gz`,
- A user-definable extract directory:  `$HOME/bitcoin/`
- The Bitcoin Core configuration file: `$HOME/.bitcoin/bitcoin.conf`
- Standard required Bitcoin Core data: `$HOME/.bitcoin/`

## Prerequisites

A fresh install of [Ubuntu Desktop](https://ubuntu.com/download/desktop) with an internet connection enabled.

## How to Run The Node Downloader Script

1. Clone the repo.
    ```bash
    git clone https://github.com/epiccurious/bitcoin-core-node-builder.git
    ```
2. Change directories into the repo.
    ```bash
    cd bitcoin-core-node-builder/
    ```
3. Run the script.
    ```bash
    ./nodedownloader.sh
    ```
