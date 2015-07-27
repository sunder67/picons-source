ABOUT
=====

All the full resolution channel logos and their link to the actual channel (=serviceref) are kept up2date in this repository. The end result are picons for Enigma2 tuners and Kodi mediacenter in combination with a compatible PVR backend.

BUILDING THE PICONS
===================

[Ubuntu](http://www.ubuntu.com/download) and [Cygwin on Windows](https://cygwin.com/install.html) are tested and supported platforms for building the picons. The required packages needed, besides the default installed ones, are shown below.

```
Ubuntu packages: imagemagick pngquant binutils librsvg2-bin [Optional: git]
Cygwin packages: imagemagick pngquant binutils rsvg [Optional: git]
```

The repository can be manually downloaded [here](https://github.com/picons/picons-source/archive/master.zip), or with the following command `git clone https://github.com/picons/picons-source.git`, if Git is installed. Use `/tmp` as your preferred location, to prevent problems arising from spaces in path names.

Copy your `enigma2` folder, your `tvheadend` folder or your `channels.conf` file to `./build-input` and execute the script `./1-build-servicelist.sh`. If all goes well, you'll end up with a new file located in the folder `./build-output`, similar to the file [servicelist_enigma2](https://gist.github.com/picons/c301a97d070797eb64b9). Now execute `./2-build-picons.sh`, this might take a while, have a look at the folder `./build-output/binaries` for the final result. By appending or removing the `.build` tag at the end of folders and files in `./build-source/backgrounds` you can control which background versions to build. By default everything is set to build.

Commands to start a build using icesat channellist:

```
git clone https://github.com/picons/picons-source.git "/tmp/picons-source"
git clone https://github.com/icesat/Enigma2-settings-13.0E-19.2E-23.5E-28.2E.git "/tmp/icesat" && mv "/tmp/icesat/E2 Settings 13.0E+19.2E+23.5E+28.2E" "/tmp/picons-source/build-input/enigma2" && rm -rf "/tmp/icesat"
cd "/tmp/picons-source"
./1-build-servicelist.sh
./2-build-picons.sh
```

CONTRIBUTING
============

So you would like to contribute? Have a look [here](https://github.com/picons/picons-source/blob/master/CONTRIBUTING.md).
