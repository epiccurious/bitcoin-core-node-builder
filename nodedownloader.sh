#!/bin/bash
# Set the URL to download Bitcoin Core, taken from https://bitcoincore.org/en/download/
bitcoin_core_url="https://bitcoincore.org/bin/bitcoin-core-24.0.1/bitcoin-24.0.1-x86_64-linux-gnu.tar.gz"

# These string should not be changed
checksum_file="SHA256SUMS"
signatures_file="SHA256SUMS.asc"

# Name of the directory to extract into, without the trailing "/" (forward slash)
bitcoin_core_extract_dir="bitcoin"

# Amount of time to wait between calls to getblockchaininfo
sleep_time=10

# Pull the filename and download directory out of the url
bitcoin_core_dir=$(dirname $bitcoin_core_url)
bitcoin_core_file=$(basename $bitcoin_core_url)

# Set services to automatically restart during dist-upgrade
sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

# Perform a full system upgrade (comparable to running Ubuntu System Updater)
clear
echo "Performing a full system upgrade... "
sudo apt -qq update && sudo apt -qq dist-upgrade -y

# Install dependencies
echo "Checking dependencies... "
sudo apt -qq install -y libxcb-xinerama0 jq git

# Download Bitcoin Core and the list of valid checksums
echo -n "Downloading Bitcoin Core files... "
[ -f $bitcoin_core_file ] || wget $bitcoin_core_url
[ -f $checksum_file ] || wget $bitcoin_core_dir/$checksum_file
echo "downloaded."

# Verify that the release file's checksum is listed in SHA256SUMS
echo -n "Verifying the download's checksum... "
sha_check=$(sha256sum --ignore-missing --check SHA256SUMS 2>/dev/null)
[[ "$sha_check" == *"OK"* ]] && echo "VALID."

[[ "$sha_check" == *"FAILED"* ]] && echo -e "INVALID. This is very bad.\nProgram cannot continue due to security concerns.\n\nPRESS ANY KEY TO EXIT." && read -n1 && exit 1

[[ -z $sha_check ]] && echo -e "Unhandled issue with SHA256SUM check.\nProgram cannot continue due to security concerns.\n\nPRESS ANY KEY TO EXIT." && read -n1 && exit 1

# Check signatures (THIS SECTION IS NOT COMPLETE)
[ -f $signatures_file ] || wget $bitcoin_core_dir/$signatures_file
#git clone https://github.com/bitcoin-core/guix.sigs.git
#cp -r guix.sigs/builder-keys/ ./
#rm -rf guix.sigs/
#gpg --keyserver hkps://keys.openpgp.org --refresh-keys 

# Extract Bitcoin Core
echo -n "Extracting the compressed Bitcoin Core download... "
mkdir $HOME/$bitcoin_core_extract_dir/
tar -xzf $bitcoin_core_file -C $HOME/$bitcoin_core_extract_dir/ --strip-components=1
echo "finished."

# Configure the node
[ -d $HOME/.bitcoin/ ] || mkdir $HOME/.bitcoin/
echo -e "daemonwait=1\nserver=1" > $HOME/.bitcoin/bitcoin.conf

echo "Bitcoin Core will start then stop then start again."
$HOME/$bitcoin_core_extract_dir/bin/bitcoind -daemonwait
echo "Bitcoin Core started"
sleep 1
$HOME/$bitcoin_core_extract_dir/bin/bitcoin-cli stop
sleep 5
echo "Bitcoin Core stopped"
echo "Bitcoin Core starting"
$HOME/$bitcoin_core_extract_dir/bin/bitcoin-qt 2>/dev/null &

echo -e "\nThe bitcoin timechain is now synchronizing.\nThis may take a couple days to a couple weeks depending on the speed of your machine and connection.\nKeep your computer connected to power and internet. If you get disconnected or your computer hangs, rerun this script.\nSleep, suspend, and hibernate will be disabled to maximize the chances everything goes smoothly.\n\nPRESS ANY KEY TO DISABLE SLEEP, SUSPEND, and HIBERNATE."
read -n1 && echo # Comment this line out for testing and development purposes

## Disable system sleep, suspend, hibernate, and hybrid-sleep through the system control tool
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
echo -e "System settings updated.\n\nPlease wait while Bitcoin Core initializes then begins syncing block headers.\nDo not close this terminal window."

blockchain_info=$($HOME/$bitcoin_core_extract_dir/bin/bitcoin-cli getblockchaininfo 2>/dev/null)

while [[ -z $blockchain_info ]]; do
  printf "Please wait while the system initializes."
  
  for (( i=1; i<=$sleep_time; i++)); do
    sleep 1
    printf "."
  done
  echo
  
  blockchain_info=$($HOME/$bitcoin_core_extract_dir/bin/bitcoin-cli getblockchaininfo 2>/dev/null)
done

# Pull the initial block download status
ibd_status=$(echo $blockchain_info | jq '.initialblockdownload')

while [[ $ibd_status -eq "true" ]]; do
  # Parse blockchain info values
  blocks=$(echo $blockchain_info | jq '.blocks')
  headers=$(echo $blockchain_info | jq '.headers')
  sync_progress=$(echo $blockchain_info | jq '.verificationprogress')
  last_block_time=$(echo $blockchain_info | jq '.time')
  size_on_disk=$(echo $blockchain_info | jq '.size_on_disk')
  
  # Handle case of early sync by replacing any e-9 with 10^-9
  [[ "$sync_progress" == *"e"* ]] && sync_progress="0.000000001"
  
  # Generate output string, clear the terminal, and print the output
  sync_status="The sync progress:          $sync_progress\nThe number of blocks left:  $((headers-blocks))\nThe current chain tip:      $(date -d @$last_block_time | cut -c 5-)\n\nThe estimated size on disk: $(($size_on_disk/1000/1000/1000))GB\nThe estimated free space:   $(df -h / | tail -1 | awk '{print $4}')B\n"
  clear
  echo -e $sync_status
  
  # Initiate sleep loop for "sleep_time" seconds
  printf "This screen will refresh in $sleep_time seconds."
  for (( i=1; i<=$sleep_time; i++)); do
    sleep 1
    printf "."
  done
  
  # Check for updated sync state
  blockchain_info=$($HOME/$bitcoin_core_extract_dir/bin/bitcoin-cli getblockchaininfo)
  ibd_status=$(echo $blockchain_info | jq '.initialblockdownload')
done

echo -e "This script has completed successfully.\n\nPRESS ANY KEY TO END THE SCRIPT."
read -n1
