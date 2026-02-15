#!/bin/bash

ERROR_LOG="errors.log"

# -------------------------------
# Help menu (Here Document)
# -------------------------------
show_help() {
cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Directory to search recursively
  -f <file>        File to search directly
  -k <keyword>     Keyword to search
  --help           Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
  $0 --help
EOF
}

# -------------------------------
# Error handler
# -------------------------------
log_error() {
    echo "$1" | tee -a "$ERROR_LOG" >&2
}

# -------------------------------
# Recursive function
# -------------------------------
search_recursive() {
    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*; do
        if [ -f "$item" ]; then
            grep -Hn "$keyword" "$item"
        elif [ -d "$item" ]; then
            search_recursive "$item" "$keyword"
        fi
    done
}

# -------------------------------
# Argument count check
# -------------------------------
if [ "$#" -eq 0 ]; then
    log_error "Error: No arguments provided"
    show_help
    exit 1
fi

# -------------------------------
# Parse arguments (getopts + --help)
# -------------------------------
DIR=""
FILE=""
KEYWORD=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d)
            DIR="$2"
            shift 2
            ;;
        -f)
            FILE="$2"
            shift 2
            ;;
        -k)
            KEYWORD="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "Invalid option: $1"
            exit 1
            ;;
    esac
done

# -------------------------------
# Input validation (Regex)
# -------------------------------
if [[ -z "$KEYWORD" || ! "$KEYWORD" =~ ^[a-zA-Z0-9_]+$ ]]; then
    log_error "Error: Invalid or empty keyword"
    exit 1
fi

# -------------------------------
# File search using Here String
# -------------------------------
if [ -n "$FILE" ]; then
    if [ ! -f "$FILE" ]; then
        log_error "Error: File not found - $FILE"
        exit 1
    fi

    echo "Searching '$KEYWORD' in file: $FILE"
    grep -n "$KEYWORD" <<< "$(cat "$FILE")"
    echo "Exit status: $?"
    exit 0
fi

# -------------------------------
# Directory recursive search
# -------------------------------
if [ -n "$DIR" ]; then
    if [ ! -d "$DIR" ]; then
        log_error "Error: Directory not found - $DIR"
        exit 1
    fi

    echo "Recursively searching '$KEYWORD' in directory: $DIR"
    search_recursive "$DIR" "$KEYWORD"
    echo "Exit status: $?"
    exit 0
fi

log_error "Error: Invalid arguments"
exit 1

