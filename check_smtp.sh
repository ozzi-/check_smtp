#!/bin/bash
# Author: ozzi- (https://github.com/ozzi-/check_smtp)
# Description: Icinga 2 check smtp

# startup checks
if [ -z "$BASH" ]; then
  echo "Please use BASH."
  exit 3
fi
if [ ! -e "/usr/bin/which" ]; then
  echo "/usr/bin/which is missing."
  exit 3
fi
msmtp=$(which msmtp)
if [ $? -ne 0 ]; then
  echo "Please install msmtp"
  exit 3
fi

# Default Values
warning=2000
critical=3500
message="check_smtp message"
subject="check_smtp subject"
recipient=""
account=""

# Usage Info
usage() {
  echo '''Usage: check_smtp [OPTIONS]
  [OPTIONS]:
  -c CRITICAL       Critical threshold for execution in milliseconds (default: 3500)
  -w WARNING        Warning threshold for execution in milliseconds (default: 2000)
  -M MESSAGE        Message to be sent (default: check_smtp message)
  -S SUBJECT        Subject to be send (default: check_smtp subject)
  -A ACCOUNT        Account to be used (default: default used in config file)
  -R RECIPIENT      Recipient E-Mail Address
  Note: msmtp requires a config file under /etc/msmtprc
  '''
}

#main
#get options
while getopts "c:w:M:S:A:R:" opt; do
  case $opt in
    c)
      critical=$OPTARG
      ;;
    w)
      warning=$OPTARG
      ;;
    M)
      message=$OPTARG
      ;;
    S)
      subject=$OPTARG
      ;;
    A)
      account=$OPTARG
      ;;
    R)
      recipient=$OPTARG
      ;;
    *)
      usage
      exit 3
      ;;
  esac
done

#Required params
if [ -z "$recipient" ] || [ $# -eq 0 ]; then
  echo "Error: recipient is required"
  usage
  exit 3
fi


start=$(echo $(($(date +%s%N)/1000000)))
if [ -z "$account" ]; then
  body=$(echo -e "To: $recipient\nSubject:$subject\n\n$message" | $msmtp $recipient  2>&1)
else
  body=$(echo -e "To: $recipient\nSubject:$subject\n\n$message" | $msmtp -a $account $recipient  2>&1)
fi
status=$?
end=$(echo $(($(date +%s%N)/1000000)))
runtime=$(($end-$start))


#decide output by return code
if [ $status -eq 0 ] ; then
 if [ $runtime -gt $critical ] ; then
   echo "CRITICAL - runtime "$runtime" bigger than critical runtime '"$critical"'"
   exit 2;
 fi;
 if [ $runtime -gt $warning ] ; then
   echo "WARNING - runtime "$runtime" bigger than warning runtime '"$warning"'"
   exit 1;
 fi;
 echo "OK: smtp send in "$runtime" ms | runtime=$runtimems;$warning;$critical;0;$critical"
 exit 0;
else
 echo "CRITICAL: smtp send failed with return code '"$status"' in "$runtime" ms with message '"$body"' | runtime=$runtimems;$warning;$critical;0;$critical"
 exit 2;
fi;
