#!/bin/bash
set -e

bitcoin_version="25.0"
bitcoin_source="https://bitcoincore.org/bin/bitcoin-core-${bitcoin_version}"
bitcoin_tarball_file="bitcoin-${bitcoin_version}-x86_64-linux-gnu.tar.gz"
bitcoin_core_extract_dir="${HOME}/bitcoin"
bitcoin_core_binary_dir="${bitcoin_core_extract_dir}/bin"

bitcoin_hash_file="SHA256SUMS"
gpg_signatures_file="SHA256SUMS.asc"
gpg_good_signatures_required="7"
guix_sigs_clone_directory="${HOME}/guix.sigs"

sleep_time="10"

# Set services to automatically restart during dist-upgrade
if [ -f /etc/needrestart/needrestart.conf ]; then
  sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
else
  sudo mkdir -p /etc/needrestart/
  echo "\$nrconf{restart} = 'a';" | sudo tee /etc/needrestart/needrestart.conf
fi

# Perform a full system upgrade (comparable to running Ubuntu System Updater)
clear
echo "Performing a full system upgrade... "
sudo apt -qq update && sudo apt -qq dist-upgrade --assume-yes

# Set services restart flag back to interactive mode.
sudo sed -i 's/#$nrconf{restart} = '"'"'a'"'"';/$nrconf{restart} = '"'"'i'"'"';/g' /etc/needrestart/needrestart.conf

if [ -f /var/run/reboot-required ]; then
  echo -en "\nREBOOT REQUIRED to upgrade the following:\n$(cat /var/run/reboot-required.pkgs)\n\nPRESS ANY KEY to reboot or press Ctrl+C to exit... "
  read -rsn1 && echo
  echo "Rebooting."
  reboot
  exit 0
fi

# Install dependencies
echo "Checking dependencies... "
sudo apt -qq update && sudo apt -qq install --assume-yes --no-install-recommends git gnupg jq libxcb-xinerama0 wget

echo -n "Downloading Bitcoin Core files... "
[ -f "${bitcoin_tarball_file}" ] || wget -q "${bitcoin_source}"/"${bitcoin_tarball_file}"
[ -f "${bitcoin_hash_file}" ] || wget -q "${bitcoin_source}"/"${bitcoin_hash_file}"
[ -f "${gpg_signatures_file}" ] || wget -q "${bitcoin_source}"/"${gpg_signatures_file}"
echo "ok."

# Check that the release file's checksum is listed in SHA256SUMS
echo -n "  Validating the checksum... "
sha256_check=$(echo $(grep ${bitcoin_tarball_file} ${bitcoin_hash_file}) | sha256sum --check 2>/dev/null)
if [[ "${sha256_check}" == *"OK" ]]; then
  echo "ok."
else
  echo -en "INVALID. The download has failed.\nThis script cannot continue due to security concerns.\n\nPRESS ANY KEY to exit... "
  read -rsn1 && echo
  >&2 echo "Exiting."
  exit 1
fi

# Check the PGP signatures of SHA256SUMS
echo -n "  Validating the signatures... "
[ -d "${guix_sigs_clone_directory}"/ ] || git clone --quiet https://github.com/bitcoin-core/guix.sigs.git "${guix_sigs_clone_directory}"
gpg --quiet --import "${guix_sigs_clone_directory}"/builder-keys/*.gpg
gpg_good_signature_count=$(gpg --verify "${gpg_signatures_file}"  2>&1 | grep "^gpg: Good signature from " | wc -l)
if [[ "${gpg_good_signature_count}" -ge "${gpg_good_signatures_required}" ]]; then
  echo "${gpg_good_signature_count} good."
  rm "${bitcoin_hash_file}"
  rm "${gpg_signatures_file}"
  rm -rf "${guix_sigs_clone_directory}"/
else
  echo -en "INVALID. The download has failed.\nThis script cannot continue due to security concerns.\n\nPRESS ANY KEY to exit... "
  read -rsn1 && echo
  >&2 echo "Exiting."
  exit 1
fi

echo -n "Extracting Bitcoin Core... "
[ -d "${bitcoin_core_extract_dir}" ] || mkdir "${bitcoin_core_extract_dir}"/
tar -xzf "${bitcoin_tarball_file}" -C "${bitcoin_core_extract_dir}"/ --strip-components=1
echo "ok."

echo -n "Creating Desktop and Applications shortcuts... "
## Create shortcut on the Desktop and in the "Show Applications" view
desktop_path="${HOME}/Desktop"
applications_path="${HOME}/.local/share/applications"
shortcut_filename="bitcoin_core.desktop"

cp $(dirname $0)/img/bitcoin.png "${bitcoin_core_extract_dir}"/

## Create .desktop on the user's Desktop and "Show Applications" directories
cat << EOF | tee "${applications_path}"/"${shortcut_filename}" > "${desktop_path}"/"${shortcut_filename}"
[Desktop Entry]
Name=Bitcoin Core
Comment=Launch Bitcoin Core
Exec=${HOME}/bitcoin/bin/bitcoin-qt & disown
Icon=${HOME}/bitcoin/bitcoin.png
Terminal=false
StartupWMClass=Bitcoin Core
Type=Application
Categories=Application;
EOF
## Make the shortcuts user-executable
chmod u+x "${applications_path}"/"${shortcut_filename}"
chmod u+x "${desktop_path}"/"${shortcut_filename}"
## Make the desktop shortcut trusted
gio set "${desktop_path}"/"${shortcut_filename}" "metadata::trusted" true
echo "ok."

echo -n "Setting the default node behavior... "
[ -d "${HOME}"/.bitcoin/ ] || mkdir "${HOME}"/.bitcoin/
echo -e "server=1\nmempoolfullrbf=1" > "${HOME}"/.bitcoin/bitcoin.conf
echo "ok."

echo -n "Checking free space in home directory... "
free_space_in_bytes=$(df --block-size=1 --output=avail "${HOME}" | sed 1d)
free_space_in_mib="$((free_space_in_bytes/1024/1024))"
echo "$((free_space_in_mib/1024)) GiB."

## This constant will need to be adjusted over time as the chain grows
## or need to find how to generate this dynamically in a trustless way.
archival_node_minimum_in_mib="$((600*1024))"
## The lower this number is, the more likely disk space errors during IBD
## The higher this number is, the more nodes prune.
## The sweet spot is about 50-100 GB more than the current blocks/ + chainstate/ size,
## which, as of June 2023, is around 522 GiB.

if [ ${free_space_in_mib} -ge ${archival_node_minimum_in_mib} ]; then
  echo "  Your node will run as an unpruned full node."
elif [ ${free_space_in_mib} -lt $((archival_node_minimum_in_mib/80)) ]; then
  echo -e "  You are too low on disk space to run Bitcoin Core.\nExiting..."
  exit 1
else
  if [ ${free_space_in_mib} -lt $((archival_node_minimum_in_mib/40)) ]; then
    echo -e "  Your disk space is low.\n  Setting blocks-only mode and the minimum 0.55 GiB prune."
    echo "blocksonly=1" >> "${HOME}"/.bitcoin/bitcoin.conf
    prune_amount_in_mib="550"
  else
    if [ ${free_space_in_mib} -lt $((archival_node_minimum_in_mib/12)) ]; then
      prune_ratio=20
    elif [ ${free_space_in_mib} -lt $((archival_node_minimum_in_mib/4)) ]; then
      prune_ratio=40
    elif [ ${free_space_in_mib} -lt $((archival_node_minimum_in_mib*3/4)) ]; then
      prune_ratio=60
    else
      prune_ratio=80
    fi
    prune_amount_in_mib=$((free_space_in_mib*prune_ratio/100))
    echo -e "  Pruning to $((prune_amount_in_mib/1024)) GiB (${prune_ratio}% of the free space).\n  You can change this in ~/.bitcoin/bitcoin.conf."
  fi
  echo "prune=${prune_amount_in_mib}" >> "${HOME}"/.bitcoin/bitcoin.conf
fi

echo -n "Starting Bitcoin Core... "
"${bitcoin_core_binary_dir}"/bitcoin-qt 2>/dev/null & disown
"${bitcoin_core_binary_dir}"/bitcoin-cli --rpcwait getrpcinfo > /dev/null
echo "ok."

echo -n "Disabling system sleep, suspend, and hibernate... "
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target &> /dev/null
echo "ok."

echo -en "\nClose this Terminal window by clicking on the \"X\".\nThis screen will refresh in ${sleep_time} seconds."
for (( i=1; i<=sleep_time; i++)); do
  sleep 1
  printf "."
done
echo

blockchain_info=$("${bitcoin_core_binary_dir}"/bitcoin-cli --rpcwait getblockchaininfo)
ibd_status=$(echo "${blockchain_info}" | jq '.initialblockdownload')

while [[ "${ibd_status}" == "true" ]]; do
  sync_progress=$(echo "${blockchain_info}" | jq '.verificationprogress')
  # Handle case of early sync by replacing scientific notation with decimal
  [[ "${sync_progress}" == *"e"* ]] && sync_progress="0.000000001"
  sync_progress_percent=$(echo "${sync_progress}*100" | bc)
  
  blocks=$(echo "${blockchain_info}" | jq '.blocks')
  headers=$(echo "${blockchain_info}" | jq '.headers')
  last_block_time=$(echo "${blockchain_info}" | jq '.time')
  size_on_disk=$(echo "${blockchain_info}" | jq '.size_on_disk')
  
  # Generate output string, clear the terminal, and print the output
  sync_status="Sync progress:          $(printf '%.4f' ${sync_progress_percent}) %\nBlocks left to sync:    $((headers-blocks))\nCurrent chain tip:      $(date -d @"${last_block_time}" | cut -c 5-)\n\nEstimated size on disk: $((size_on_disk/1024/1024/1024)) GiB\nEstimated free space:   $(df -h / | tail -1 | awk '{print $4}')iB"
  clear
  echo -e "${sync_status}"
  
  echo -en "\nSynchronizing can take weeks on a slow connection.\n\nClose this Terminal window by clicking on the \"X\".\nThis screen will refresh in ${sleep_time} seconds."
  for (( i=1; i<=sleep_time; i++)); do
    sleep 1
    printf "."
  done

  # Check for updated sync state
  blockchain_info=$("${bitcoin_core_binary_dir}"/bitcoin-cli --rpcwait getblockchaininfo)
  echo
  ibd_status=$(echo "${blockchain_info}" | jq '.initialblockdownload')
done

echo -e "This script has completed successfully.\nExiting."
exit 0
