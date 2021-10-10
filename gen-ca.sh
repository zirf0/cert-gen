#!/bin/bash

#
# Semi autugeneration of certificates for GL + rsyslog TLS
CT='/usr/bin/certtool'
CA='ca.pem'
CAKEY='ca-key.pem'
TMPL='req.tmpl'
Color_Off='\033[0m'
Red='\033[0;31m'

PREFIX=$1

#echo $'\033[0;31m'
# if certtool installed
if ! [ -f $CT ];
then
	    echo $'\033[0;31m'"Sorry $CT not found, please install in first. Exit"
	    echo $'\033[0m'
	    exit 1
fi
# if ca.pem and ca-key.pem present
if ! [  -f $CA -a  -f $CAKEY ];
then
	    echo  $'\033[0;31m'"Sorry, $CA or $CAKEY not found. Run gen-ca.sh first. Exit"
	    echo $'\033[0m'
	    exit 2 
fi
# if req.tmpl esists? 
if ! [ -f $TMPL ];
then
	    echo  $'\033[0;31m'"  $TMPL doesn't exist. Exit"
	    echo $'\033[0m'
            exit 3
    
fi
#if command line empty
if ! [ -z "$PREFIX" ];
then
	    echo  $'\033[0;31m'"  run $0 prefix"
	    echo " uniq for filenames"
	    echo $'\033[0m'
            exit 4
    
fi

#echo $'\033[0m'
#Delete it
echo $1
exit
$CT --generate-privkey --outfile $1-key.pem --bits 2048
$CT --generate-request --load-privkey $1-key.pem --outfile request.pem --template  $TMPL
$CT --generate-certificate --load-request request.pem --outfile $1-cert.pem --load-ca-certificate $CA --load-ca-privkey $CAKEY \
	--template $TMPL
rm -f request.pem
chmod 644 $1-*
