
#!/bin/bash
# this is a utility to make tarballing and compressing with xz easier
# the command to run is:
# bash tarxz.sh name level|type
# e.g.
# bash tarxz.sh /path/to/folder/ 9
# tars and zips Rapunzel_1.0_date at level 9 compression
# to untar unzip, run this:
# bash tarxz.sh folder.tar.xz u
# this command also removes the original tar file
#
# Omitting the final option throws an error

# This doesn't work yet, not sure why
# # Enable job control
# # set -m
# #
# # function exit_script() {
# #   # this script cleans up the xz processes if Ctrl + C is pressed
# #   echo "trapped exit"
# #   pkill -TERM xz
# #   exit 255
# # }
# #
# # trap exit_script TERM

function nice_progress_print {
  # Stolen and modified from https://stackoverflow.com/questions/18017256/how-to-print-out-to-the-same-line-overriding-previous-line
  NAME_START=$1
  NAME_FINISH=$2
  for i in {1..3} ; do echo -n "Working $NAME_START"; for ((j=0; j<i; j++)) ; do echo -n ' '; done; echo -n '=>' ; for ((j=i;j<=2;j++)) ; do echo -n ' '; done; echo -n " $NAME_FINISH"; echo -n $'\r'; sleep 1; done
}

if [ -z "$1" ]; then
  echo "Need to specify a directory or file to tar or untar"
  exit 255
fi

if [ -z "$2" ]; then
  echo "Need to specify a level of compression (0-9) or 'u' to decompress"
  exit 255
fi

DIR_FILE="$1"
COMPR="$2"

if [ "$COMPR" == "u" ]; then
  echo "Uncompressing "$DIR_FILE""
  echo "xz -dc "$DIR_FILE" | tar x"

  # uncompress command
  xz -dc "$DIR_FILE" | tar x

elif [ "$COMPR" -ge 0 ] && [ "$COMPR" -le 9 ]; then

  if [ "${DIR_FILE:(-1)}" != "/" ]; then
    echo "Can only tarxz directories. Directories end with '/'"
    exit 255

  else
    LEN_STRING="${#DIR_FILE}"
    COMPRESSED_NAME="${DIR_FILE:0:$LEN_STRING - 1}"
    echo "Compressing "$DIR_FILE" at level "$COMPR" compression as "$COMPRESSED_NAME".tar.xz"
    echo "tar cf - "$DIR_FILE" | xz -"$COMPR" > "$COMPRESSED_NAME".tar.xz"

    # compress command
    (tar cf - "$DIR_FILE" | xz -"$COMPR" > "$COMPRESSED_NAME".tar.xz &)

    while [ "$(pgrep xz)" != "" ]; do
      nice_progress_print "$DIR_FILE" "$COMPRESSED_NAME.tar.xz"
    done
    echo "Complete: $DIR_FILE ===> $COMPRESSED_NAME.tar.xz"
  fi

else
  echo "Command not recognized"

fi
