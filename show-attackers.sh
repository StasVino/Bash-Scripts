#!/bin/bash
LOG_FILE="${1}"
LIMIT='10'

# Make sure the file was suppllied as an argument
if [[ ! -e "${LOG_FILE}" ]] 
then
  echo "Cannot open ${LOG_FILE}" >&2
  exit 1
fi

# Display the CSV header
echo "Count,IP,Location"

# Loop through the list of failed attempts and correspoding IP adresses
FAILD_PASSWRDS=$(cat ${LOG_FILE} | grep Failed | awk '{print $(NF-3)}' | sort | uniq -c |sort -nr)

echo "${FAILD_PASSWRDS}" | while read COUNT IP
do
  # If the number of failed atempts is greater then the limit, display count, IP, location
  if [[ "${COUNT}" -gt "${LIMIT}" ]]
  then
    LOCATION=$(geoiplookup "${IP}" | awk -F ', ' '{print $(NF)}')
    echo "${COUNT},${IP},${LOCATION}"
  fi
done

exit 0  

