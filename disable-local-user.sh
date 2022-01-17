#!/bin/bash

# Display the usage and exiT
ARCHIVE="/ARCHIVES"

usage () {
  echo " Usage: ${0} [-dra] USER [USERN]..." >&2   
  echo " Disable the account(s) " >&2
  echo "-d Delete the account(s) instead of disabling them " >&2
  echo "-r Remove the home directory associated with the account(s) " >&2
  echo "-a Create an archive of the home directory associated with the account(s) and store the archive in the /archive directory" <&2
  exit 1
}


# make sure the script is being executed with sueruser privileges
if [[ "${UID}" -ne 0 ]]
then
  echo "You are not a superUser, please use sudo to login as a root user" >&2
  exit 1
fi
# Parse the options
while getopts dra OPTION
do
  case ${OPTION} in 
    d)
      DELET_USER='true'
      ;;
    r)
      REMOVE_HOME_DIR='-r'
      ;;
    a)
      MAKE_ARCHIVE='true'
      ;;
    ?)
      usage
      ;;
  esac
done


# Remove the options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

# If user doesn't supply at least one argument
if [[ "${#}" -lt 1 ]] 
then
  usage
fi


# Loop through all the usernames supplied as arguments.
for USER_NAME in "${@}"
do
  # Make sure the UID of the account is at least 1000
  USERID=$(id -u ${USER_NAME})
  
  if [[ ${USERID} -lt 1000 ]] 
  then
    echo "The user id is less then 1000" >&2
    exit 1  
  fi

  # Create an archive if requested to do so
  if [[ ${MAKE_ARCHIVE} = 'true' ]]
  then
    # Make sure the ARCHIVE_DIR directory exists
    if [[ ! -d "${ARCHIVE}" ]]
    then 
      mkdir -p ${ARCHIVE}
      if [[ "${?}" -ne 0 ]]
      then
        echo "issue creating the ${ARCHIVE}" >&2
        exit 1
      fi
    fi  
    # Archive the user's home directory and move it into the ARCHIVE-DIR
    HOME_DIR="/home/${USER_NAME}"
    if [[ -d "${HOME_DIR}" ]]
    then
      tar -zcf "${ARCHIVE}/${USER_NAME}.tgz" &> /dev/null
      echo 'Archive has been created'
      if [[ "${?}" -ne 0 ]]
      then
        echo "Issue archiving files" >&2
        exit 1
      fi
    else
      echo "${HOME_DIR} does not exit or is not a directory" >&2
      exit
    fi
  fi

    # Delete the user
    if [[ ${DELET_USER} = 'true' ]]
    then
      userdel ${REMOVE_HOME_DIR}  ${USER_NAME}
      # Check to see if the userdel command succeeded
      # We dont want to tell the user that an account was deleted when it hasn't 
      if [[ "${?}" -ne 0 ]] 
      then
        echo 'the account ${USER_NAME} was NOT deleted'
      else
        echo 'the account ${USER_NAME) was deleted'
      fi
    else
      chage -E 0 ${USER_NAME}
      # Check to see if the chage command succeeded
      # We dont want to tell the user that an account was disabled when it hasn't
      if [[ "${?}" -ne 0 ]] 
      then
        echo 'the account ${USER_NAME} was NOT disabled '
      else
        echo 'the account ${USER_NAME} was disabled' 
      fi
    fi 
done

exit 0

