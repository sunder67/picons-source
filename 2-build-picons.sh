#!/bin/bash

#sudo apt-get install p7zip-full imagemagick pngnq librsvg2-bin binutils

version="$(date +"%Y-%m-%d--%H-%M-%S")"

REPODIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCEDIR="$REPODIR/build-source"
TOOLSDIR="$REPODIR/build-tools"

TEMP="/tmp/picons-tmp"
TEMPBINARIES="/tmp/picons-binaries"
TEMPPICONS="$TEMP/picons"
TEMPSOURCEPICONS="$TEMP/sourcepicons"
TEMPSOURCEPICONSBLACK="$TEMPSOURCEPICONS/black"
TEMPSOURCEPICONSWHITE="$TEMPSOURCEPICONS/white"
TEMPSYMLINKS_LOGOS="$TEMP/symlinks_logos"

SERVICELIST="/tmp/servicelist_"

LOGFILE="/tmp/picons.log"
echo "$version" > "$LOGFILE"

chmod -R 755 "$TOOLSDIR"/*.sh

"$TOOLSDIR"/check-images.sh "$SOURCEDIR/tv"
"$TOOLSDIR"/check-images.sh "$SOURCEDIR/radio"

if [ -d "$TEMP" ]; then
    rm -rf "$TEMP"
fi
mkdir "$TEMP"

if ! [ -d "$TEMPBINARIES" ]; then
    mkdir "$TEMPBINARIES"
else
    rm -rf "$TEMPBINARIES"
    mkdir "$TEMPBINARIES"
fi

echo "$(date +"%H:%M:%S") - Creating symlinks and copying logos"
"$TOOLSDIR"/create-symlinks+copy-logos.sh "$SERVICELIST" "$TEMPSYMLINKS_LOGOS" "$SOURCEDIR"

echo "$(date +"%H:%M:%S") - Converting svg files"
mkdir -p "$TEMPSOURCEPICONSBLACK/tv"
mkdir -p "$TEMPSOURCEPICONSBLACK/radio"
mkdir -p "$TEMPSOURCEPICONSWHITE/tv"
mkdir -p "$TEMPSOURCEPICONSWHITE/radio"

cp "$TEMPSYMLINKS_LOGOS/logos/tv/"*.* "$TEMPSOURCEPICONSBLACK/tv" 2>> "$LOGFILE"
cp "$TEMPSYMLINKS_LOGOS/logos/radio/"*.* "$TEMPSOURCEPICONSBLACK/radio" 2>> "$LOGFILE"

for file in $(find "$TEMPSOURCEPICONS" -type f -name '*.svg'); do
    rsvg-convert -w 400 -h 400 -a -f png -o ${file%.*}.png "$file"
    rm "$file"
done

cp "$TEMPSOURCEPICONSBLACK/tv/"*.* "$TEMPSOURCEPICONSWHITE/tv" 2>> "$LOGFILE"
cp "$TEMPSOURCEPICONSBLACK/radio/"*.* "$TEMPSOURCEPICONSWHITE/radio" 2>> "$LOGFILE"
cp "$TEMPSYMLINKS_LOGOS/logos/tv/white/"*.* "$TEMPSOURCEPICONSWHITE/tv" 2>> "$LOGFILE"
cp "$TEMPSYMLINKS_LOGOS/logos/radio/white/"*.* "$TEMPSOURCEPICONSWHITE/radio" 2>> "$LOGFILE"

for file in $(find "$TEMPSOURCEPICONS" -type f -name '*.svg'); do
    rsvg-convert -w 400 -h 400 -a -f png -o ${file%.*}.png "$file"
    rm "$file"
done

for background in "$SOURCEDIR/backgrounds/"*.build ; do

    backgroundname=${background%.*}
    backgroundname=${backgroundname##*/}

    for backgroundcolor in "$SOURCEDIR/backgrounds/$backgroundname.build/"*.build ; do

        backgroundcolorname=${backgroundcolor%.*}
        backgroundcolorname=${backgroundcolorname%.*}
        backgroundcolorname=${backgroundcolorname##*/}

        echo "$(date +"%H:%M:%S") -----------------------------------------------------------"
        echo "$(date +"%H:%M:%S") - Creating picons: $backgroundname.$backgroundcolorname"

        if [[ "$backgroundcolorname" == *-white* ]]; then
            USETEMPSOURCEPICONS="$TEMPSOURCEPICONSWHITE"
        else
            USETEMPSOURCEPICONS="$TEMPSOURCEPICONSBLACK"
        fi

        mkdir -p "$TEMPPICONS/picon"

        for directory in "$USETEMPSOURCEPICONS/"* ; do
            if [ -d "$directory" ]; then
                directory=${directory##*/}
                for logo in "$USETEMPSOURCEPICONS/$directory/"*.png ; do
                    if [ -f "$logo" ]; then
                        logoname=${logo##*/}
                        logoname=${logoname%.*}
                        fullfilepath="$TEMPPICONS/picon/$directory/$logoname.png"

                        if ! [ -d "$TEMPPICONS/picon/$directory" ]; then
                            mkdir -p "$TEMPPICONS/picon/$directory"
                        fi

                        case "$backgroundname" in
                            "70x53")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="70x53"; else resize="62x45"; fi
                                extent="70x53"
                                compress="pngnq -g 2.2 -s 1"
                                ;;
                            "100x60")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="100x60"; else resize="86x46"; fi
                                extent="100x60"
                                compress="pngnq -g 2.2 -s 1"
                                ;;
                            "220x132")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="220x132"; else resize="189x101"; fi
                                extent="220x132"
                                compress="pngnq -g 2.2 -s 1"
                                ;;
                            "400x240")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="400x240"; else resize="369x221"; fi
                                extent="400x240"
                                compress="pngnq -g 2.2 -s 1"
                                ;;
                            "kodi")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="256x256"; else resize="226x226"; fi
                                extent="256x256"
                                compress="cat"
                                ;;
                        esac

                        convert "$backgroundcolor" \( "$logo" -background none -bordercolor none -border 100 -trim -resize $resize -gravity center -extent $extent +repage \) -layers merge - 2>> "$LOGFILE" | $compress > "$fullfilepath" 2>> "$LOGFILE"
                    fi
                done
            fi
        done

        if [ "$backgroundname" = "70x53" ] || [ "$backgroundname" = "100x60" ] || [ "$backgroundname" = "220x132" ] || [ "$backgroundname" = "400x240" ]; then

            echo "$(date +"%H:%M:%S") - Copying symlinks: $backgroundname.$backgroundcolorname"
            cp -P "$TEMPSYMLINKS_LOGOS/symlinks/1_"* "$TEMPPICONS/picon" 2>> "$LOGFILE"

            echo "$(date +"%H:%M:%S") - Creating ipk: $backgroundname.$backgroundcolorname"
            mkdir "$TEMPPICONS/CONTROL"
            echo "Package: enigma2-plugin-picons-tv-$backgroundname.$backgroundcolorname" > "$TEMPPICONS/CONTROL/control"
            echo "Version: $version" >> "$TEMPPICONS/CONTROL/control"
            echo "Section: base" >> "$TEMPPICONS/CONTROL/control"
            echo "Architecture: all" >> "$TEMPPICONS/CONTROL/control"
            echo "Maintainer: http://picons.bitbucket.org" >> "$TEMPPICONS/CONTROL/control"
            echo "Source: https://bitbucket.org/picons/logos/src" >> "$TEMPPICONS/CONTROL/control"
            echo "Description: $backgroundname Picons ($backgroundcolorname)" >> "$TEMPPICONS/CONTROL/control"
            echo "OE: enigma2-plugin-picons-tv-$backgroundname.$backgroundcolorname" >> "$TEMPPICONS/CONTROL/control"
            echo "HomePage: http://picons.bitbucket.org" >> "$TEMPPICONS/CONTROL/control"
            echo "License: unknown" >> "$TEMPPICONS/CONTROL/control"
            echo "Priority: optional" >> "$TEMPPICONS/CONTROL/control"
            chmod -R 777 "$TEMPPICONS"
            "$TOOLSDIR"/ipkg-build.sh -o root -g root "$TEMPPICONS" "$TEMPBINARIES" >> "$LOGFILE"

            echo "$(date +"%H:%M:%S") - Creating tar.bz2: $backgroundname.$backgroundcolorname"
            mkdir "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"
            cp -P -r "$TEMPPICONS/picon/"* "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version" 2>> "$LOGFILE"
            chmod -R 777 "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"
            tar --owner=root --group=root -cjf "$TEMPBINARIES/$backgroundname.$backgroundcolorname"\_"$version.tar.bz2" -C "$TEMPPICONS" "$backgroundname.$backgroundcolorname"\_"$version"
            rm -rf "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"

            echo "$(date +"%H:%M:%S") - Creating 7z: $backgroundname.$backgroundcolorname"
            mkdir "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"
            cp -H "$TEMPPICONS/picon/1_"*.png "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version" 2>> "$LOGFILE"
            chmod -R 777 "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"
            7z a -t7z -mx9 "$TEMPBINARIES/$backgroundname.$backgroundcolorname"\_"$version.7z" "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version" >> "$LOGFILE"

        fi

        if [ "$backgroundname" = "kodi" ]; then

            echo "$(date +"%H:%M:%S") - Copying symlinks: $backgroundname.$backgroundcolorname"
            cp -P "$TEMPSYMLINKS_LOGOS/symlinks/1_"* "$TEMPPICONS/picon" 2>> "$LOGFILE"

            echo "$(date +"%H:%M:%S") - Creating tar.bz2: $backgroundname.$backgroundcolorname"
            mkdir "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"
            cp -P -r "$TEMPPICONS/picon/"* "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version" 2>> "$LOGFILE"
            chmod -R 777 "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"
            tar --owner=root --group=root -cjf "$TEMPBINARIES/$backgroundname.$backgroundcolorname"\_"$version.tar.bz2" -C "$TEMPPICONS" "$backgroundname.$backgroundcolorname"\_"$version"
            rm -rf "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"

            echo "$(date +"%H:%M:%S") - Creating 7z: $backgroundname.$backgroundcolorname"
            mkdir "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"
            cp -H "$TEMPPICONS/picon/1_"*.png "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version" 2>> "$LOGFILE"
            chmod -R 777 "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version"
            7z a -t7z -mx9 "$TEMPBINARIES/$backgroundname.$backgroundcolorname"\_"$version.7z" "$TEMPPICONS/$backgroundname.$backgroundcolorname"\_"$version" >> "$LOGFILE"

        fi

        rm -rf "$TEMPPICONS"

    done

done

touchstamp=`echo ${version//-/} | rev | cut -c 3- | rev`.`echo ${version//-/} | cut -c 13-`
for file in "$TEMPBINARIES/"* ; do
    touch -t "$touchstamp" "$file"
done

if [ -d "$TEMP" ]; then
    rm -rf "$TEMP"
fi

read -p "Press any key to exit..." -n1 -s
