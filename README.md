# Bitcoin Core Node Builder

Create a secure Bitcoin Core node with ease.

## What Does This Script Do?

The script performs the following actions:
1. Install system updates and reboot if necessary.
2. Download, verify, configure, and start Bitcoin Core.
3. Prevent sleep, suspend, and hibernate mode.
4. While the initial block download completes, display relevant info including the percent synced (e.g. 34%) and free disk space left.
5. After the initial block download completes, have the user press Enter/return to complete the script.

## What Files Does This Script Touch?

The script modifies the following files:
- Anything affected by standard system upgrades and dependencies
- `$HOME/*.tar.gz`, the Bitcoin Core compressed tarball
- `$HOME/bitcoin/`, a user-definable extraction directory
- `$HOME/.bitcoin/bitcoin.conf`, the Bitcoin Core configuration file
- `$HOME/.bitcoin/`, the default Bitcoin Core data directory

## Prerequisites

A fresh install of [Ubuntu Desktop](https://ubuntu.com/download/desktop) with an internet connection enabled.

## How to Run The Node Downloader Script

1. Clone the repository.
    ```bash
    git clone https://github.com/epiccurious/bitcoin-core-node-builder.git
    ```
2. Change to the repository directory.
    ```bash
    cd bitcoin-core-node-builder/
    ```
3. Run the script.
    ```bash
    ./nodebuilder.sh
    ```
