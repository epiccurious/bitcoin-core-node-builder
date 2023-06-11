#!/bin/bash
set -e

# Set the URL to download Bitcoin Core, taken from https://bitcoincore.org/en/download/
bitcoin_core_url="https://bitcoincore.org/bin/bitcoin-core-24.0.1/bitcoin-24.0.1-x86_64-linux-gnu.tar.gz"

# Pull the filename and download directory out of the url
bitcoin_core_dir=$(dirname $bitcoin_core_url)
bitcoin_core_file=$(basename $bitcoin_core_url)

# The filenames for the hash and signature
sha256_hash_file="SHA256SUMS"
gpg_signatures_file="SHA256SUMS.asc"
gpg_good_signatures_required="7"

# Name of the directory to extract into, without the trailing "/" (forward slash)
bitcoin_core_extract_dir="${HOME}/bitcoin"
bitcoin_core_binary_dir="${bitcoin_core_extract_dir}/bin"

# Amount of time to wait between calls to getblockchaininfo
sleep_time=10

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

# Set automatical restart flag back to interactive mode.
sudo sed -i 's/#$nrconf{restart} = '"'"'a'"'"';/$nrconf{restart} = '"'"'i'"'"';/g' /etc/needrestart/needrestart.conf

# Install dependencies
echo "Checking dependencies... "
sudo apt -qq install -y git gnupg jq libxcb-xinerama0 wget

# Download Bitcoin Core and the list of valid checksums
echo -n "Downloading Bitcoin Core files... "
[ -f "${bitcoin_core_file}" ] || wget -q "${bitcoin_core_dir}"/"${bitcoin_core_file}"
[ -f "${sha256_hash_file}" ] || wget -q "${bitcoin_core_dir}"/"${sha256_hash_file}"
[ -f "${gpg_signatures_file}" ] || wget -q "${bitcoin_core_dir}"/"${gpg_signatures_file}"
echo "ok."

# Check that the release file's checksum is listed in SHA256SUMS
echo -n "  Validating the download's checksum... "
sha256_check=$(echo $(grep ${bitcoin_core_file} ${sha256_hash_file}) | sha256sum --check 2>/dev/null)
if [[ "${sha256_check}" == *"OK" ]]; then
  echo "ok."
else
  echo -e "INVALID. The download has failed.\nThis script cannot continue due to security concerns.\n\nPRESS ANY KEY TO EXIT."
  read -rn1
  exit 1
fi

# Check the PGP signatures of SHA256SUMS
echo -n "  Validating the signatures of the checksum file... "
[ -d guix.sigs/ ] || git clone --quiet https://github.com/bitcoin-core/guix.sigs.git
gpg --quiet --import guix.sigs/builder-keys/*.gpg
gpg_good_signature_count=$(gpg --verify "${gpg_signatures_file}"  2>&1 | grep "^gpg: Good signature from " | wc -l)
if [[ "${gpg_good_signature_count}" -ge "${gpg_good_signatures_required}" ]]; then
  echo "${gpg_good_signature_count} good."
  rm "${sha256_hash_file}"
  rm "${gpg_signatures_file}"
  rm -rf guix.sigs/
else
  echo -e "INVALID. The download has failed.\nThis script cannot continue due to security concerns.\n\nPRESS ANY KEY TO EXIT."
  read -rn1
  exit 1
fi

# Extract Bitcoin Core
echo -n "Extracting Bitcoin Core... "
[ -d "${bitcoin_core_extract_dir}" ] || mkdir "${bitcoin_core_extract_dir}"/
tar -xzf "${bitcoin_core_file}" -C "${bitcoin_core_extract_dir}"/ --strip-components=1
echo "ok."

echo "Configuring Bitcoin Core... "
echo -n "  Creating the desktop shortcut... "
## Create a desktop shortcut for Bitcoin Core
cp $(dirname $0)/bitcoin.png "$bitcoin_core_extract_dir"/
shortcut_filename="bitcoin_core.desktop"
## Create the desktop file
touch "$HOME"/Desktop/"$shortcut_filename"
cat << EOF > "$HOME"/Desktop/"$shortcut_filename"
[Desktop Entry]
Name=Bitcoin Core
Comment=Launch Bitcoin Core
Exec=$HOME/bitcoin/bin/bitcoin-qt & disown
Icon=$HOME/bitcoin/bitcoin.png
Terminal=false
StartupWMClass=Bitcoin Core
Type=Application
Categories=Application;
EOF
## Make the shortcut user-executable
chmod u+x "$HOME"/Desktop/"$shortcut_filename"
## Make the shortcut trusted
gio set "$HOME"/Desktop/"$shortcut_filename" "metadata::trusted" true
echo "ok."

# Configure the node
echo -n "  Setting default node behavior... "
[ -d "$HOME"/.bitcoin/ ] || mkdir "$HOME"/.bitcoin/
echo -e "server=1\nmempoolfullrbf=1" > "$HOME"/.bitcoin/bitcoin.conf
echo "ok."

echo "Starting Bitcoin Core... "
"$bitcoin_core_binary_dir"/bitcoin-qt 2>/dev/null & disown

blockchain_info=$("$bitcoin_core_binary_dir"/bitcoin-cli getblockchaininfo 2>/dev/null)

while [[ -z $blockchain_info ]]; do
  printf "Please wait while the system initializes."
  
  for (( i=1; i<=sleep_time; i++)); do
    sleep 1
    printf "."
  done
  echo
  
  blockchain_info=$("$bitcoin_core_binary_dir"/bitcoin-cli getblockchaininfo 2>/dev/null)
done

echo -e "\nThe bitcoin timechain is now synchronizing.\nThis may take a couple days to a couple weeks depending on the speed of your machine and connection.\nKeep your computer connected to power and internet. If you get disconnected or your computer hangs, rerun this script.\nSleep, suspend, and hibernate will be disabled to maximize the chances everything goes smoothly.\n\nPRESS ANY KEY TO DISABLE SLEEP, SUSPEND, and HIBERNATE."
read -rn1 && echo # Comment this line out for testing and development purposes

## Disable system sleep, suspend, hibernate, and hybrid-sleep through the system control tool
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
echo -e "System settings updated.\n\nPlease wait while Bitcoin Core initializes then begins syncing block headers.\nDo not close this terminal window."


# Pull the initial block download status
ibd_status=$(echo "$blockchain_info" | jq '.initialblockdownload')

while [[ $ibd_status -eq "true" ]]; do
  # Parse blockchain info values
  blocks=$(echo "$blockchain_info" | jq '.blocks')
  headers=$(echo "$blockchain_info" | jq '.headers')
  sync_progress=$(echo "$blockchain_info" | jq '.verificationprogress')
  last_block_time=$(echo "$blockchain_info" | jq '.time')
  size_on_disk=$(echo "$blockchain_info" | jq '.size_on_disk')
  
  # Handle case of early sync by replacing any e-9 with 10^-9
  [[ "$sync_progress" == *"e"* ]] && sync_progress="0.000000001"
  
  # Generate output string, clear the terminal, and print the output
  sync_status="The sync progress:          $sync_progress\nThe number of blocks left:  $((headers-blocks))\nThe current chain tip:      $(date -d @"$last_block_time" | cut -c 5-)\n\nThe estimated size on disk: $((size_on_disk/1000/1000/1000))GB\nThe estimated free space:   $(df -h / | tail -1 | awk '{print $4}')B\n"
  clear
  echo -e "$sync_status"
  
  # Initiate sleep loop for "sleep_time" seconds
  printf 'This screen will refresh in %s seconds.' "$sleep_time"
  for (( i=1; i<=sleep_time; i++)); do
    sleep 1
    printf "."
  done
  
  # Check for updated sync state
  blockchain_info=$("$bitcoin_core_binary_dir"/bitcoin-cli getblockchaininfo)
  ibd_status=$(echo "$blockchain_info" | jq '.initialblockdownload')
done

echo -e "This script has completed successfully.\n\nPRESS ANY KEY TO END THE SCRIPT."
read -rn1
