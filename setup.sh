#!/bin/bash

apt-get update && apt-get install -qy \
  ffmpeg \
  tmux \
  vim

mkdir $HOME/cd_rips

# On Raspbmc, the bin directory is added to the path through .profile
cp -r bin/ $HOME/bin/


