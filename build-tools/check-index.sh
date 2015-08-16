#!/bin/bash

source_location="$1"
style="$2"

cat "$source_location/$style-index" | sed -e 's/^.*=//g' | sort | uniq | while read line ; do
    if [ ! -f $source_location/$line.* ]; then
        echo The following logo does not exist: $line, found in $style-index
    fi
done
