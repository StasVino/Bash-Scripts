#!/bin/bash


SERVER_LIST="/vagrant/servers"
SUDO_MODE=""

# Display the usage and exit
usage () {
  echo " Usage: ${0} [-nsv] [-f FILE] COMMAND " >&2
  echo " Executes the COMMAND on the provided remote servers " >&2
  echo " -f Overrides the defult filepath /vagrant/servers" >&2
  echo " -n Allows the user to preform a dry run" >&2
  echo " -s Run the command on sudo (superuser) privileges on the remote servers" >&2
  echo " -v Verbose mode " >&2
  exit 1
}

# Options for the ssh command.
SSH_OPTIONS="-o ConnectTimeout=2"

# Make sure the script is not being executed with superuser privileges
if [[ "${UID}" -eq 0 ]]
then
  echo "Do not execute this script as root. Use the -s option instead."
  usage
fi

# Parse the options
while getopts f:nsv OPTION
do
  case ${OPTION} in
    f)
      SERVER_LIST="${OPTARG}" ;;
    n)
      DRY_RUN='true' ;;
    s)
      SUDO_MODE='sudo' ;;
    v)
      VERBOSE='true' ;;
    ?)
      usage ;;
  esac
done

# Remove the options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

# If the user doesn't supply at least one argument, give them help
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Anything that remains on the command line is to be treated as a single command
COMMAND="${@}"

# Make usre the SERVER_LIST file exists
if [[ ! -e "${SERVER_LIST}" ]] 
then 
  echo "Cannot open server list ${SERVER_LIST}, filepath does not exist" >&2
  exit 1
fi

# Loop through the SERVER_LIST	
for SERVER in $(cat "${SERVER_LIST}")
do
  if [[ "${VERBOSE}" = "true" ]]
  then
    echo "${SERVER}"
  fi
  SSH_COMMAND="ssh ${SSH_OPTION} ${SERVER} ${SUDO_MODE} ${COMMAND}"
  # If it's a dry run, don't execute anthing, just echo it
  if [[ "${DRY_RUN}" = 'true' ]]
  then
    echo "DRY RUN: ${SSH_COMMAND}"
  else
    ${SSH_COMMAND}
    # Captuer any non-zero exit status from the SSH_COMMAND and report to the user
    SSH_EXIT_STATUS="${?}"
    if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
    then
      EXIT_STATUS="${SSH_EXIT_STATUS}"
      echo "Execution of ${SERVER} failed"
    fi
  fi
done

exit ${EXIT_STATUS}


