#!/bin/bash

serviceref_list="$1"
build_location="$2"
source_location="$3"

if [ -d "$build_location" ]; then
    rm -rf "$build_location"
fi

mkdir -p "$build_location/symlinks"

cd "$build_location/symlinks"

cat "$serviceref_list"* | grep -o '1_0_.*_.*_.*_.*_.*_0_0_0' | sort | uniq | while read serviceref ; do
    unique_id=$(echo "$serviceref" | sed -n -e 's/^1_0_[^_]*_//p' | sed -n -e 's/...._0_0_0$//p')
    logo=$(cat "$source_location/srindex" | grep -i -m 1 "$unique_id" | sed -n -e 's/.*=//p')

    if [ ! -z "$logo" ]; then
        ln -s "$logo.png" "$serviceref.png"

        logoname=$(basename "$logo")
        dir=$(dirname "$logo")

        mkdir -p "$build_location/logos/$dir/white"

        cp "$source_location/$dir/$logoname."* "$build_location/logos/$dir/"

        if [ -f "$source_location/$dir/white/$logoname."* ]; then
            cp "$source_location/$dir/white/$logoname."* "$build_location/logos/$dir/white/"
        fi
    fi
done
