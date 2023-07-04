# Test Procedures

This directory outlines the procedures that test `bitcoin-core-node-builder` scripts.

## Testing for Major Code Changes

For major changes to the code or for Bitcoin Core version upgrades, perform a full test on a fresh install of:
- Ubuntu Desktop LTS running on bare metal
- Debian 12 running on a Proxmox virtual machine

[broken link](https://asdflkdsafjlkdsafjoixciouvxlkcjv.com)

## Testing for Minor Code Changes

For minor changes, each pull request should be tested on Ubuntu Desktop according to the following procedure:
```bash
test_branch_name=""
cd "${HOME}"
rm -rf "${HOME}"/{.bitcoin/,bitcoin/,bitcoin-*-linux-gnu.tar.gz}
[ -d "${HOME}"/bitcoin-core-node-builder/ ] && rm -rf "${HOME}"/bitcoin-core-node-builder/
git clone https://github.com/epiccurious/bitcoin-core-node-builder.git -b "${test_branch_name}"
"${HOME}"/bitcoin-core-node-builder/nodebuilder.sh
```
