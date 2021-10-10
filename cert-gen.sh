#!/bin/bash

#
# Semi autugeneration of certificates for GL + rsyslog TLS
#
DDIR='data/'
ODIR='output/'
#GLSRV='****' # Edit this line, subtitute real graylog server hostname or IP
GLSRV='node2'
CT='/usr/bin/certtool'
CA=$ODIR'ca.pem'
CAKEY=$ODIR'ca-key.pem'
TMPL=$DDIR'req.tmpl'
RSTMPL=$DDIR'10-graylog.tmpl'
#Color_Off='\033[0m'
#Red='\033[0;31m'

# is GLSRV correct
if [ "$GLSRV" = '****' ];
then
	echo $'\033[0;31m'"$GLSRV is not valid value. Edit $0 set  GLSRV variable as servername or IP of graylog server.Exit"$'\033[0m'
	exit 127
fi
# is certtool installed
if ! [ -f $CT ];
then
	    echo $'\033[0;31m'"Sorry $CT not found, please install in first. Exit"
	    echo $'\033[0m'
	    exit 1
fi
# is ca.pem and ca-key.pem present
if ! [  -f $CA -a  -f $CAKEY ];
then
	    echo  $'\033[0;31m'"Sorry, $CA or $CAKEY not found. Run gen-ca.sh first. Exit"
	    echo $'\033[0m'
	    exit 2 
fi
# is req.tmpl esists? 
if ! [ -f $TMPL ];
then
	    echo  $'\033[0;31m'"  $TMPL doesn't exist. Exit"
	    echo $'\033[0m'
            exit 3
    
fi
# RSTMPL exists
if ! [ -f $RSTMPL ];
then
	    echo  $'\033[0;31m'"  $RSTMPL doesn't exist. Exit"
	    echo $'\033[0m'
            exit 3
    
fi
#is command line empty
if  [ "$1" = "" ];
then
	    echo  $'\033[0;31m'"Run: $0 prefix"
	    echo " prefix should be unique for filenames"
	    echo $'\033[0m'
            exit 4
    
fi

# generate cert and key files

$CT --generate-privkey --outfile $ODIR$1-key.pem --bits 2048
$CT --generate-request --load-privkey $ODIR$1-key.pem --outfile request.pem --template  $TMPL
$CT --generate-certificate --load-request request.pem --outfile $ODIR$1-cert.pem --load-ca-certificate $CA --load-ca-privkey $CAKEY \
	--template $TMPL
rm -f request.pem
chmod 644 $ODIR$1-*


# generate rsyslog config

sed s/machine/$1/g $RSTMPL > tmp
sed s/glsrv/$GLSRV/g tmp > $ODIR$1-graylog.conf
rm tmp
