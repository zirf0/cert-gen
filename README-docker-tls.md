**Part I. Graylog server installation (docker image) Ubuntu 18.04**

0. Configure firewall (include AWS SG or Azure NGS to allow 9000/tcp(WebUI*) and 5140/tcp(SyslogTCP input of GrayLog)
1. Install docker, pwgen via apt.
2. Install docker-compose from GitHub

*$ wget https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-linux-x86_64*
*$ chmod +x docker-compose-linux-x86_64*
*$ sudo cp docker-compose-linux-x86_64 /usr/local/bin*
*$ sudo ln -s /usr/local/bin/docker-compose-linux-x86_64 /usr/bin/docker-compose*

3. Download docker-compose.yml

* $git clone https://github.com/Graylog2/docker-compose* 

you will need ~/docker-compose/open-core. There

*$cp .env.example .env*
*$nano .env*

Follow the instructions inside file. Please note command

*$ echo youpass | shasum -a 256*
will output
f99e38e7d33e39d9150f92232bebdca0b83fa5192b61100d9c5e963c411f5f7f  -
You need only
f99e38e7d33e39d9150f92232bebdca0b83fa5192b61100d9c5e963c411f5f7f
(skip "trailer")

4.  Edit docker-compose.yml. Comment out unused ports:

ports:
    #- "5044:5044/tcp"   # Beats
    #- "5140:5140/udp"   # Syslog
    - "5140:5140/tcp"   # Syslog
    #- "5555:5555/tcp"   # RAW TCP
    #- "5555:5555/udp"   # RAW TCP
    - "9000:9000/tcp"   # Server API
    #- "12201:12201/tcp" # GELF TCP
    #- "12201:12201/udp" # GELF UDP
    #- "10000:10000/tcp" # Custom TCP port
    #- "10000:10000/udp" # Custom UDP port
    #- "13301:13301/tcp" # Forwarder data
    #- "13302:13302/tcp" # Forwarder config

5. Now you can run docker-compose

*$sudo docker-compose up -d*
(Note: you can avoid persistent usiage of "sudo" with docker, just add current user to sudo group "docker".

*$ sudo usermod -aG docker userame*

6. wait for full start. Check your server http://url-of-server:9000
login admin
password yourpass from step 3

7. Setup TLS. You can do it on separate Linux machine or here.

Install certtools

*$ sudo apt install -y gnutls-bin*


*$cd  cert-gen*
*$ ./gen-ca.sh*

It generates ca.pem (root CA) and ca-key.pem in ca/ folder. Keep these files! All over certificates will be based on them.

Generate certificates and configuration file for rsyslog
(edit  cert-gen.sh set up $GLSRV variable to actual graylog server name or IP, instead of "****")

* $./cert-gen.sh gl*

It generates 3 files in out/ folder: gl-cert.pem  gl-graylog.conf  gl-key.pem. You do not need gl-graylog.conf. The file is for rsyslog, graylog ignores it. So

*$ rm out/ gl-graylog.conf*
*$ sudo cp ca/ca.pem out/gl* /var/lib/docker/volumes/graylog-docker_graylog_data/_data
This step copies data to named volume of container (note this is for Ubuntu 18, Debian 11 use over folder name).

8. Go back to WebUI.  Go to System/Inputs, Select input type "Syslog TCP" and launch new input. Most important parn on the Figure 1.



In container path to the data /usr/share/graylog/data/data. Run input.



**Part II. Setup test client (any minimal VM instance).**

1.  Install rsyslog TLS drivers. For Debian/Ubuntu

*$ sudo apt install -y rsyslog-gnutls*
 
2. Use script in cert-gen, for example

* $./cert-gen  dev01*

will generate in out/ dev01-cert.pem  dev01-graylog.conf  dev01-key.pem, you should copy these files and ca/ca.pem to /etc/rsyslog.d on target device. Then (on target)

*$ sudo systemctl restart rsyslog*
check result
*$ sudo tail -n 20 -f /var/log/syslog*

If OK
Dec  9 04:54:48 node3 systemd[1]: Stopping System Logging Service...
Dec  9 04:54:48 node3 rsyslogd: [origin software="rsyslogd" swVersion="8.2102.0" x-pid="338" x-info="https://www.rsyslog.com"] exiting on signal 15.
Dec  9 04:54:49 node3 systemd[1]: rsyslog.service: Succeeded.
Dec  9 04:54:49 node3 systemd[1]: Stopped System Logging Service.
Dec  9 04:54:49 node3 systemd[1]: rsyslog.service: Consumed 2.843s CPU time.
Dec  9 04:54:49 node3 systemd[1]: Starting System Logging Service...
Dec  9 04:54:49 node3 systemd[1]: Started System Logging Service.
Dec  9 04:54:49 node3 rsyslogd: imuxsock: Acquired UNIX socket '/run/systemd/journal/syslog' (fd 3) from systemd.  [v8.2102.0]
Dec  9 04:54:49 node3 rsyslogd: [origin software="rsyslogd" swVersion="8.2102.0" x-pid="426" x-info="https://www.rsyslog.com"] start

In WebUI (search tab) with "Updating" 1 s the same events will appear.

Example of errors in /var/log/syslog

Dec  9 04:59:19 node3 rsyslogd: [origin software="rsyslogd" swVersion="8.2102.0" x-pid="522" x-info="https://www.rsyslog.com"] start
Dec  9 05:00:09 node3 rsyslogd: unexpected GnuTLS error -53 - this could be caused by a broken connection. GnuTLS reports: Error in the push function.   [v8.2102.0 try https://www.rsyslog.com/e/2078 ]
Dec  9 05:00:09 node3 rsyslogd: omfwd: TCPSendBuf error -2078, destruct TCP Connection to node2:5140 [v8.2102.0 try https://www.rsyslog.com/e/2078 ]
Dec  9 05:00:09 node3 rsyslogd: action 'action-0-builtin:omfwd' suspended (module 'builtin:omfwd'), retry 0. There should be messages before this one giving the reason for suspension. [v8.2102.0 try https://www.rsyslog.com/e/2007 ]

No events in GrayLog search. I simulated it (wrong file name for certificate on GrayLog).








