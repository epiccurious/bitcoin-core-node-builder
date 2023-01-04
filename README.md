# Bitcoin Core Node Builder

Simplify the process of spinning up a new Bitcoin Core node.

## What (Will) This Script Do?

The script will perform the following actions:
1. Download Bitcoin Core to the home directory from `https://bitcoincore.org/en/download/`.
2. Verify the download using with the checksums `SHA256SUMS` and signatures `SHA256SUMS.asc`.
3. Extract to `~/bitcoin/`.
4. Create a config file to prune to 25 GB and run in blocksonly mode.
5. Prevent the computer from sleep, suspend, or hibernate due to inactivity. The user must first press `Enter/return` at this step to confirm.
5. Launch `bitcoin-qt`.
6. While the initial block download runs, display the percent synced (e.g. 34%) to the user.
7. After the initial block download completes, have the user press Enter to complete the script.

## Prerequisites

The user should have a fresh install of the latest LTS version of [Ubuntu Desktop](https://ubuntu.com/download/desktop).

No additional prerequisotes.

## How to Run The Script

The script is still in development. It will be a modified version of [the RecoverMyPassphrase repo]](https://github.com/epiccurious/RecoverMyPassphrase`).