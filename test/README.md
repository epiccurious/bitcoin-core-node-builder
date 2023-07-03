# Test Procedures

This directory outlines the procedures that test `bitcoin-core-node-builder` scripts.

## Automated Validation for Code Changes

Before you open a pull request to master, you should validate your code against two third-party shell tools.

After you open a pull request to master, GitHub Actions CI will [automatically run these checks](https://github.com/epiccurious/bitcoin-core-node-builder/actions/workflows/bash_validation_ci.yaml).

Add the tools to your environment with:
```bash
sudo apt install -y shellcheck shfmt
```

### How to Use shellcheck

[`ShellCheck`](https://www.shellcheck.net/) gives warnings and suggestions for bash/sh shell scripts, including:
- typical beginner's syntax issues that cause a shell to give cryptic error messages
- typical intermediate level semantic problems that cause a shell to behave strangely and counter-intuitively.
- subtle caveats, corner cases and pitfalls that may cause an advanced user's otherwise working script to fail under future circumstances.


To validate changes against `shellcheck`, run the following command:
```bash
shellcheck ~/Documents/GitHub/bitcoin-core-node-builder/nodebuilder
```

Alternatively, [a VSCode extension to integrate ShellCheck](https://github.com/vscode-shellcheck/vscode-shellcheck) can simplify the process.

### How to Use shfmt

[`shfmt`](https://github.com/mvdan/sh) formats shell programs. `shfmt`'s default shell formatting was chosen to be consistent, common, and predictable.

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

