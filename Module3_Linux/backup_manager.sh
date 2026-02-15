#!/bin/bash

# ----------------------------
# Check command-line arguments
# ----------------------------
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 \"<source_dir>\" \"<backup_dir>\" \"<file_extension>\""
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXTENSION="$3"

# ----------------------------
# Validate source directory
# ----------------------------
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# ----------------------------
# Create backup directory if not exists
# ----------------------------
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create backup directory."
        exit 1
    fi
fi

# ----------------------------
# Enable nullglob for empty matches
# ----------------------------
shopt -s nullglob

# ----------------------------
# Globbing + Array
# ----------------------------
FILES=("$SOURCE_DIR"/*"$EXTENSION")

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No files with extension $EXTENSION found in source directory."
    exit 0
fi

# ----------------------------
# Export BACKUP_COUNT
# ----------------------------
export BACKUP_COUNT=0
TOTAL_SIZE=0

echo "Files to be backed up:"
echo "----------------------"

# ----------------------------
# Print file names and sizes
# ----------------------------
for file in "${FILES[@]}"; do
    size=$(stat -c %s "$file")
    echo "$(basename "$file") - ${size} bytes"
done

echo
echo "Starting backup..."
echo

# ----------------------------
# Backup logic
# ----------------------------
for file in "${FILES[@]}"; do
    filename=$(basename "$file")
    dest_file="$BACKUP_DIR/$filename"

    if [ -f "$dest_file" ]; then
        # Overwrite only if source is newer
        if [ "$file" -nt "$dest_file" ]; then
            cp "$file" "$dest_file"
            ((BACKUP_COUNT++))
            size=$(stat -c %s "$file")
            ((TOTAL_SIZE+=size))
        fi
    else
        cp "$file" "$dest_file"
        ((BACKUP_COUNT++))
        size=$(stat -c %s "$file")
        ((TOTAL_SIZE+=size))
    fi
done

# ----------------------------
# Generate report
# ----------------------------
REPORT_FILE="$BACKUP_DIR/backup_report.log"

{
    echo "Backup Summary Report"
    echo "---------------------"
    echo "Total files processed : ${#FILES[@]}"
    echo "Total files backed up : $BACKUP_COUNT"
    echo "Total size backed up  : $TOTAL_SIZE bytes"
    echo "Backup directory      : $BACKUP_DIR"
    echo "Backup completed on   : $(date)"
} > "$REPORT_FILE"
echo "Backup completed successfully."
echo "Report saved at: $REPORT_FILE"

