for f in *.m4a; do ffmpeg -i "$f" -c:a flac "${f%.m4a}.flac"; done
