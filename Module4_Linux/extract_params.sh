#!/bin/bash

# Check argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="output.txt"

# Check file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found"
    exit 1
fi

# Clear output file
> "$OUTPUT_FILE"

while IFS= read -r line; do

    if echo "$line" | grep -q '"frame.time"'; then
        value=$(echo "$line" | cut -d':' -f2- | sed 's/^ *//')
        echo "\"frame.time\": \"$value\"," >> "$OUTPUT_FILE"
    fi

    if echo "$line" | grep -q '"wlan.fc.type"'; then
        value=$(echo "$line" | cut -d':' -f2- | sed 's/^ *//')
        echo "\"wlan.fc.type\": \"$value\"," >> "$OUTPUT_FILE"
    fi

    if echo "$line" | grep -q '"wlan.fc.subtype"'; then
        value=$(echo "$line" | cut -d':' -f2- | sed 's/^ *//')
        echo "\"wlan.fc.subtype\": \"$value\"" >> "$OUTPUT_FILE"
    fi

done < "$INPUT_FILE"

echo "Extraction completed. Output saved to output.txt"

