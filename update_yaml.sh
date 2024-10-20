#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <yaml_file> <image_tag> <custom_text>"
    exit 1
fi

YAML_FILE=$1
IMAGE_TAG=$2
CUSTOM_TEXT=$3

TEMP_FILE=$(mktemp)

while IFS= read -r line; do
    line=$(echo "$line" | sed "s/tag: \".*\"/tag: \"$IMAGE_TAG\"/")
    line=$(echo "$line" | sed "s/homepageText: \".*\"/homepageText: \"$CUSTOM_TEXT\"/")
    echo "$line" >> "$TEMP_FILE"
done < "$YAML_FILE"

mv "$TEMP_FILE" "$YAML_FILE"
