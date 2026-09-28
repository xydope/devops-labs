#!/bin/bash

usage() {
  echo "Usage: $0 <source_directory> <destination_directory>"
  echo
  echo "Create a compressed backup archive of a directory."
  echo
  echo "Arguments:"
  echo "  source_directory       Directory to backup"
  echo "  destination_directory  Directory where the backup archive will be stored"
  echo
  echo "Example:"
  echo "  $0 ~/data ~/backups"
}

if [[ "$1" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

SOURCE_DIR="$1"
DESTINATION_DIR="$2"

if [[ ! -d "$SOURCE_DIR" ]]; then
  msg="Error: Source directory '$SOURCE_DIR' does not exist."

  echo "$msg" >&2
  logger -t bash-backup -p user.err "$msg"
  exit 1
fi

if ! mkdir -p "$DESTINATION_DIR" 2> /dev/null; then
  msg="Error: Failed to create destination directory '$DESTINATION_DIR'."
  echo "$msg" >&2
  logger -t bash-backup -p user.err "$msg"
  exit 1
fi

bkp_filename="$(basename "$SOURCE_DIR")_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"

if ! tar -czf "$DESTINATION_DIR/$bkp_filename" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" &> /dev/null; then
  msg="Error: Failed to create backup archive '$DESTINATION_DIR/$bkp_filename'."

  echo "$msg" >&2
  logger -t bash-backup -p user.err "$msg"
  exit 1
fi

find "$DESTINATION_DIR" -type f -name "$(basename "$SOURCE_DIR")_*.tar.gz" -mtime +7 \
  | while read -r old_backup; do
    if rm "$old_backup"; then
      msg="Old backup deleted: $old_backup"
      echo "$msg"
      logger -t bash-backup -p user.info "$msg"
    else
      msg="Error: Failed to delete old backup '$old_backup'."
      echo "$msg" >&2
      logger -t bash-backup -p user.err "$msg"
    fi
  done

msg="Backup completed successfully: $DESTINATION_DIR/$bkp_filename"
echo "$msg"
logger -t bash-backup -p user.info "$msg"
