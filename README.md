# Bitcoin Core Node Builder

Create a secure Bitcoin Core node with ease.

NOTE: This code is still under development and not yet ready. Test at your own risk. You can track progress under the Minimum Viable Product milestone.

## Prerequisites

1. An active internet connection
2. A fresh install of any modern Linux distribution based on Debian, such as [Ubuntu Desktop LTS](https://ubuntu.com/tutorials/install-ubuntu-desktop)
3. curl, which you can install with `sudo apt install -y curl`

This script **does not** support macOS, 32-bit operating systems, or Arm-based hardware.

## How to Start Bitcoin Core Node Builder

Open the Terminal and run the following command:
```
/bin/bash -c "$(curl -sSL https://raw.githubusercontent.com/epiccurious/bitcoin-core-node-builder/master/nodebuilder)"
```

NOTE: This code is still under development and not yet ready. Test at your own risk. You can track progress under the Minimum Viable Product milestone.

## What Does This Script Do?

The script performs the following actions:
1. Install system updates, reboot if necessary, then install dependencies.
2. Download, validate, and extract Bitcoin Core.
3. Set a prune for Bitcoin Core based on the disk free space.
4. Create shortcuts for Bitcoin Core on the desktop and on the "Show Applications" list.
5. Start Bitcoin Core.
6. Prevent the system from sleeping, suspending, and hibernating.
7. While the initial block download proceeds, display relevant info such as the percent synced (e.g. 34%), number of blocks left, and the free disk space remaining.
8. After the initial block download completes, tell the user that the script has finished and end the script.

## Which Files Does This Script Touch?

Before launching Bitcoin Core, this script modifies the following files:
- Any files related to installing system updates and dependencies
- The Bitcoin Core tarball and extract directory
  - `~/bitcoin-*-x86_64-linux-gnu.tar.gz`
  - `~/bitcoin/`
- The Bitcoin Core configuration file
  - `~/.bitcoin/bitcoin.conf`
- Temporary support files for verifying the Bitcoin Core download
  - `~/SHA256SUMS`
  - `~/SHA256SUMS.asc`
  - `~/guix.sigs/`

## YouTube Playlist

Follow the changes to this repository on [the YouTube playlist](https://www.youtube.com/playlist?list=PL3dr_BSAPOFSaozbtQ1wZM2enpdJIY_5T).

## Acknowledgements

Inspiration for this project came from:
- [Bitcoin Core](https://github.com/bitcoin/bitcoin/graphs/contributors) Open Source project
- [Yeti Wallet](https://github.com/JWWeatherman/yeticold/graphs/contributors) Open Source project
- [Addy Yeow](https://github.com/ayeowch/)'s Open Source script [install-full-node.sh](https://bitnodes.io/install-full-node.sh)
- [Ben Westgate](https://github.com/BenWestgate)'s Open Source script [yeti.Bash](https://github.com/BenWestgate/yeti.Bash)
- [ArmanTheParman](https://github.com/armantheparman)'s Open Source script [Parmanode](https://github.com/armantheparman/parmanode)
- [402 Payment Required](https://www.youtube.com/@402PaymentRequired)'s video [Bitcoin & Lightning Server](https://www.youtube.com/watch?v=_Hrnls92TxQ)
- [StopAndDecrypt](https://stopanddecrypt.medium.com/)'s guide [Running Bitcoin & Lightning Nodes](https://stopanddecrypt.medium.com/running-bitcoin-lightning-nodes-over-the-tor-network-2021-edition-489180297d5)

## License

This project is licensed under the terms of [the MIT No Attribution license](./LICENSE).
