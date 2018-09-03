#! /usr/bin/env bash
# by omen23 © 2018 
# -> CXX rewrite with libav coming soon… (= 
# (was supposed to be) just a one liner to put my movie in a matroska container so my TV likes it (ten-split/chapters, fast rwnd and fwd)
# USE: container(most likely mp4) will be changed to matroska (mkv) - original file can be shredded, moved to trash or left intact
# NOTE this is written with a GNU/Linux OS using KDE as GUI in mind - the "move to trash" function uses kioclient - I have no clue if those work with GTK3+ systems
trap 'echo; echo "Caught signal..."; echo "Exiting..."; exit 130' SIGTSTP SIGINT SIGTERM SIGHUP

# ------------------
#    YESNOPROMPT
# ------------------
readYes()
{
while read -r -n 1 answer; do
  if [[ $answer = [JjNnYy] ]]; then
    [[ $answer = [JjYy] ]] && retval=0
    [[ $answer = [Nn] ]] && retval=1
    break
  fi
done
echo # just a final linefeed, optics...
return $retval
}

echo "##########################################################"
echo "#### \"toMatroska\" container conversion script         ####"
echo -e "##########################################################\n"

read -p "Please specify the input file and press ENTER: " INFILE
echo "Codec details and the file ending will be added automatically"
read -p "Now specify the name you want for the output file (omit final dot, file format and codec details): " OUTFILE
OUTFILE="/home/$USER/Films/$OUTFILE.x264.AAC.mkv" # set the absolute path 

ffmpeg -i "$INFILE" -c:v copy -c:a copy "$OUTFILE" -v -8
if [[ $? -eq 0 ]]; then
  echo "$OUTFILE - `date`" >> "/home/$USER/Films/filmlist.txt"
  echo -e "\nContainer conversion success!"
  echo -e "\"$OUTFILE\" is ready to be played on the TV!\n"
  echo -n "Do you want to secure-delete the input file with shred? (Y/N)? "
  if readYes; then
    echo "Deleting \"$INFILE\" with 3 shred overwrites and a final overwrite with zeros to hide shred..."
    shred -zuv "$INFILE"
    echo "All done - exiting..."
    exit 0
  else [[ $answer = [Nn] ]]
    echo -n "Do you want to move the input file to trash? (Y/N)? "
    if readYes; then
      echo "Moving \"$INFILE\" to trash..."
      # idk maybe make this more portable but I dont wanna – mv "home/$USER/.local/share/Trash/files/"
      # someone please let me know if GNOME Shell and Unity use the same trash:/ folder or the counterpart of kioclient
      kioclient move "$INFILE" trash:/ 
      echo "\"$INFILE\" is in trash - all done - exiting..."
      exit 0
    fi
  fi
echo -e "The original input file \"$INFILE\" will stay intact.\n"
echo "All done - exiting..."
exit 0
fi
