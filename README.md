# Bitcoin Core Node Builder

Create a secure Bitcoin Core node with ease.

NOTE: This code is still under development and not yet ready. Test at your own risk. You can track progress under the Minimum Viable Product milestone.

## Prerequisites

1. An active internet connection
2. A fresh install of any modern Linux distribution based on Debian, such as [Ubuntu Desktop LTS](https://ubuntu.com/tutorials/install-ubuntu-desktop).

This script **does not** support macOS, 32-bit systems, or Arm-based systems.

## How to Start Bitcoin Core Node Builder

Open the Terminal and run the following command:
```
sudo apt install -y git && git clone https://github.com/epiccurious/bitcoin-core-node-builder.git && bitcoin-core-node-builder/nodebuilder.sh
```

NOTE: This code is still under development and not yet ready. Test at your own risk. You can track progress under the Minimum Viable Product milestone.

## What Does This Script Do?

The script performs the following actions:
1. Install system updates and reboot if necessary.
2. Download, cryptographically validate, configure, and run Bitcoin Core.
3. Create a shortcut to Bitcoin Core on the desktop.
4. Prevent system sleep, suspend, and hibernate.
5. While the initial block download completes, display relevant info including the percent synced (e.g. 34%) and free disk space left.
6. TODO: After the initial block download completes, enable Tor and I2P. (This step isn't ready yet.)
7. After the initial block download completes, tell the user that the script is finished and to press any key to close the terminal window.

## What Files Does This Script Touch?

The script modifies the following files:
- Anything affected by upgrading the system and installing dependencies
- `$HOME/bitcoin-*-x86_64-linux-gnu.tar.gz`, the downloaded Bitcoin Core compressed tarball
- `$HOME/SHA256SUMS`, the tarball's checksum file
- `$HOME/SHA256SUMS.asc`, the signatures for the checksum file
- `$HOME/guix.sigs/`, 
- `$HOME/bitcoin/`, a user-definable extraction directory
- `$HOME/.bitcoin/`, the default Bitcoin Core data directory
- `$HOME/.bitcoin/bitcoin.conf`, the Bitcoin Core configuration file

## Acknowledgements

Inspriation for this project came from:
- [Bitcoin Core](https://github.com/bitcoin/bitcoin/graphs/contributors) Open Source project
- [Yeti Wallet](https://github.com/JWWeatherman/yeticold/graphs/contributors) Open Source project
- [Addy Yeow](https://github.com/ayeowch/)'s Open Source script [install-full-node.sh](https://bitnodes.io/install-full-node.sh)
- [Ben Westgate](https://twitter.com/BenWestgate_)'s Open Source script [yeti.Bash](https://github.com/BenWestgate/yeti.Bash)
- [402 Payment Required](https://twitter.com/402PaymentReq)'s video [Bitcoin & Lightning Server](https://www.youtube.com/watch?v=_Hrnls92TxQ)
- [StopAndDecrypt](https://twitter.com/StopAndDecrypt)'s guide [Running Bitcoin & Lightning Nodes](https://stopanddecrypt.medium.com/running-bitcoin-lightning-nodes-over-the-tor-network-2021-edition-489180297d5)
