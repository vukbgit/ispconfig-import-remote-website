#!/bin/bash
#colors
DEFAULT_COLOR='\033[0;37m'
HIGHLIGHT_COLOR='\033[0;33m'
ERROR_COLOR='\033[0;31m'
SUCCESS_COLOR='\033[0;32m'
DC=$DEFAULT_COLOR
HC=$HIGHLIGHT_COLOR
EC=$ERROR_COLOR
SC=$SUCCESS_COLOR
#CHECK CONFIG FILE
printf "\n${DC}* IMPORT CONFIG FILE *${DC}\n\n"
CONFIG_FILE=$1
if [ -z $CONFIG_FILE ]; then
  printf "${EC}config file path must be passed as first parameter${DC}, aborting\n"
  exit 1
fi
if ! [ -e $CONFIG_FILE ]; then
  printf "${EC}config file path ${HC}$CONFIG_FILE ${EC}is not valid${DC}, aborting\n"
  exit 1
else    
  source $CONFIG_FILE
  printf "${SC}config file ${HC}$CONFIG_FILE ${SC}imported${DC}\n"
fi
#CHECK VARIABLES
printf "\n${DC}* CHECK VARIABLES *${DC}\n\n"
VARIABLES_NAMES=("REMOTE_HOST" "REMOTE_USER" "REMOTE_CLIENT" "REMOTE_WEB" "LOCAL_CLIENT" "LOCAL_WEB" "ROOT_FOLDER")
NUM_VARIABLES_NAMES=${#VARIABLES_NAMES[@]}
INTEGER_VARIABLES_NAMES=("REMOTE_CLIENT" "REMOTE_WEB" "LOCAL_CLIENT" "LOCAL_WEB")
VARIABLES_OK=1
for (( i=0;i<$NUM_VARIABLES_NAMES;i++)); do
  VARIABLE_NAME=${VARIABLES_NAMES[${i}]}
  VARIABLE_VALUE=${!VARIABLE_NAME}
  #check variable exists and has a value
  if [ -z $VARIABLE_VALUE ]; then
    printf "${EC}missing variable ${HC}$VARIABLE_NAME ${EC}in config file${DC}\n"
    VARIABLES_OK=0
  else
    #check integer variables
    if [[ " ${INTEGER_VARIABLES_NAMES[*]} " =~ " ${VARIABLE_NAME} " ]] && ! [[ $VARIABLE_VALUE =~ ^[0-9]+$ ]]; then
      printf "${HC}$VARIABLE_NAME ${EC}must be integer, got ${HC}$VARIABLE_VALUE${DC}\n"
      VARIABLES_OK=0
    else
      #variable is ok
      printf "${HC}$VARIABLE_NAME ${SC}is ${HC}$VARIABLE_VALUE\n"
    fi
  fi 
done
if [ $VARIABLES_OK -eq 0 ]; then
  printf "${EC}not all of variables correctly set, aborting${DC}\n"
  exit 1
fi 
printf "${SC}variables are ok${DC}\n"
#BUILD PATHS
REMOTE_PATH="/var/www/clients/client$REMOTE_CLIENT/web$REMOTE_WEB/$ROOT_FOLDER"
LOCAL_PATH="/var/www/clients/client$LOCAL_CLIENT/web$LOCAL_WEB"
#CONFIRM
printf "\n${DC}* CONFIRM *${DC}\n\n"
printf "${DC}ready to copy from ${HC}$REMOTE_HOST ${DC}\n"
printf "${DC}folder ${HC}$REMOTE_PATH ${DC}\n"
printf "${DC}into ${HC}$LOCAL_PATH ${DC}\n"
printf "is it ok? [y,N]"
read ok
ok="${ok:=n}"
case $ok in
  n) echo -e "${DC}let's do nothing, exiting\n";exit;;
esac
#TRANSFER COMMAND
scp -r $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH $LOCAL_PATH
printf "${SC}transfer complete${DC}\n"
#FILES PERMISSIONS
chown -R web$LOCAL_WEB:client$LOCAL_CLIENT $LOCAL_PATH/$ROOT_FOLDER/*
printf "${SC}files permissions set${DC}\n"
