for FILE in *.flac;
do
        ffmpeg -i "$FILE" -ab 192k -map_metadata 0 "${FILE%.*}.mp3";
done
