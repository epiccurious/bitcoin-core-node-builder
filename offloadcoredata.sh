#!/bin/bash
set -e

# The Bitcoin Core blocks source directory, with no trailing slash
data_directory_source=$HOME/.bitcoin

# The blocks target/destination directory, with no trailing slash
# For our example, the drive is mounted at "/media/user1/DRIVE1"
# and the target/destination directory is "timechain/"
data_directory_target=/media/$USER/DRIVE/timechain

# Set the source and target variables
blocks_source=$data_directory_source/blocks
blocks_target=$data_directory_target/blocks
chainstate_source=$data_directory_source/chainstate
chainstate_target=$data_directory_target/chainstate
configuration_source=$data_directory_source/bitcoin.conf
configuration_target=$data_directory_target/bitcoin.conf

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
cp $blocks_source/{$highest_blk_dat,highest_rev_dat} $blocks_target/
echo "copied."

# Copy the blocks index directory
echo -n "Copying the blocks index... "
cp $blocks_source/index/ $blocks_target/index/
echo "copied."

# TODO: Need to add a check if we're just removing and copying the same thing
# Remove the old chainstate if one exists
[ -d $chainstate_target/ ] && echo -n "Removing the old chainstate data" && rm -r $chainstate_target/ && echo "finished."
# Remove the old configuration
[ -f $configuration_target ] && echo -n "Removing the old bitcoin.conf file." && rm $configuration_target

# Copy the new chainstate
echo -n "Copying the new chainstate ... "
cp -r $chainstate_source/ $chainstate_target/
echo "copied."

# TODO: Need to add a check if we're just removing and copying the same thing

# Copy the new configuration
cp $configuration_source $configuration_target

echo "Finished copying the chainstate and configuration."

echo "Finished transfer. Launching Bitcoin Core."
$HOME/bitcoin/bin/bitcoin-qt &
