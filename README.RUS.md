Настройка rsyslog TLS, центрального сервера Graylog и Nginx для отправки журналов в Graylog

Генерируем сертификаты СА и клиентов

Обратите внимание, что сервер CA обычно является специальным высокозащищенным устройством. Но вы можете использовать любой сервер Ubuntu. 
устанавливаем certtool:

 $ sudo apt install gnutls-bin

клонируем этот репозиторий

$ git clone https://github.com/zirf0/cert-gen.git 

Редактируем  cert-gen.sh, переменная GLSRV должна указывать на реальный серый сервер вместо '****'.

$ . /gen-ca.sh 

Скрипт генерирует ca/ca.pem и ca/ca-key.pem. Сделайте это один раз, вы будете использовать эти файлы в будущем (
имеет  защиту дурака, он не может перезаписывать файлы, если они уже существуют).
Теперь вы можете сгенерировать наборы для веб-серверов и сервера graylog. Синтаксис для cert-gen.sh:

$./cent-gen hostname

где "hostname" является префиксом для файлов, которые вам нужны. Пример:
$ ./cent-gen ngx1
$ ls -l out/

ngx1-cert.pem
ngx1-graylog.conf
ngx1-key.pem

Теперь вы можете разместить файлы :

Для веб-серверов

$ scp out/ngx1* out/ca.pem user@ngx 1:

для копирования файла в домашний каталог пользователя user.

Для сервера graylog вам не нужно копировать ngx1-graylog.conf, так что

$ scp out/ca.pem out/ngx1-cert.pem out/ngx1-key.pem user@ngx1:

Выполнить шаг этот для всех серверов. Примечание: ca.pem является общим для всех серверов, в то время как другие файлы отличаются. Я
предположим, что конфигурация вашего rsyslog по умолчанию, без переадресаций.

Конфигурация серверов

Заходим как user.

1. устанавливаем драйверы TLS

$ sudo apt install -y rsyslog-gnutls

2. копируем все полученные файлы ОС в /etc/rsyslog.d/
$ sudo ngx1* /etc/rsyslog.d/

3. для сервера graylog
 
разрешаем 10514/tcp на файрволе.

WebUI, System/Input SyslogTCP

Что выставить:

порт 10514
TLS cert файл: /etc/rsyslog.d/ngx1-cert.pem
TLS файл закрытого ключа: /etc/rsyslog.d/ngx1-key.pem
TLS Client Auth Trusted Certs: /etc/rsyslog.d/ca.pem
флажок   'Разрешить TLS'
Сохранить SystogTCP. Запустить его.

4. для веб-серверов nginx

настройка  nginx. В конфигурационных файлах nginx в секции server 
error_log syslog:server=unix:/dev/log,facility=local7,tag=vhost1_err,severity=error; 
access_log syslog:server=unix:/dev/log,facility=local7,tag=vhost1,nohostname,severity=info combined;
Обратите внимание на тег vhost1, он будет выглядеть как aplication_name
на сервере graylog. От вас зависит строгость(severity).

$ sudo systemctl restart rsyslog
$ sudo systemctl reload nginx


 






