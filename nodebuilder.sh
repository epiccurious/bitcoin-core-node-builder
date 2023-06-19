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
sudo apt -qq update && sudo apt -qq dist-upgrade -y

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
sudo apt -qq update && sudo apt -qq install -y git gnupg jq libxcb-xinerama0 wget

# Download Bitcoin Core and the list of valid checksums
echo -n "Downloading Bitcoin Core files... "
[ -f "${bitcoin_tarball_file}" ] || wget -q "${bitcoin_source}"/"${bitcoin_tarball_file}"
[ -f "${bitcoin_hash_file}" ] || wget -q "${bitcoin_source}"/"${bitcoin_hash_file}"
[ -f "${gpg_signatures_file}" ] || wget -q "${bitcoin_source}"/"${gpg_signatures_file}"
echo "ok."

# Check that the release file's checksum is listed in SHA256SUMS
echo -n "  Validating the download's checksum... "
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
echo -n "  Validating the signatures of the checksum file... "
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

echo "Configuring Bitcoin Core... "
echo -n "  Creating the desktop shortcut... "
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

echo -n "  Setting default node behavior... "
[ -d "${HOME}"/.bitcoin/ ] || mkdir "${HOME}"/.bitcoin/
echo -e "server=1\nmempoolfullrbf=1" > "${HOME}"/.bitcoin/bitcoin.conf
echo "ok."

echo -n "Starting Bitcoin Core... "
"${bitcoin_core_binary_dir}"/bitcoin-qt 2>/dev/null & disown
"${bitcoin_core_binary_dir}"/bitcoin-cli --rpcwait getrpcinfo > /dev/null
echo "ok."

echo -en "  Note: Synchronizing the blockchain may take several weeks,\n  on old computers and slow internet. Please be patient.\n\nPRESS ANY KEY to disable sleep, suspend, and hibernate... "
read -rsn1 && echo

sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
echo "System settings have been updated."

echo -en "\nClose this Terminal window by clicking on the \"X\".\nThis screen will refresh in ${sleep_time} seconds."
for (( i=1; i<=sleep_time; i++)); do
  sleep 1
  printf "."
done
echo

blockchain_info=$("${bitcoin_core_binary_dir}"/bitcoin-cli --rpcwait getblockchaininfo)
ibd_status=$(echo "${blockchain_info}" | jq '.initialblockdownload')

while [[ "${ibd_status}" == "true" ]]; do
  # Parse blockchain info values
  blocks=$(echo "${blockchain_info}" | jq '.blocks')
  headers=$(echo "${blockchain_info}" | jq '.headers')
  sync_progress=$(echo "${blockchain_info}" | jq '.verificationprogress')
  last_block_time=$(echo "${blockchain_info}" | jq '.time')
  size_on_disk=$(echo "${blockchain_info}" | jq '.size_on_disk')
  
  # Handle case of early sync by replacing any e-9 with 10^-9
  [[ "${sync_progress}" == *"e"* ]] && sync_progress="0.000000001"
  
  # Generate output string, clear the terminal, and print the output
  sync_status="Sync progress:          ${sync_progress}\nBlocks left to sync:    $((headers-blocks))\nCurrent chain tip:      $(date -d @"${last_block_time}" | cut -c 5-)\n\nEstimated size on disk: $((size_on_disk/1000/1000/1000))GB\nEstimated free space:   $(df -h / | tail -1 | awk '{print $4}')B"
  clear
  echo -e "${sync_status}"
  
  # Initiate sleep loop for "sleep_time" seconds
  echo -en "\nClose this Terminal window by clicking on the \"X\".\nThis screen will refresh in ${sleep_time} seconds."
  for (( i=1; i<=sleep_time; i++)); do
    sleep 1
    printf "."
  done
  echo

  # Check for updated sync state
  blockchain_info=$("${bitcoin_core_binary_dir}"/bitcoin-cli --rpcwait getblockchaininfo)
  ibd_status=$(echo "${blockchain_info}" | jq '.initialblockdownload')
done

echo -e "This script has completed successfully.\nExiting."
exit 0
