# Домашнее задание к занятию 3 «Использование Yandex Cloud»

Подготовил inventory-файл `prod.yml`, добавил в playbook установку и настройку Lighthouse.

Выполнил линтинг командой `ansible-lint site.yml`, исправил ошибки.

Запустил playbook с флагом `--check`:
```
TASK [NGINX | Install NGINX] **************************************************************************************************************************************************************************************************
fatal: [lighthouse-01]: FAILED! => {"changed": false, "msg": "No package matching 'nginx' found available, installed or updated", "rc": 126, "results": ["No package matching 'nginx' found available, installed or updated"]}
...ignoring

TASK [NGINX | Create file for lighthouse config] ******************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [NGINX | Create general config] ******************************************************************************************************************************************************************************************
changed: [lighthouse-01]

RUNNING HANDLER [reload-nginx] ************************************************************************************************************************************************************************************************
skipping: [lighthouse-01]

PLAY [Install LightHouse] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [Lighthouse | Install dependencies] **************************************************************************************************************************************************************************************
changed: [lighthouse-01]

TASK [Lighthouse | Copy from git] *********************************************************************************************************************************************************************************************
fatal: [lighthouse-01]: FAILED! => {"changed": false, "msg": "Failed to find required executable git in paths: /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin"}
...ignoring

TASK [Lighthouse | Create lighthouse config] **********************************************************************************************************************************************************************************
changed: [lighthouse-01]

RUNNING HANDLER [reload-nginx] ************************************************************************************************************************************************************************************************
skipping: [lighthouse-01]

PLAY [Install Clickhouse] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Clickhouse | Get distrib] ***********************************************************************************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Clickhouse | Install packages] ******************************************************************************************************************************************************************************************
changed: [clickhouse-01]

RUNNING HANDLER [Start clickhouse service] ************************************************************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "Could not find the requested service clickhouse-server: host"}
...ignoring

TASK [Clickhouse | Create database] *******************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

PLAY [Install Vector] *********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Vector | Install rpm] ***************************************************************************************************************************************************************************************************
changed: [vector-01]

TASK [Vector | Template config] ***********************************************************************************************************************************************************************************************
changed: [vector-01]

TASK [Vector | Create systemd unit] *******************************************************************************************************************************************************************************************
changed: [vector-01]

TASK [Vector | Start service] *************************************************************************************************************************************************************************************************
fatal: [vector-01]: FAILED! => {"changed": false, "msg": "Could not find the requested service vector: host"}
...ignoring

PLAY RECAP ********************************************************************************************************************************************************************************************************************
clickhouse-01              : ok=4    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=1   
lighthouse-01              : ok=9    changed=4    unreachable=0    failed=0    skipped=2    rescued=0    ignored=2   
vector-01                  : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1 
```
Запустил playbook с флагом `--diff`:
```
(venv) alex@example ~/repo/netology-ansible/ansible03/playbook (main) $ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Nginx] **********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [NGINX | Install epel-release] *******************************************************************************************************************************************************************************************
changed: [lighthouse-01]

TASK [NGINX | Install NGINX] **************************************************************************************************************************************************************************************************
changed: [lighthouse-01]

TASK [NGINX | Create file for lighthouse config] ******************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,6 +1,6 @@
 {
-    "atime": 1683209080.2954264,
-    "mtime": 1683209080.2954264,
+    "atime": 1683209080.299803,
+    "mtime": 1683209080.299803,
     "path": "/etc/nginx/conf.d/lighthouse.conf",
-    "state": "absent"
+    "state": "touch"
 }

changed: [lighthouse-01]

TASK [NGINX | Create general config] ******************************************************************************************************************************************************************************************
--- before: /etc/nginx/nginx.conf
+++ after: /home/alex/.ansible/tmp/ansible-local-11001wpvuatj2/tmpj8s_m5gw/nginx.conf.j2
@@ -1,84 +1,35 @@
-# For more information on configuration, see:
-#   * Official English Documentation: http://nginx.org/en/docs/
-#   * Official Russian Documentation: http://nginx.org/ru/docs/
-
-user nginx;
-worker_processes auto;
-error_log /var/log/nginx/error.log;
-pid /run/nginx.pid;
-
-# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
-include /usr/share/nginx/modules/*.conf;
+worker_processes  1;
+user              centos;
 
 events {
-    worker_connections 1024;
+    worker_connections  1024;
 }
 
+error_log         /var/log/nginx/error.log info;
+pid               /var/run/nginx.pid;
+
 http {
-    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
-                      '$status $body_bytes_sent "$http_referer" '
-                      '"$http_user_agent" "$http_x_forwarded_for"';
 
-    access_log  /var/log/nginx/access.log  main;
+    include       mime.types;
+    charset       utf-8;
 
-    sendfile            on;
-    tcp_nopush          on;
-    tcp_nodelay         on;
-    keepalive_timeout   65;
-    types_hash_max_size 4096;
-
-    include             /etc/nginx/mime.types;
-    default_type        application/octet-stream;
-
-    # Load modular configuration files from the /etc/nginx/conf.d directory.
-    # See http://nginx.org/en/docs/ngx_core_module.html#include
-    # for more information.
-    include /etc/nginx/conf.d/*.conf;
+    access_log    /var/log/nginx/access.log  combined;
 
     server {
-        listen       80;
-        listen       [::]:80;
-        server_name  _;
-        root         /usr/share/nginx/html;
+        server_name   localhost;
+        listen        80;
 
-        # Load configuration files for the default server block.
-        include /etc/nginx/default.d/*.conf;
 
-        error_page 404 /404.html;
-        location = /404.html {
+        location      / {
+            root      html;
+
         }
 
-        error_page 500 502 503 504 /50x.html;
-        location = /50x.html {
-        }
+        include conf.d/lighthouse.conf;
+
+
     }
 
-# Settings for a TLS enabled server.
-#
-#    server {
-#        listen       443 ssl http2;
-#        listen       [::]:443 ssl http2;
-#        server_name  _;
-#        root         /usr/share/nginx/html;
-#
-#        ssl_certificate "/etc/pki/nginx/server.crt";
-#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
-#        ssl_session_cache shared:SSL:1m;
-#        ssl_session_timeout  10m;
-#        ssl_ciphers HIGH:!aNULL:!MD5;
-#        ssl_prefer_server_ciphers on;
-#
-#        # Load configuration files for the default server block.
-#        include /etc/nginx/default.d/*.conf;
-#
-#        error_page 404 /404.html;
-#            location = /40x.html {
-#        }
-#
-#        error_page 500 502 503 504 /50x.html;
-#            location = /50x.html {
-#        }
-#    }
 
 }
 

changed: [lighthouse-01]

RUNNING HANDLER [start-nginx] *************************************************************************************************************************************************************************************************
changed: [lighthouse-01]

RUNNING HANDLER [reload-nginx] ************************************************************************************************************************************************************************************************
changed: [lighthouse-01]

PLAY [Install LightHouse] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [Lighthouse | Install dependencies] **************************************************************************************************************************************************************************************
changed: [lighthouse-01]

TASK [Lighthouse | Copy from git] *********************************************************************************************************************************************************************************************
>> Newly checked out d701335c25cd1bb9b5155711190bad8ab852c2ce
changed: [lighthouse-01]

TASK [Lighthouse | Create lighthouse config] **********************************************************************************************************************************************************************************
--- before: /etc/nginx/conf.d/lighthouse.conf
+++ after: /home/alex/.ansible/tmp/ansible-local-11001wpvuatj2/tmpn81jg6nx/lighthouse.conf.j2
@@ -0,0 +1,8 @@
+
+        location /lighthouse {
+            root /var/www/lighthouse;
+        }
+
+
+
+

changed: [lighthouse-01]

RUNNING HANDLER [reload-nginx] ************************************************************************************************************************************************************************************************
changed: [lighthouse-01]

PLAY [Install Clickhouse] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Clickhouse | Get distrib] ***********************************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Clickhouse | Install packages] ******************************************************************************************************************************************************************************************
changed: [clickhouse-01]

RUNNING HANDLER [Start clickhouse service] ************************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Clickhouse | Create database] *******************************************************************************************************************************************************************************************
changed: [clickhouse-01]

PLAY [Install Vector] *********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Vector | Install rpm] ***************************************************************************************************************************************************************************************************
changed: [vector-01]

TASK [Vector | Template config] ***********************************************************************************************************************************************************************************************
--- before
+++ after: /home/alex/.ansible/tmp/ansible-local-11001wpvuatj2/tmpqv4qq9dk/vector.yaml.j2
@@ -0,0 +1,18 @@
+sinks:
+    to_clickhouse:
+        compression: gzip
+        database: custom
+        endpoint: localhost:8123
+        healthcheck: false
+        inputs:
+        - our_log
+        skip_unknown_fields: true
+        table: my_table
+        type: clickhouse
+sources:
+    our_log:
+        ignore_older_secs: 600
+        include:
+        - /home/centos/logs/*.log
+        read_from: beginning
+        type: file

[WARNING]: The value "1000" (type int) was converted to "u'1000'" (type string). If this does not look like what you expect, quote the entire value to ensure it does not change.
changed: [vector-01]

TASK [Vector | Create systemd unit] *******************************************************************************************************************************************************************************************
--- before
+++ after: /home/alex/.ansible/tmp/ansible-local-11001wpvuatj2/tmp2wno7l1y/vector.service.j2
@@ -0,0 +1,26 @@
+#
+# Ansible managed
+#
+[Unit]
+Description=Vector
+Documentation=https://vector.dev/docs/about/what-is-vector/
+Requires=network-online.target
+After=network-online.target
+
+[Service]
+User=root
+Group=root
+
+ExecStart=/usr/bin/vector
+ExecReload=/bin/kill -HUP $MAINPID
+
+StandardOutput=journal
+StandardError=journal
+
+SyslogIdentifier=vector
+
+KillSignal=SIGTERM
+Restart=no
+
+[Install]
+WantedBy=multi-user.target
\ No newline at end of file

changed: [vector-01]

TASK [Vector | Start service] *************************************************************************************************************************************************************************************************
changed: [vector-01]

PLAY RECAP ********************************************************************************************************************************************************************************************************************
clickhouse-01              : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
lighthouse-01              : ok=12   changed=10   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
Убедился, что изменения на системе произведены:
```
(venv) alex@example ~/repo/netology-ansible/ansible03/playbook (main) $ ssh centos@158.160.25.121
[centos@vector ~]$ systemctl status vector
● vector.service - Vector
   Loaded: loaded (/etc/systemd/system/vector.service; disabled; vendor preset: disabled)
   Active: active (running) since Чт 2023-05-04 14:06:43 UTC; 46s ago
     Docs: https://vector.dev/docs/about/what-is-vector/
 Main PID: 8583 (vector)
   CGroup: /system.slice/vector.service
           └─8583 /usr/bin/vector
[centos@vector ~]$ exit
logout
Connection to 158.160.25.121 closed.
(venv) alex@example ~/repo/netology-ansible/ansible03/playbook (main) $ ssh centos@51.250.27.160
[centos@clickhouse ~]$ clickhouse-client -h 127.0.0.1
ClickHouse client version 22.3.10.22 (official build).
Connecting to 127.0.0.1:9000 as user default.
Connected to ClickHouse server version 22.3.10 revision 54455.

clickhouse.ru-central1.internal :)
```
Lighthouse открывается в браузере по IP-адресу ВМ.

Повторно запустил playbook с флагом `--diff`:
```
(venv) alex@example ~/repo/netology-ansible/ansible03/playbook (main) $ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Nginx] **********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [NGINX | Install epel-release] *******************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [NGINX | Install NGINX] **************************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [NGINX | Create file for lighthouse config] ******************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,6 +1,6 @@
 {
-    "atime": 1683209137.8013527,
-    "mtime": 1683209134.126357,
+    "atime": 1683209407.573454,
+    "mtime": 1683209407.573454,
     "path": "/etc/nginx/conf.d/lighthouse.conf",
-    "state": "file"
+    "state": "touch"
 }

changed: [lighthouse-01]

TASK [NGINX | Create general config] ******************************************************************************************************************************************************************************************
ok: [lighthouse-01]

PLAY [Install LightHouse] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [Lighthouse | Install dependencies] **************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [Lighthouse | Copy from git] *********************************************************************************************************************************************************************************************
ok: [lighthouse-01]

TASK [Lighthouse | Create lighthouse config] **********************************************************************************************************************************************************************************
ok: [lighthouse-01]

PLAY [Install Clickhouse] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Clickhouse | Get distrib] ***********************************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Clickhouse | Install packages] ******************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Clickhouse | Create database] *******************************************************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] *********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Vector | Install rpm] ***************************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Vector | Template config] ***********************************************************************************************************************************************************************************************
[WARNING]: The value "1000" (type int) was converted to "u'1000'" (type string). If this does not look like what you expect, quote the entire value to ensure it does not change.
ok: [vector-01]

TASK [Vector | Create systemd unit] *******************************************************************************************************************************************************************************************
ok: [vector-01]

TASK [Vector | Start service] *************************************************************************************************************************************************************************************************
ok: [vector-01]

PLAY RECAP ********************************************************************************************************************************************************************************************************************
clickhouse-01              : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
lighthouse-01              : ok=9    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

## Описание playbook

Устанавливает и настраивает Clickhouse, Nginx, Lighthouse и Vector.

### Задачи

#### PLAY [Install Nginx]
  - NGINX | Install epel-release - устанавливает репозиторий EPEL
  - NGINX | Install NGINX - устанавливает Nginx
  - NGINX | Create file for lighthouse config - создаёт пустой файл для lighthouse.conf
  - NGINX | Create general config - создаёт основной конфигурационный файл nginx.conf

#### PLAY [Install Lighthouse]
  - Lighthouse | Install dependencies - устанавливает необходимые зависимости
  - Lighthouse | Copy from git - копирует исходник Lighthouse из репозитория
  - Lighthouse | Create lighthouse config - создаёт конфигурационный файл lighthouse.conf (инклюд в nginx.conf)
 
#### PLAY [Install Clickhouse]
  - Clickhouse | Get distrib - скачивает пакеты для установки Clickhouse
  - Clickhouse | Get reserve distrib - скачивает пакеты для установки Clickhouse с другого URL
  - Clickhouse | Install packages - устанавливает Clickhouse
  - Clickhouse | Flush handlers - запускает все обработчики (запускает сервис)
  - Clickhouse | Create database - создаёт БД 

#### PLAY [Deploy Vector] 
  - Vector | Install rpm - устанавливает Vector
  - Vector | Template config - копирует конфигурационный файлы Vector из шаблона
  - Vector | Create systemd unit - создаёт systemd-службу Vector по файлу из шаблона
  - Vector | Start service - добавляет службу Vector в автозагрузку и запускает

### Переменные

- `clickhouse_version` - версия Clickhouse
- `clickhouse_packages` - пакеты для установки Clickhouse
- `lighthouse_vcs` - репозиторий Lighthouse
- `lighthouse_location_dir` - путь к локации lighthouse в nginx
- `vector_url` - URL для установки Vector
- `vector_data_dir` - директория с данными Vector
- `vector_documentation_link` - ссылка на документацию Vector
- `vector_log_output` - значение `StandardOutput` для systemd-службы Vector 
- `vector_syslog_identifier` - значение `SyslogIdentifier` для systemd-службы Vector 

### Теги

- `nginx` - установка и настройка Nginx
- `lighthouse` - установка и настройка Lighthouse
- `clickhouse` - установка и настройка Clickhouse
- `vector` - установка и настройка Vector