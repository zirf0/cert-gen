Configure rsyslog TLS, central Graylog and Nginx to send logs to Graylog

Generate CA and machine certificates

Please note Certification Authority (CA) server normally is dedicated high-protected device. But for

your task you can use any Ubuntu server. 
1. $ sudo apt install gnutls-bin
clone this repo
Edit cert-gen.sh, variable GLSRV must point to real graylog server instead of ‘****’.
2. $ ./gen-ca.sh
It generates ca/ca.pem and ca/ca-key.pem. Do it once, you will use these files in future (the
script has foolproof, it can’t overwrite files if they already exist).
3. Now you can generate sets for webservers and graylog server. Syntax for cert-gen.sh:
./cent-gen hostname
where “hostname” is prefix for files you needed. Live example:
$ ./cent-gen ngx1
$ ls -l out/

ngx1-cert.pem
ngx1-graylog.conf
ngx1-key.pem

Now you can share files:

For webservers

$ scp out/ngx1* out/ca.pem user@ngx1:

to copy file fo homedir of the ‘user’.

For graylog server you don’t need to copy ngx1-graylog.conf, so
$ scp out/ca.pem out/ngx1-cert.pem out/ngx1-key.pem user@ngx1:
Do step 3 for all servers. Note, ca.pem is general for all servers, whereas other files are different. I
suppose your rsyslog configuration is default, without any forwarding.

Configuration of servers

Loging as ‘user’
1. install TLS drivers
$ sudo apt install -y rsyslog-gnutls
2. copy all received from CA files to /etc/rsyslog.d/
$ sudo ngx1* /etc/rsyslog.d/
3. for graylog server 
enable port 10514/tcp in firewall/security groups.
open WebUI, System/Inputs Syslog TCP
Important things:
port 10514
TLS cert file: /etc/rsyslog.d/ngx1-cert.pem
TLS private key file: /etc/rsyslog.d/ngx1-key.pem
TLS Client Auth Trusted Certs: /etc/rsyslog.d/ca.pem
check box ‘Enable TLS’
Save Input. Start input.
4. For webservers
Configure nginx sites. In configuration files of nginx in server or vhost section
error_log syslog:server=unix:/dev/log,facility=local7,tag=vhost1_err,severity=error;
access_log syslog:server=unix:/dev/log,facility=local7,tag=vhost1,nohostname,severity=info combined;
Pay attention to ‘tag’, it will be seen as ‘application name’ instead of ‘nginx’. So you will can sort it 
out on graylog server. ‘severity’ is up to you.
$ sudo systemctl restart rsyslog
$ sudo systemctl reload nginx
