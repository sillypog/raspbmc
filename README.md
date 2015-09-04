# raspbmc
Configuration for my raspbmc set up

## Transfering from Mac

- Rip files to iTunes with Apple Lossless to create .m4a files
- Folders should be arranged as Artist/Album/...
- cd into each directory of .m4a files and run alac_to_flac.sh
    `for f in *.m4a; do ffmpeg -i "$f" -c:a flac "${f%.m4a}.flac"; done`
- cd to level containing all artists.
- Transfer to pi with `scp -r . pi@X.X.X.X:/home/pi/cd_rips/`
- ssh into pi
- Launch a [tmux](http://www.sitepoint.com/tmux-a-simple-start/) session: 
- Run rips_to_folders.pl
