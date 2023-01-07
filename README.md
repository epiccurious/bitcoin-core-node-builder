# Bitcoin Core Node Builder

Simplify the process of spinning up a new Bitcoin Core node.

## What (Will) This Script Do?

The script will perform the following actions:
1. Run system updates.
2. Download [Bitcoin Core](https://bitcoincore.org/en/download/`) to the home directory.
3. Verify the download using the checksums `SHA256SUMS` and signatures `SHA256SUMS.asc`.
4. Extract the tgz to `~/bitcoin/`.
5. Create a config file to run a 25 GB prune in blocksonly mode.
6. Prevent the computer from sleep, suspend, or hibernate due to inactivity. The user must first press `Enter/return` at this step to confirm.
7. Launch `bitcoin-qt`.
8. While the initial block download runs, display the percent synced (e.g. 34%) to the user.
9. After the initial block download completes, have the user press Enter to complete the script.

## Prerequisites

A fresh install of [Ubuntu Desktop](https://ubuntu.com/download/desktop).

## How to Run The Script

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
