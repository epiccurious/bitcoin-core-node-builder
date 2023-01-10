#!/bin/bash
set -e

# The Bitcoin Core blocks source directory, with no trailing slash
data_directory_source=$HOME/.bitcoin

# The blocks target/destination directory, with no trailing slash
# For our example, the drive is mounted at "/media/user1/DRIVE1"
# and the target/destination directory is "timechain/"
data_directory_target=/media/$USER/DRIVE1/timechain

# Set the source and target variables
blocks_source=$data_directory_source/blocks
blocks_target=$data_directory_target/blocks
chainstate_source=$data_directory_source/chainstate
chainstate_target=$data_directory_target/chainstate
configuration_source=$data_directory_source/bitcoin.conf
configuration_target=$data_directory_target/bitcoin.conf

# Tell Bitcoin Core to stop and wait for the process to end
clear
echo -n "Closing Bitcoin Core..."
# Get the process ID for bitcoin-qt
qt_pid=$(pidof bitcoin-qt)
# Send the stop command to bitcoin-cli
$HOME/bitcoin/bin/bitcoin-cli stop 1>/dev/null
# Wait for the bitcoin-qt process to end
while [[ $(pidof bitcoin-qt) == $qt_pid ]]; do echo -n "."; sleep 1; done

# Search for all .dat files in the blocks directory and sort by the fourth character
find $blocks_source -name '*.dat' -type f -printf '%f\n' | sort -k1.4 > tomove

# Find the highest numbered rev file
highest_blk_dat=$(cat tomove | tail -2 | head -1)
highest_rev_dat=$(cat tomove | tail -1)

# Remove the highest-numbered blk*.dat file from tomove
grep -v $highest_blk_dat tomove > tmpfile && mv tmpfile tomove
# Remove the highest-numbered rev*.dat file from tomove
grep -v $highest_rev_dat tomove > tmpfile && mv tmpfile tomove
echo "Moving all .dat files except $highest_blk_dat and $highest_rev_dat."

# Iterate through each line of tomove
while read file; do
  echo -n "Moving and linking $file... "
  # Move the blk*.dat and rev*.dat files
  mv $blocks_source/$file $blocks_target/$file
  # Set the permissions to read-only
  chmod 400 $blocks_target/$file
  # Create symbolic link from target to data dir
  ln -s $blocks_target/$file $blocks_source/$file
  # Create a new line after rev files are copied
  [[ $file == "rev"*".dat" ]] && echo "finished."
done <tomove

# Remove the list of files to move
rm tomove

# Copy the highest-numbered blk*.dat and rev*.dat
# We will leave the original copy, rather than move.
echo -n "Copying $highest_blk_dat and $highest_rev_dat... "
cp $blocks_source/$highest_{blk,rev}_dat $blocks_target/
echo "copied."

# TODO: Need to add a check if we're just removing and copying the same thing
# Remove the old blocks index directory, if one exists
[ -d $blocks_target/index/ ] && echo -n "Removing the old blocks index directory... " && rm -r $blocks_target/index/ && echo "finished."
# Copy the blocks index directory
echo -n "Copying the new blocks index directory... "
cp -r $blocks_source/index/ $blocks_target/index/
echo "copied."

# Remove the old chainstate directory, if one exists
[ -d $chainstate_target/ ] && echo -n "Removing the old chainstate directory... " && rm -r $chainstate_target/ && echo "finished."
# Copy the new chainstate
echo -n "Copying the new chainstate directory... "
cp -r $chainstate_source/ $chainstate_target/
echo "copied."

# Remove the old configuration file, if one exists
[ -f $configuration_target ] && echo -n "Removing the old configuration file." && rm $configuration_target
# Copy the new configuration
echo "Copying the new configuration file."
cp $configuration_source $configuration_target

echo "Finished the data transfer. Launching Bitcoin Core application."
$HOME/bitcoin/bin/bitcoin-qt &
