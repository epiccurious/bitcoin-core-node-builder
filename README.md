# Bitcoin Core Node Builder

Create a secure Bitcoin Core node with ease.

NOTE: This code is not yet ready for production.

NOTE: This code does NOT cryptographically verify signatures yet.

NOTE: This code is still under development. Test at your own risk.

## What Does This Script Do?

The script performs the following actions:
1. Install system updates and reboot if necessary.
2. Download, verify, configure, and run Bitcoin Core.
3. Prevent sleep, suspend, and hibernate mode.
4. While the initial block download completes, display relevant info including the percent synced (e.g. 34%) and free disk space left.
5. TODO: After the initial block download completes, enable Tor and I2P. (This step isn't ready yet.)
6. Tell the user that the script is finished and to press any key to close the terminal window.

## What Files Does This Script Touch?

The script modifies the following files:
- Anything affected by upgrading the system and installing dependencies
- `$HOME/*.tar.gz`, the downloaded Bitcoin Core compressed tarball
- `$HOME/bitcoin/`, a user-definable extraction directory
- `$HOME/.bitcoin/`, the default Bitcoin Core data directory
- `$HOME/.bitcoin/bitcoin.conf`, the Bitcoin Core configuration file

## Prerequisites

A fresh install of [Ubuntu Desktop](https://ubuntu.com/tutorials/install-ubuntu-desktop) with an internet connection enabled.

## How to Run The Node Builder Script

NOTE: This code is not yet ready for production.

NOTE: This code does NOT cryptographically verify signatures yet.

NOTE: This code is still under development. Test at your own risk.

1. Install git.
    ```bash
    sudo apt install -y git
    ```
2. Clone the repository.
    ```bash
    git clone https://github.com/epiccurious/bitcoin-core-node-builder.git
    ```
3. Change to the repository directory.
    ```bash
    cd bitcoin-core-node-builder/
    ```
4. Run the script.
    ```bash
    ./nodebuilder.sh
    ```
