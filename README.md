# Raspbian
Configuration for my raspbian set up

## Setup
- Enable ssh on headless raspbian by touching a file called `ssh` to the card before turning on the pi.
- Get the network subnet with `ifconfig` on Mac.
- Get the IP address of the pi:
	`nmap -sn 192.168.1.0/24`
- ssh into the pi.
- Install git:
	`sudo apt-get update && apt-get install git`
- Clone this repo on to the pi
- Run setup.sh

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
