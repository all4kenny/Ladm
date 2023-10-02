#!/bin/bash

# What to backup
source_1="/home"
source_2="/etc/ssh"
source_3="/etc/xrdp"
source_4="/etc/vsftpd.conf"
source_5="/var/log"

# Destination
if [ ! -d /mnt/Distr/archive ]; then
mkdir /mnt/Distr/archive
fi
dest="/mnt/Distr/archive"

# Create archive filename
day=$(date +%Y%m%d-%H%M%S)
hostname=$(hostname -s)
archive_file="$hostname-$day.tar"

# Print start status message
echo "Backing up $source_1 to $dest/$archive_file"
echo "Backing up $source_2 to $dest/$archive_file"
echo "Backing up $source_3 to $dest/$archive_file"
echo "Backing up $source_4 to $dest/$archive_file"
echo "Backing up $source_5 to $dest/$archive_file"
date
echo

# Backup the files using tar
tar cpf $dest/$archive_file $source_1 $source_2 $source_3 $source_4 $source_5

# Print end status message
echo
echo "Backup finished"
date

# Long listing of files in $dest to check file sizes.
ls -lh $dest
