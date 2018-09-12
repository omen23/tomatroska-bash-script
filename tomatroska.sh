#! /usr/bin/env bash
# by omen23 © 2018 
# -> CXX rewrite with libavcodec coming soon… (= 
# (was supposed to be) just a one liner to put my movie in a matroska container so my TV likes it (ten-split/chapters, fast rwnd and fwd)
# USE: container(most likely mp4) will be changed to matroska (mkv) - original file can be shredded, moved to trash or left intact

# ------------------
#   SIGNAL HANDLER
# ------------------
trap 'echo; echo "Caught signal..."; echo "Exiting..."; exit 130' SIGTSTP SIGINT SIGTERM SIGHUP
# ------------------
#    DESKTOP CHECK
# ------------------
desktop_session_print() {
if [ "$DESKTOP_SESSION" != "" ] ; then             
  echo "$DESKTOP_SESSION"
  return 0  
fi
return 1
} 
# ------------------
#    YESNOPROMPT
# ------------------
readYes()
{
while read -r answer; do
  if [[ ${answer:0:1} = [YyNnJj] ]]; then
    [[ ${answer:0:1} = [JjYy] ]] && retval=0
    [[ ${answer:0:1} = [Nn] ]] && retval=1
    break
  fi
done
return $retval
}

echo "##########################################################"
echo "#### \"toMatroska\" container conversion script         ####"
echo -e "##########################################################\n"

read -p "Please specify the input file and press ENTER: " INFILE
if [[ ! -a $INFILE ]]; then
  echo "The specified infile does not exist – maybe you called the script in the wrong directory."
  exit 127
fi
echo "Codec details and the file ending will be added automatically"
echo "(omit final dot, file format and codec details)"
read -p "Now specify the name you want for the output file: " OUTFILE
OUTFILE="/home/$USER/Films/$OUTFILE.x264.AAC.mkv" # set the absolute path 

ffmpeg -i "$INFILE" -c:v copy -c:a copy "$OUTFILE" -v -8
if [[ $? -eq 0 ]]; then
  echo "\"${OUTFILE##/*/}\" — `date`" >> "/home/$USER/Films/filmlist.txt"
  echo -e "\nContainer conversion successful!"
  echo -e "\"$OUTFILE\" is ready to be played on the TV!\n"
  notify-send "Container conversion successful" "\"${OUTFILE##/*/}\" is ready to be played on the TV!" -i preferences-desktop-notification -t 7500 #-i dialog-information # 
  
  echo -n "Do you want to secure-delete the input file with shred? (Y/N)? "
  if readYes; then
    echo "Deleting \"$INFILE\" with 3 shred overwrites and a final overwrite with zeros to hide shred..."
    shred -zuv "$INFILE"
    echo "All done - exiting..."
    notify-send "All done!" "\"$INFILE\" securely deleted with shred." -i face-smile -t 6000
    exit 0
  fi
  
  echo -n "Do you want to move the input file to trash? (Y/N)? "
  if readYes; then
    echo "Trying to move \"$INFILE\" to trash..."
    GUI=`desktop_session_print`
    # for the nerds [[ $? -ne 0 ]] && echo "No GUI found - exiting..." && exit 127
    case "$GUI" in 
      plasma)
        kioclient move "$INFILE" trash:/
        echo "\"$INFILE\" is in trash - all done - exiting..."
        notify-send "All done!" "\"$INFILE\" is in trash."  -i face-smile -t 6000
        exit 0
        ;;
      gnome)
        gvfs-trash "$INFILE"
        echo "\"$INFILE\" is in trash - all done - exiting..."
        notify-send "All done!" "\"$INFILE\" is in trash."  -i face-smile -t 6000
        exit 0
        ;;
      *)
        echo "Could not determine running desktop session — please delete the file yourself."
        notify-send "Could not determine GUI" "Please delete \"$INFILE\" yourself." -t 6000
        exit 0
        ;;
    esac
  fi  

echo "The original input file \"$INFILE\" will stay intact."
notify-send "All done!" "The original input file \"$INFILE\" will stay intact." -i face-smile -t 6000
echo "All done - exiting..."
exit 0   
else
  exit 127
fi
