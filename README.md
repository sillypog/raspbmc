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
- Create a new rsa key on the pi:
	`ssh-keygen -t rsa -b 4096 -C "email@address.com"`
- Add id_rsa.pub to the Github account.
- Clone this repo on to the pi
- Checkout the raspbian branch.
	`cd raspbmc && git checkout raspbian`
- Run `sudo ./setup.sh`

### Mount External drive.
Get the drive location, eg `/dev/sda5` and mount that to a folder.
When disconnecting, run `lsof` to confirm nothing is using that drive before unmounting.
```
sudo blkid
sudo mkdir /media/data
sudo mount -t ntfs-3g /dev/sda5 /media/data/
lsof /media/data
sudo umount /media/data
```

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

## Transfering to Mac

- On mac, run scp in quotes to handle spaces in filenames:
  `scp 'pi@X.X.X.X:"/home/pi/original with spaces.mp3"' copy.mp3`

## Downloading from Youtube

- https://github.com/rg3/youtube-dl
- `youtube-dl -x --audio-format mp3 https://www.youtube.com/watch?v=XXX`

## Restart

`sudo shutdown -r now`
