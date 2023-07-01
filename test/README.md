# Test Procedures

This directory outlines the procedures that test `bitcoin-core-node-builder` scripts.

## Automated Validation for Code Changes

Before opening pull requests, the new code should be validated against two third-party shell tools.

Add the tools to your environment with:
```bash
sudo apt install -y shellcheck shfmt
```

### How to Use shellcheck

To validate changes against `shellcheck`, run the following command:
```bash
shellcheck ~/Documents/GitHub/bitcoin-core-node-builder/nodebuilder
```

### How to Use shfmt

To validate changes against `shellcheck`, run the following command:
```bash
shfmt -i 2 -sr -d ~/Documents/GitHub/bitcoin-core-node-builder/nodebuilder
```

## Manual Testing for Code Changes

During the review period, open pull requests should be manually tested to ensure:
1. The change actually fixes the issue
2. The change doesn't cause unintentional bugs

### Major Code Changes

For major changes to the code or for Bitcoin Core version upgrades, perform a full test on a fresh install of:
- Ubuntu Desktop LTS running on bare metal
- Debian 12 running on a Proxmox virtual machine

### Minor Code Changes

For minor changes, each pull request should be tested on Ubuntu Desktop.

Run the following command after updating the `test_branch_name`:
```bash
test_branch_name=""
cd "${HOME}"/
rm -rf "${HOME}"/{.bitcoin/,bitcoin/,bitcoin-*-linux-gnu.tar.gz}
[ -d "${HOME}"/bitcoin-core-node-builder/ ] && rm -rf "${HOME}"/bitcoin-core-node-builder/
git clone https://github.com/epiccurious/bitcoin-core-node-builder.git -b "${test_branch_name}"
"${HOME}"/bitcoin-core-node-builder/nodebuilder
```

