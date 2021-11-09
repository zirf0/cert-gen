#!/bin/bash

#
# Semi autugeneration of certificates for GL + rsyslog TLS
#
DDIR='data/'
ODIR='ca/'
CT='/usr/bin/certtool'
CA=$ODIR'ca.pem'
CAKEY=$ODIR'ca-key.pem'
CATMPL=$DDIR'ca.tmpl'
#Color_Off='\033[0m'
#Red='\033[0;31m'
echo
# is certtool installed
if ! [ -f $CT ];
then
	    echo $'\033[0;31m'"Sorry $CT not found, please install in first. Exit"
	    echo $'\033[0m'
	    exit 1
fi
# is ca.pem and ca-key.pem present
if  [  -f $CA -a  -f $CAKEY ];
then
	    echo  $'\033[0;31m'" $CA and $CAKEY already exist. Delete them manually before proceed"
	    echo $'\033[0m'
	    exit 2 
fi
# is ca.tmpl esists? 
if ! [ -f $CATMPL ];
then
	    echo  $'\033[0;31m'"  $TMPL doesn't exist. Exit"
	    echo $'\033[0m'
            exit 3
    
fi

# generate cert and key files

$CT -p  --outfile $CAKEY
chmod 400 $CAKEY
chmod 400 $CA
$CT -s --load-privkey $CAKEY --outfile $CA --template $CATMPL

