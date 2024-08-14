for z in *.zip; do unzip -d Movies "$z"; rm "$z"; done

rm *.torrent
