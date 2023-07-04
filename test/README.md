# Test Procedures

This page outlines the procedures to test `bitcoin-core-node-builder` scripts.

## Table of Contents
- [Automated Validation](#automated-validation-for-code-changes)
  - [Details About the Validation Tools](#details-about-the-validation-tools)
  - [How to Use ShellCheck](#how-to-use-shellcheck)
  - [How to Use shfmt](#how-to-use-shfmt)
- [Manual Testing](#manual-testing-for-code-changes)
  - [Major Code Changes](#major-code-changes)
  - [Minor Code Changes](#minor-code-changes)

## Automated Validation

_**Before**_ opening a pull request, you must validate your code changes against two third-party shell tools: `shellcheck` and `shfmt`.

_**After**_ opening a pull request, GitHub Actions CI will [automatically run `shellcheck` and `shfmt`](https://github.com/epiccurious/bitcoin-core-node-builder/actions/workflows/bash_validation_ci.yaml) for you.

### Details About the Validation Tools

[`ShellCheck`](https://www.shellcheck.net/) gives warnings and suggestions for bash/sh shell scripts, including:
- typical beginner's syntax issues that cause a shell to give cryptic error messages
- typical intermediate level semantic problems that cause a shell to behave strangely and counter-intuitively.
- subtle caveats, corner cases and pitfalls that may cause an advanced user's otherwise working script to fail under future circumstances.

[`shfmt`](https://github.com/mvdan/sh) formats shell programs. `shfmt`'s default shell formatting was chosen to be consistent, common, and predictable.

You can add the packages to your local environment with `sudo apt install -y shellcheck shfmt`.

### How to Use ShellCheck

To validate changes against `shellcheck`, run the following command:
```bash
shellcheck ~/Documents/GitHub/bitcoin-core-node-builder/nodebuilder
```

Alternatively, [a VSCode extension to integrate ShellCheck](https://github.com/vscode-shellcheck/vscode-shellcheck) can simplify the process.

### How to Use shfmt

To validate changes against `shellcheck`, run the following command:
```bash
shfmt -i 2 -sr -d ~/Documents/GitHub/bitcoin-core-node-builder/nodebuilder
```

## Manual Testing

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

