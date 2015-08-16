#!/bin/bash

serviceref_list="$1"
build_location="$2"
source_location="$3"
style="$4"

if [ -d "$build_location" ]; then
    rm -rf "$build_location"
fi

mkdir -p "$build_location/symlinks"

cd "$build_location/symlinks"

cat "$serviceref_list"*"$style" | while read line ; do

    IFS="|X|"
    line_data=($line)
    serviceref=$(echo ${line_data[0]} | tr -d [:space:])
    link_srp=$(echo ${line_data[2]} | tr -d [:space:])
    link_snp=$(echo ${line_data[3]} | tr -d [:space:])
    
    IFS="="
    link_srp=($link_srp)
    logo_srp=${link_srp[1]}
    link_snp=($link_snp)
    logo_snp=${link_snp[1]}
    snpname=${link_snp[0]}

    if [ ! "$logo_srp" = "--------" ]; then
        ln -s -f "$logo_srp.png" "$serviceref.png"

        logoname=$(basename "$logo_srp")
        dir=$(dirname "$logo_srp")

        mkdir -p "$build_location/logos/$dir/white"

        cp -n "$source_location/$dir/$logoname."* "$build_location/logos/$dir/"

        if [ -f "$source_location/$dir/white/$logoname."* ]; then
            cp -n "$source_location/$dir/white/$logoname."* "$build_location/logos/$dir/white/"
        fi
    fi

    if [ "$style" = "snp" ]; then
        if [ ! "$logo_snp" = "--------" ]; then
            ln -s -f "$logo_snp.png" "$snpname.png"

            logoname=$(basename "$logo_snp")
            dir=$(dirname "$logo_snp")

            mkdir -p "$build_location/logos/$dir/white"

            cp -n "$source_location/$dir/$logoname."* "$build_location/logos/$dir/"

            if [ -f "$source_location/$dir/white/$logoname."* ]; then
                cp -n "$source_location/$dir/white/$logoname."* "$build_location/logos/$dir/white/"
            fi
        fi
    fi
done
