#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  SOURCE_DIR="$TEST_DIR/source"
  DESTINATION_DIR="$TEST_DIR/backup"

  mkdir -p "$SOURCE_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "fails when source and destination are not provided" {
  run ./backup.sh

  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "fails when source directory does not exist" {
  run ./backup.sh "$TEST_DIR/nonexistent" "$DESTINATION_DIR"

  [ "$status" -ne 0 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "creates destination directory if it does not exist" {
  run ./backup.sh "$SOURCE_DIR" "$DESTINATION_DIR"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION_DIR" ]
}

@test "creates archive containing expected files" {
  echo "hello backup" > "$SOURCE_DIR/file.txt"
  mkdir -p "$SOURCE_DIR/subdir"
  echo "nested" > "$SOURCE_DIR/subdir/nested.txt"

  run ./backup.sh "$SOURCE_DIR" "$DESTINATION_DIR"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Backup completed successfully"* ]]

  backup_file=$(find "$DESTINATION_DIR" -type f -name "*.tar.gz")
  [ -f "$backup_file" ]
  [[ "$output" == *"$backup_file"* ]]

  archive_listing=$(tar -tzf "$backup_file")
  [[ "$archive_listing" == *"source/file.txt"* ]]
  [[ "$archive_listing" == *"source/subdir/nested.txt"* ]]

  extract_dir="$TEST_DIR/extract"
  mkdir -p "$extract_dir"
  tar -xzf "$backup_file" -C "$extract_dir"

  [ "$(cat "$extract_dir/source/file.txt")" = "hello backup" ]
  [ "$(cat "$extract_dir/source/subdir/nested.txt")" = "nested" ]
}

@test "backup filename contains timestamp in expected format" {
  run ./backup.sh "$SOURCE_DIR" "$DESTINATION_DIR"

  [ "$status" -eq 0 ]

  backup_file=$(find "$DESTINATION_DIR" -type f -name "*.tar.gz")

  [[ "$backup_file" =~ $(basename "$SOURCE_DIR")_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}\.tar\.gz$ ]]
}

@test "tar command is executed with error handling" {

  mkdir -p "$DESTINATION_DIR"

  chmod -w "$DESTINATION_DIR" # Make destination directory unwritable to simulate error

  run ./backup.sh "$SOURCE_DIR" "$DESTINATION_DIR"

  [ "$status" -ne 0 ]
  [[ "$output" == *"Error: Failed to create backup archive"* ]]
}

@test "deletes backup files older than 7 days" {
  old_backup="$DESTINATION_DIR/source_2026-08-01_12-00-00.tar.gz"

  mkdir -p "$DESTINATION_DIR"
  touch "$old_backup"
  touch -d "8 days ago" "$old_backup"

  run ./backup.sh "$SOURCE_DIR" "$DESTINATION_DIR"

  [ "$status" -eq 0 ]
  [ ! -f "$old_backup" ]
}
