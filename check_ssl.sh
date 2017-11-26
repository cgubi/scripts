#!/bin/bash
 
# Based on
# http://giantdorks.org/alain/shell-script-to-check-ssl-certificate-info-like-expiration-date-and-subject/

declare -a hosts
readarray -t hosts < $1

TODAYTS=`date '+%s'`
FOUND=0
DAYSNOTICE=10
MSG=""

for host in "${hosts[@]}"
do
	# echo "Checking $host"
	SSLEND=`echo | openssl s_client -connect $host:443 2>/dev/null | openssl x509 -noout -enddate`
	SSLENDDATE=$(cut -d= -f2- <<<"$SSLEND")
	SSLENDDATETS=`date -d "$SSLENDDATE" '+%s'`
	SSLENDDATETSNOTICE=`date -d "$SSLENDDATE-$DAYSNOTICE days" '+%s'`
	SSLENDDATEFORMAT=`date -d "$SSLENDDATE" '+%F'`
	

	if [ $TODAYTS -ge $SSLENDDATETS ]; # Check expired
	then
		FOUND=1
		MSG="$MSG$host certificato SSL scaduto il $SSLENDDATEFORMAT\n"
	elif [ $TODAYTS -ge $SSLENDDATETSNOTICE ]; # Check about to expire
	then
		FOUND=1
		MSG="$MSG$host certificato SSL scadra' il $SSLENDDATEFORMAT\n"
	fi
done

if [ $FOUND == 1 ];
then
#	printf "$MSG"
	printf "$MSG" | slacktee.sh
fi
