#!/bin/bash

# This script creates an account on the local sysytem
# you will be prompted for the account name and password


# Makes sure the scipt is executed with superuser privielegs
UID_TO_TEST_FOR="1000"

if [[ "${UID}" -ne 0 ]]
then 
 echo "You are not a super user, please attempt again with root privileges" >&2
 exit 1
fi

#If the user doesn't supply at least one arg
if [[ "${#}" -eq 0 ]]
then 
 echo "Usage: ${0} USER_NAME followed by [COMMENT] 
Create an account on the local system with the name of USER_NAME and a comment field of COMMENT" >&2
 exit 1
fi

# first parameter is user name
USER_NAME="${1}"
COMMENT=""
shift

# rest are account comments
for USER_COMMENT in "${@}"
do
 COMMENT="${COMMENT} ${USER_COMMENT}"
done

# Genarate a password
PASS_WORD=$(date +%s%N | sha256sum | head -c32)

# create a user
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null

# Check to see if the useradd command succeeded
if [[ "${?}" -ne 0 ]] 
then 
 echo "Something went wrong with the creation of the user" >&2
 exit 1
fi

# Set the password for the user
echo "${PASS_WORD}" | passwd --stdin ${USER_NAME} &> /dev/null

# Check to see if the passwd command succeeded
if [[ "${?}" -ne 0 ]] 
then 
 echo "Something went wrong with the creation of the password" >&2
 exit 1
fi

# Force password change on first login
passwd -e ${USER_NAME} &> /dev/null

# Display the username, password, and the host where the user was created.

echo "the username is:
 ${USER_NAME}"
echo
echo "the the password is:
 ${PASS_WORD}" 
echo
echo "the the host is:
 ${HOSTNAME}" 
exit 0
