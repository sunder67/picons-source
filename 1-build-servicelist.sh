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
index=$(<"$location/build-source/$style-index")

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
    lamedb=$(<"$location/build-input/enigma2/lamedb")

    cat "$location/build-input/enigma2/"*bouquet.* | grep -o '#SERVICE .*:0:.*:.*:.*:.*:.*:0:0:0' | sed -e 's/#SERVICE //g' -e 's/.*/\U&\E/' -e 's/:/_/g' | sort | uniq | while read serviceref ; do
        serviceref_id=$(sed -e 's/^[^_]*_0_[^_]*_//g' -e 's/_0_0_0$//g' <<< "$serviceref")
        unique_id=${serviceref_id%????}
        channelref=(${serviceref//_/ })
        channelname=$(grep -i -A1 "${channelref[3]}:.*${channelref[6]}:.*${channelref[4]}:.*${channelref[5]}:.*:.*" <<< "$lamedb" | sed -n "2p" | iconv -c -f utf-8 -t ascii | sed -e 's/^[ \t]*//' -e 's/|//g' -e 's/§//g')

        logo_srp=$(grep -i -m 1 "^$unique_id" <<< "$index" | sed -n -e 's/.*=//p')
        if [ -z "$logo_srp" ]; then logo_srp="--------"; fi

        if [ "$style" = "snp" ]; then
            snpname=$(sed -e 's/&/and/g' -e 's/*/star/g' -e 's/+/plus/g' -e 's/\(.*\)/\L\1/g' -e 's/[^a-z0-9]//g' <<< "$channelname")
            if [ -z "$snpname" ]; then snpname="--------"; fi
            logo_snp=$(grep -i -m 1 "^$snpname=" <<< "$index" | sed -n -e 's/.*=//p')
            if [ -z "$logo_snp" ]; then logo_snp="--------"; fi
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp\t$snpname=$logo_snp" >> "$tempfile"
        else
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp" >> "$tempfile"
        fi
        ((currentline++))
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
        serviceref=$(grep -o '1_0_.*_.*_.*_.*_.*_0_0_0' "$channelfile")
        serviceref_id=$(sed -e 's/^[^_]*_0_[^_]*_//g' -e 's/_0_0_0$//g' <<< "$serviceref")
        unique_id=${serviceref_id%????}
        tvhservice=$(grep -A1 'services' "$channelfile" | sed -n "2p" | sed -e 's/"//g' -e 's/,//g')
        channelname=$(grep 'svcname' $(find "$location/build-input/tvheadend" -type f -name $tvhservice) | sed -e 's/.*"svcname": "//g' -e 's/",//g' | iconv -c -f utf-8 -t ascii | sed -e 's/^[ \t]*//' -e 's/|//g' -e 's/§//g')

        logo_srp=$(grep -i -m 1 "^$unique_id" <<< "$index" | sed -n -e 's/.*=//p')
        if [ -z "$logo_srp" ]; then logo_srp="--------"; fi

        if [ "$style" = "snp" ]; then
            snpname=$(sed -e 's/&/and/g' -e 's/*/star/g' -e 's/+/plus/g' -e 's/\(.*\)/\L\1/g' -e 's/[^a-z0-9]//g' <<< "$channelname")
            if [ -z "$snpname" ]; then snpname="--------"; fi
            logo_snp=$(grep -i -m 1 "^$snpname=" <<< "$index" | sed -n -e 's/.*=//p')
            if [ -z "$logo_snp" ]; then logo_snp="--------"; fi
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp\t$snpname=$logo_snp" >> "$tempfile"
        else
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp" >> "$tempfile"
        fi
        ((currentline++))
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

        sid=$(printf "%x\n" ${vdrchannel[9]})
        tid=$(printf "%x\n" ${vdrchannel[11]})
        nid=$(printf "%x\n" ${vdrchannel[10]})

        case ${vdrchannel[3]} in
            *"W") namespace=$(printf "%x\n" $(sed -e 's/S//' -e 's/W//' <<< "${vdrchannel[3]}" | awk '{printf "%.0f\n", 3600-($1*10)}'));;
            *"E") namespace=$(printf "%x\n" $(sed -e 's/S//' -e 's/E//' <<< "${vdrchannel[3]}" | awk '{printf "%.0f\n", $1*10}'));;
            "T") namespace="EEEE";;
            "C") namespace="FFFF";;
        esac
        case ${vdrchannel[5]} in
            "0") channeltype="2";;
            *"=2") channeltype="1";;
            *"=27") channeltype="19";;
        esac

        unique_id=$(sed -e 's/.*/\U&\E/' <<< "$sid"'_'"$tid"'_'"$nid"'_'"$namespace")
        serviceref='1_0_'"$channeltype"'_'"$unique_id"'0000_0_0_0'
        serviceref_id="$unique_id"'0000'
        channelname=(${vdrchannel[0]})
        channelname=$(iconv -c -f utf-8 -t ascii <<< "${channelname[0]}" | sed -e 's/^[ \t]*//' -e 's/|//g' -e 's/§//g')

        logo_srp=$(grep -i -m 1 "^$unique_id" <<< "$index" | sed -n -e 's/.*=//p')
        if [ -z "$logo_srp" ]; then logo_srp="--------"; fi

        if [ "$style" = "snp" ]; then
            snpname=$(sed -e 's/&/and/g' -e 's/*/star/g' -e 's/+/plus/g' -e 's/\(.*\)/\L\1/g' -e 's/[^a-z0-9]//g' <<< "$channelname")
            if [ -z "$snpname" ]; then snpname="--------"; fi
            logo_snp=$(grep -i -m 1 "^$snpname=" <<< "$index" | sed -n -e 's/.*=//p')
            if [ -z "$logo_snp" ]; then logo_snp="--------"; fi
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp\t$snpname=$logo_snp" >> "$tempfile"
        else
            echo -e "$serviceref\t$channelname\t$serviceref_id=$logo_srp" >> "$tempfile"
        fi
        ((currentline++))
        echo -ne "Channels found: $currentline"\\r
    done

    cat "$tempfile" | sort -t $'\t' -k 2,2 | uniq | sed -e 's/\t/§|/g' | column -t -s $'§' | sed -e 's/|/  |  /g' > "$file"
    rm "$tempfile"
    echo "VDR: Exported to $file"
else
    echo "VDR: File ./build-input/channels.conf not found"
fi

read -p "Press any key to exit..." -n1 -s
