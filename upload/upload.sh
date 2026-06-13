#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOSEND_DIR="$SCRIPT_DIR/tosend"
SENT_DIR="$SCRIPT_DIR/sent"

source "$SCRIPT_DIR/.env"

if [ -z "$API_KEY" ] || [ -z "$API_SECRET" ]; then
  echo "Remplis API_KEY et API_SECRET dans upload/.env"
  exit 1
fi

count=0
errors=0

for tag_dir in "$TOSEND_DIR"/*/; do
  [ -d "$tag_dir" ] || continue
  tag=$(basename "$tag_dir")
  mkdir -p "$SENT_DIR/$tag"

  for file in "$tag_dir"*; do
    [ -f "$file" ] || continue

    ext="${file##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    case "$ext_lower" in
      jpg|jpeg|png|heic|webp|gif) ;;
      *) continue ;;
    esac

    if [ "$ext_lower" = "heic" ]; then
      jpg_file="${file%.*}.jpg"
      sips -s format jpeg "$file" --out "$jpg_file" > /dev/null 2>&1
      rm "$file"
      file="$jpg_file"
      echo "  🔄 HEIC → JPEG"
    fi

    filename=$(basename "$file")
    name_no_ext="${filename%.*}"
    title=$(echo "$name_no_ext" | sed 's/[-_]/ /g' | sed 's/  */ /g')

    public_id="${tag}/$(echo "$title" | sed 's/ /-/g' | sed "s/[',]//g")"
    timestamp=$(date +%s)
    signature=$(printf "public_id=%s&tags=%s&timestamp=%s%s" "$public_id" "$tag" "$timestamp" "$API_SECRET" | shasum -a 1 | cut -d' ' -f1)

    response=$(curl -s -X POST \
      "https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/upload" \
      -F "file=@${file}" \
      -F "api_key=${API_KEY}" \
      -F "timestamp=${timestamp}" \
      -F "signature=${signature}" \
      -F "tags=${tag}" \
      -F "public_id=${public_id}")

    if echo "$response" | grep -q '"public_id"'; then
      mv "$file" "$SENT_DIR/$tag/"
      echo "  ✓ $filename → tag:$tag · titre: $title"
      count=$((count + 1))
    else
      error=$(echo "$response" | grep -o '"message":"[^"]*"' | head -1)
      echo "  ✗ $filename — $error"
      errors=$((errors + 1))
    fi

    sleep 1
  done
done

echo ""
echo "$count photo(s) envoyée(s), $errors erreur(s)"
