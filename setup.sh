#!/bin/bash

apt-get update && apt-get install -qy \
  ffmpeg \
  fuse \
  lsof \
  ntfs-3g \
  tmux \
  vim \
  youtube-dl

mkdir $HOME/cd_rips

# On Raspbmc, the bin directory is added to the path through .profile
cp -r bin/ $HOME/bin/


