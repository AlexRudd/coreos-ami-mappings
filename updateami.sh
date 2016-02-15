#!/bin/bash

AMI_FEED_URL="https://coreos.com/dist/aws"
STABLE_CHANNEL="aws-stable.json"
BETA_CHANNEL="aws-beta.json"
ALPHA_CHANNEL="aws-alpha.json"

MAP_NAME="AWSRegionToAMI"

# check for required tools
hash jq 2>/dev/null || { echo >&2 "jq required (https://stedolan.github.io/jq/). Aborting."; exit 1; }
hash curl 2>/dev/null || { echo >&2 "curl required (https://curl.haxx.se/). Aborting."; exit 1; }
hash tr 2>/dev/null || { echo >&2 "curl required (https://curl.haxx.se/). Aborting."; exit 1; }

#check args
if [ "$#" -gt 1 ]; then
  channel=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  template_path=$2
else
  channel="stable"
  template_path=$1
fi 

# Select ami channel to use (defaults to stable)
case $channel in
"stable")
  feed_url="$AMI_FEED_URL/$STABLE_CHANNEL"
  ;;
"beta")
  feed_url="$AMI_FEED_URL/$BETA_CHANNEL"
  ;;
"alpha")
  feed_url="$AMI_FEED_URL/$ALPHA_CHANNEL"
  ;;
*)
  feed_url="$AMI_FEED_URL/$STABLE_CHANNEL"
  ;;
esac

# Get all files that match template path pattern
replace=true
case $template_path in
-h|--help )
  echo "usage: updateami [channel name...] [--map | <template file>]"
  echo "channel		stable (default), beta, alpha"
  echo "-m --map	outputs just the new AMI Mappings"
  echo "<template file>	a file path expansion of the cloudformation templates to update the Mappings of"
  exit 0
  ;;
-m|--map )
  replace=false
  ;;
*)
  if [ -z "$template_path" ]; then
    echo "No template path specified!"
    exit 1
  elif ! ls $template_path 1> /dev/null 2>&1; then
    echo "Invalid template path: $template_path"
    exit 1
  fi
  ;;
esac

# arg summary
echo "Using feed url: $feed_url"
echo "On template(s): $template_path"

# get all templates to be modified
templates=()
while IFS= read -d $'\0' -r file ; do
  templates=("${templates[@]}" "$file")
done < <(find ./ -name "$template_path" -print0)

#get new ami's
updated_amis="{\"Mappings\":{\"$MAP_NAME\":$(curl -s $feed_url | jq -c 'del(.release_info)')}}"
if ! $replace; then
  echo $updated_amis | jq '.'
  exit 0
fi

#loop through templates
for i in "${templates[@]}"
do
  content=$(cat $i | jq -c '.')
  new_content=$(echo $content | jq ". + $updated_amis")

  echo "$new_content" > $i.new
  mv $i.new $i
done
