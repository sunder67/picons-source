#!/bin/bash

if [ -z "$1" ]; then
    echo "Which style are you going to build?"
    select choice in "Service Reference" "Service Name" "Exit"; do
        case $choice in
            "Service Reference" ) style=srp; break;;
            "Service Name" ) style=snp; break;;
            "Exit" ) exit;;
        esac
    done
else
    style=$1
fi

location=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [ -d "/dev/shm" ]; then
    temp="/dev/shm"
else
    temp="/tmp"
fi

#Enigma2
if [ -d "$location/build-input/enigma2" ]; then
    echo "Enigma2: Converting channellist..."

    file="$location/build-output/servicelist-enigma2-$style"
    tempfile="$temp/$(echo $RANDOM)"

    cat "$location/build-input/enigma2/"*bouquet.* | grep -o '#SERVICE .*:0:.*:.*:.*:.*:.*:0:0:0' | sed -e 's/#SERVICE //g' -e 's/.*/\U&\E/' -e 's/:/_/g' | sort | uniq | while read serviceref ; do
        unique_id=$(echo "$serviceref" | sed -n -e 's/^[^_]*_0_[^_]*_//p' | sed -n -e 's/...._0_0_0$//p')
        serviceref_id=$(echo "$serviceref" | sed -n -e 's/^[^_]*_0_[^_]*_//p' | sed -n -e 's/_0_0_0$//p')
        channelref=(${serviceref//_/ })
        channelname=$(cat "$location/build-input/enigma2/lamedb" | grep -i -A1 "${channelref[3]}:.*${channelref[6]}:.*${channelref[4]}:.*${channelref[5]}:.*:.*" | sed -n "2p" | iconv -c -f utf-8 -t ascii | sed -e 's/^[ \t]*//')
        channelname=$(echo "$channelname" | sed -e 's/|//g' -e 's/§//g')
        snpname=$(echo "$channelname" | sed -e 's/&/and/g' -e 's/*/star/g' -e 's/+/plus/g' -e 's/\(.*\)/\L\1/g' -e 's/[^a-z0-9]//g')
        if [ -z "$snpname" ]; then
            snpname="--------"
        fi
        logo_srp=$(cat "$location/build-source/$style-index" | grep -i -m 1 "^$unique_id" | sed -n -e 's/.*=//p')
        if [ -z "$logo_srp" ]; then
            logo_srp="--------"
        fi
        logo_snp=$(cat "$location/build-source/$style-index" | grep -i -m 1 "^$snpname=" | sed -n -e 's/.*=//p')
        if [ -z "$logo_snp" ]; then
            logo_snp="--------"
        fi
        if [ "$style" = "snp" ]; then
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp\t$snpname=$logo_snp" >> "$tempfile"
        else
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp" >> "$tempfile"
        fi
        currentline=$((currentline+1))
        echo -ne "Channels found: $currentline"\\r
    done

    cat "$tempfile" | sort -t $'\t' -k 2,2 | uniq | sed -e 's/\t/§|/g' | column -t -s $'§' | sed -e 's/|/  |  /g' > "$file"
    rm "$tempfile"
    echo "Enigma2: Exported to $file"
else
    echo "Enigma2: Folder ./build-input/enigma2 not found"
fi

#TvHeadend
if [ -d "$location/build-input/tvheadend" ]; then
    echo "TvHeadend: Converting channellist..."

    file="$location/build-output/servicelist-tvheadend-$style"
    tempfile="$temp/$(echo $RANDOM)"

    for channelfile in "$location/build-input/tvheadend/channel/config/"* ; do
        serviceref=$(cat $channelfile | grep -o '1_0_.*_.*_.*_.*_.*_0_0_0')
        unique_id=$(echo "$serviceref" | sed -n -e 's/^1_0_[^_]*_//p' | sed -n -e 's/...._0_0_0$//p')
        serviceref_id=$(echo "$serviceref" | sed -n -e 's/^[^_]*_0_[^_]*_//p' | sed -n -e 's/_0_0_0$//p')
        tvhservice=$(cat $channelfile | grep -A1 'services' | sed -n "2p" | sed -e 's/"//g' -e 's/,//g')
        channelname=$(cat $(find "$location/build-input/tvheadend" -type f -name $tvhservice) | grep 'svcname' | sed -e 's/.*"svcname": "//g' -e 's/",//g' | iconv -c -f utf-8 -t ascii | sed -e 's/^[ \t]*//')
        channelname=$(echo "$channelname" | sed -e 's/|//g' -e 's/§//g')
        snpname=$(echo "$channelname" | sed -e 's/&/and/g' -e 's/*/star/g' -e 's/+/plus/g' -e 's/\(.*\)/\L\1/g' -e 's/[^a-z0-9]//g')
        if [ -z "$snpname" ]; then
            snpname="--------"
        fi
        logo_srp=$(cat "$location/build-source/$style-index" | grep -i -m 1 "^$unique_id" | sed -n -e 's/.*=//p')
        if [ -z "$logo_srp" ]; then
            logo_srp="--------"
        fi
        logo_snp=$(cat "$location/build-source/$style-index" | grep -i -m 1 "^$snpname=" | sed -n -e 's/.*=//p')
        if [ -z "$logo_snp" ]; then
            logo_snp="--------"
        fi
        if [ "$style" = "snp" ]; then
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp\t$snpname=$logo_snp" >> "$tempfile"
        else
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp" >> "$tempfile"
        fi
        currentline=$((currentline+1))
        echo -ne "Channels found: $currentline"\\r
    done

    cat "$tempfile" | sort -t $'\t' -k 2,2 | uniq | sed -e 's/\t/§|/g' | column -t -s $'§' | sed -e 's/|/  |  /g' > "$file"
    rm "$tempfile"
    echo "TvHeadend: Exported to $file"
else
    echo "TvHeadend: Folder ./build-input/tvheadend not found"
fi

#VDR
if [ -f "$location/build-input/channels.conf" ]; then
    echo "VDR: Converting channellist..."

    file="$location/build-output/servicelist-vdr-$style"
    tempfile="$temp/$(echo $RANDOM)"

    cat "$location/build-input/channels.conf" | grep -o '.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:.*:0' | sort | uniq | while read channel ; do
        IFS=":"
        vdrchannel=($channel)
        IFS=";"
        channelname=(${vdrchannel[0]})
        channelname=$(echo ${channelname[0]} | iconv -c -f utf-8 -t ascii | sed -e 's/^[ \t]*//')
        channelname=$(echo "$channelname" | sed -e 's/|//g' -e 's/§//g')

        sid=$(printf "%x\n" ${vdrchannel[9]})
        tid=$(printf "%x\n" ${vdrchannel[11]})
        nid=$(printf "%x\n" ${vdrchannel[10]})

        case ${vdrchannel[3]} in
            *"W") namespace=$(printf "%x\n" $(echo "${vdrchannel[3]}" | sed -e 's/S//' -e 's/W//' | awk '{printf "%.0f\n", 3600-($1*10)}'));;
            *"E") namespace=$(printf "%x\n" $(echo "${vdrchannel[3]}" | sed -e 's/S//' -e 's/E//' | awk '{printf "%.0f\n", $1*10}'));;
            "T") namespace="EEEE";;
            "C") namespace="FFFF";;
        esac
        case ${vdrchannel[5]} in
            "0") channeltype="2";;
            *"=2") channeltype="1";;
            *"=27") channeltype="19";;
        esac

        unique_id=$(echo "$sid"'_'"$tid"'_'"$nid"'_'"$namespace" | sed -e 's/.*/\U&\E/')
        snpname=$(echo "$channelname" | sed -e 's/&/and/g' -e 's/*/star/g' -e 's/+/plus/g' -e 's/\(.*\)/\L\1/g' -e 's/[^a-z0-9]//g')
        if [ -z "$snpname" ]; then
            snpname="--------"
        fi
        logo_srp=$(cat "$location/build-source/$style-index" | grep -i -m 1 "^$unique_id" | sed -n -e 's/.*=//p')
        if [ -z "$logo_srp" ]; then
            logo_srp="--------"
        fi
        logo_snp=$(cat "$location/build-source/$style-index" | grep -i -m 1 "^$snpname=" | sed -n -e 's/.*=//p')
        if [ -z "$logo_snp" ]; then
            logo_snp="--------"
        fi
        if [ "$style" = "snp" ]; then
            echo -e '1_0_'"$channeltype"'_'"$unique_id"'0000_0_0_0'"\t$channelname\t$unique_id"'0000'"=$logo_srp\t$snpname=$logo_snp" >> "$tempfile"
        else
            echo -e '1_0_'"$channeltype"'_'"$unique_id"'0000_0_0_0'"\t$channelname\t$unique_id"'0000'"=$logo_srp" >> "$tempfile"
        fi
        currentline=$((currentline+1))
        echo -ne "Channels found: $currentline"\\r
    done

    cat "$tempfile" | sort -t $'\t' -k 2,2 | uniq | sed -e 's/\t/§|/g' | column -t -s $'§' | sed -e 's/|/  |  /g' > "$file"
    rm "$tempfile"
    echo "VDR: Exported to $file"
else
    echo "VDR: File ./build-input/channels.conf not found"
fi

read -p "Press any key to exit..." -n1 -s
