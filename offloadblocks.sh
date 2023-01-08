#!/bin/bash
set -e

# The Bitcoin Core blocks source directory, with no trailing slash
BLOCK_SOURCE=$HOME/.bitcoin/blocks

# The blocks target/destination directory, with no trailing slash
# For our example, the drive is mounted at "/media/user1/DRIVE1"
# and the target/destination directory is "blocks/"
BLOCK_TARGET=/media/$USER/DRIVE1/blocks

# Search for all .dat files in the directory and sort by the fourth character
find . -name '*.dat' -type f -printf '%f\n' | sort -k1.4 > tomove

# Find the highest numbered rev file
remove_blk=$(cat tomove | tail -2 | head -1)
remove_rev=$(cat tomove | tail -1)

# Remove the highest-numbered blk*.dat file from tomove
grep -v $remove_blk tomove > tmpfile && mv tmpfile tomove
# Remove the highest-numbered rev*.dat file from tomove
grep -v $remove_rev tomove > tmpfile && mv tmpfile tomove
echo "Selecting all .dat files except $remove_blk and $remove_rev."

# Iterate through each line of tomove
while read file; do
  echo -n "Moving and linking $file... "
  # Move the blk*.dat and rev*.dat files
  mv $BLOCK_SOURCE/$file $BLOCK_TARGET/$file
  # Set the permissions to read-only
  chmod 400 $BLOCK_TARGET/$file
  # Create symbolic link from target to data dir
  ln -s $BLOCK_TARGET/$file $BLOCK_SOURCE/$file
  # Create a new line after rev files are copied
  [[ $file == "rev"*".dat" ]] && echo "finished."
done <tomove

rm tomove

echo "Finished transfer. Launching Bitcoin Core."
$HOME/bitcoin/bin/bitcoin-qt &
