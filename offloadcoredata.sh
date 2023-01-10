#!/bin/bash
set -e

## The Bitcoin Core blocks source directory, with no trailing slash
data_directory_source="$HOME"/.bitcoin

## The blocks target/destination directory, with no trailing slash
## For our example, the drive is mounted at "/media/user1/DRIVE1"
## and the target/destination directory is "timechain/"
data_directory_target=/media/$USER/BLOCKS/timechain

## Set the source and target variables
blocks_source=$data_directory_source/blocks
blocks_target=$data_directory_target/blocks
chainstate_source=$data_directory_source/chainstate
chainstate_target=$data_directory_target/chainstate

## Tell Bitcoin Core to stop and wait for the process to end
clear
echo -n "Closing Bitcoin Core..."
## Get the process ID for bitcoin-qt
qt_pid=$(pidof bitcoin-qt)
## Send the stop command to bitcoin-cli
"$HOME"/bitcoin/bin/bitcoin-cli stop 1>/dev/null
## Wait for the bitcoin-qt process to end
while [[ $(pidof bitcoin-qt) == "$qt_pid" ]]; do echo -n "."; sleep 1; done

## Search for all .dat files in the blocks directory and sort by the fourth character
find "$blocks_source" -name '*.dat' -type f -printf '%f\n' | sort -k1.4 > tomove

## Find the highest numbered rev file
highest_blk_dat=$(tail -2 tomove | head -1)
highest_rev_dat=$(tail -1 tomove)

## Remove the highest-numbered blk*.dat file from tomove
grep -v "$highest_blk_dat" tomove > tmpfile && mv tmpfile tomove
## Remove the highest-numbered rev*.dat file from tomove
grep -v "$highest_rev_dat" tomove > tmpfile && mv tmpfile tomove
echo "Moving all .dat files except $highest_blk_dat and $highest_rev_dat."

## Iterate through each line of tomove
while read -r file; do
  echo -n "Moving and linking $file... "
  ## Move the blk*.dat and rev*.dat files
  rsync -ptgouq --partial --remove-source-files "$blocks_source"/"$file" "$blocks_target"/"$file"
  ## Set the permissions to read-only
  chmod 400 "$blocks_target"/"$file"
  ## Create symbolic link from target to data dir
  ln -s "$blocks_target"/"$file" "$blocks_source"/"$file"
  ## Create a new line after rev files are copied
  [[ $file == "rev"*".dat" ]] && echo "finished."
done <tomove
## Remove the list of files to move
rm tomove

## Copy the highest-numbered blk*.dat and rev*.dat
## We will leave the original copy, rather than move.
echo -n "Copying $highest_blk_dat and $highest_rev_dat... "
rsync -ptgouq --partial "$blocks_source"/$highest_{blk,rev}_dat "$blocks_target"/
echo "copied."

## Copy the blocks index
echo -n "Copying the blocks index directory... "
rsync -auq --partial --delete "$blocks_source"/index/ "$blocks_target"/index/
echo "copied."

## Copy the chainstate
## Create a list of files
find "$chainstate_source" -type f -printf '%f\n' | sort > tomove
echo -n "Synchronizing $(wc -l < tomove) chainstate files..."
## Copy each line at a time
while read -r file; do
  echo -n "."
  rsync -ptgouq --partial "$chainstate_source"/"$file" "$chainstate_target"/
done <tomove
echo && rm tomove
## Delete old chainstate files left in the target directory
rsync -auq --partial --delete "$chainstate_source"/ "$chainstate_target"/
echo "copied."

## Launch and disown bitcoin-qt
echo "Finished the data transfer. Launching Bitcoin Core application."
"$HOME"/bitcoin/bin/bitcoin-qt & disown
