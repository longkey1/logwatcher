#!/usr/bin/env bash

# functions
function usage() {
  echo "usage:"
  echo "${0}  [-l log file] [-k keywords] [-e email address]"
  exit 1
}

# options
while getopts l:e:k: opt
do
  case ${opt} in
  "l" )
    readonly LOG_FILE=${OPTARG}
    ;;
  "e" )
    readonly EMAIL=${OPTARG}
    ;;
  "k" )
    readonly KEYWORDS_STRING=${OPTARG}
    ;;
  :|\?) usage;;
  esac
done
if [ -z "${LOG_FILE}" -o -z "${EMAIL}"  -o -z "${KEYWORDS_STRING}" ]; then
  usage
  exit 1
fi
declare -a KEYWORDS=();
KEYWORDS=$(echo $KEYWORDS_STRING | tr ',' ' ');
GREP_OPTIONS=""
for word in ${KEYWORDS[@]};
do
  GREP_OPTIONS="${GREP_OPTIONS} -e ${word}"
done
if [ -z "${GREP_OPTIONS}" ]; then
  usage
  exit 1
fi



# main
while read line
do
  echo ${line} | grep --line-buffered ${GREP_OPTIONS} | xargs -I@ echo "@" | /usr/sbin/sendmail -- ${EMAIL}
done < <(tail -n0 -F ${LOG_FILE})
