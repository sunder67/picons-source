ABOUT
=====

All the full resolution channel logos and their link to the actual channel (=serviceref) are kept up2date in this repository. The end result are picons for Enigma2 tuners and Kodi mediacenter in combination with a compatible PVR backend.

BUILDING THE PICONS
===================

Copy your `enigma2` folder, your `tvheadend` folder or your `channels.conf` file to `./build-input` and execute the script `./1-build-servicelist.sh`. If all goes well, you'll end up with a new file located in `/tmp` similar to [servicelist_enigma2](http://pastebin.com/FdHVDahq). Now execute `./2-build-picons.sh`, this might take a while, have a look at the folder `/tmp/picons-binaries` for the final result. By appending or removing the `.build` tag at the end of folders and files in `./build-source/backgrounds` you can control which background versions to build. By default everything is set to build.

On a default Ubuntu install, the following command `sudo apt-get install p7zip-full imagemagick pngnq librsvg2-bin binutils` should be sufficient, to get the required packages. Running the script on a Ubuntu Live system should be possible.

The repository can be downloaded [here](https://bitbucket.org/picons/picons-source/downloads).

GUIDELINES
==========

Below are some guidelines to keep in mind if you would like to contribute, when looking at the file `./build-source/srindex`, you'll get an idea on what to do next... Add new entries at the top of the list.

__Serviceref:__

- UPPERCASE
- Only the part `296_5_85_C00000` is used, the parts `1_0_1_` and `_0_0_0` must be removed

__Logo:__

- LOWERCASE
- NO spaces, fancy symbols or `.-+_`, except for the exceptions below
- Time sharing channels are seperated by `_`
- Sometimes it's useful to add a country code, do it by putting `-gbr`, `-deu` or `-...` at the end of the name. Country codes can be found [here](ftp://ftp.fu-berlin.de/doc/iso/iso3166-countrycodes.txt)
- If the channelname contains a `+`, use `+`, if it's a timeshift channel, use `plus1`
- Filetype `svg` is the way to go, otherwise `png`
- The resolution doesn't matter for `svg`, for `png` try to get it > 400px
- Quality should be as high as possible with transparancy
- A `white` version of a logo, should be placed in the folder `./build-source/tv/white` or `./build-source/radio/white`, a `black` version must always exist, a `white` version is optional
- Don't forget to put `tv/` or `radio/` in front of the logo's name in `./build-source/srindex`

SAMPLE OF SRINDEX
=================

```
1005_29_46_E080000=tv/eurosporthd
1006_29_46_E080000=tv/discoveryhdshowcase
1007_43_46_E080000=tv/tvnorgehd
1008_29_46_E080000=tv/bbchd
100E_3_1_E083163=tv/viasat6
1015_1D4C_FBFF_820000=tv/discoveryhd
1018_1D4C_FBFF_820000=tv/cielohd
1018_3_1_E083163=tv/novacinema
10_1_85_C00000=tv/fox
10_1_85_FFFF0000=tv/fox
1019_7DC_2_11A0000=tv/skymoviesboxoffice-gbr
1019_7EF_2_11A0000=tv/skymoviesboxoffice-gbr
101B_7DC_2_11A0000=tv/skymoviesboxoffice-gbr
101B_7EF_2_11A0000=tv/skymoviesboxoffice-gbr
101_E_85_C00000=tv/skybundesligahd-deu
```
