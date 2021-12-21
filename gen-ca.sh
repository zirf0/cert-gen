#!/bin/bash

#
# Semi autugeneration of certificates for GL + rsyslog TLS
#
DDIR='data/'
OUTDIR='out/'
ODIR='ca/'
CT='/usr/bin/certtool'
CA=$ODIR'ca.pem'
CAKEY=$ODIR'ca-key.pem'
CATMPL=$DDIR'ca.tmpl'
#Color_Off='\033[0m'
#Red='\033[0;31m'
echo
# is $OUTDIR exit?
if ! [ -d $OUTDIR ];
then
	    echo  $'\033[0;31m'"  $OUTDIR doesn't exist. Exit"
	    echo $'\033[0m'
            echo "creaing $OUTDIR..."
	    mkdir $OUTDIR
# exit 3
    
fi
echo
# is $ODIR exit?
if ! [ -d $ODIR ];
then
	    echo  $'\033[0;31m'"  $ODIR doesn't exist. Exit"
	    echo $'\033[0m'
            echo "creaing $ODIR..."
	    mkdir $ODIR
# exit 3
    
fi
# is certtool installed
if ! [ -f $CT ];
then
	    echo $'\033[0;31m'"Sorry $CT not found, please install in first(gnutls-utils or gnutls-bin package). Exit"
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

