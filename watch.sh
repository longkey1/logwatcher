#!/usr/bin/env bash

# variables
MESSAGE='@'

# functions
function usage() {
  cat <<EOF
$(basename ${0}) is a tool for ...

Usage:
  $(basename ${0}) [command] [<options>]

Options:
  -l  target log file path
  -k  keyword string (comma separated)
  -m  message format [default ${MESSAGE}]
  -c  notification command
  -h  print this
EOF
  exit 1
}

# options
while getopts l:k:m:c: opt
do
  case ${opt} in
  "l" )
    LOG_FILE=${OPTARG}
    ;;
  "k" )
    KEYWORDS_STRING=${OPTARG}
    ;;
  "m" )
    MESSAGE=${OPTARG}
    ;;
  "c" )
    NOTIFICATION_COMMAND=${OPTARG}
    ;;
  :|\?) usage;;
  esac
done
if [ -z "${LOG_FILE}" -o -z "${KEYWORDS_STRING}" -o -z "${NOTIFICATION_COMMAND}" ]; then
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
  echo ${line} | grep --line-buffered ${GREP_OPTIONS} | xargs -I @ echo ${MESSAGE} | ${NOTIFICATION_COMMAND}
done < <(tail -n0 -F ${LOG_FILE})
