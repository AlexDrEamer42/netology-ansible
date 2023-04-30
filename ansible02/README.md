# Домашнее задание к занятию 2 «Работа с Playbook»

Подготовил inventory-файл `prod.yml`, добавил в playbook установку и настройку [vector](https://vector.dev).
Выполнил линтинг командой `ansible-lint site.yml`, исправил ошибки.
Запустил playbook с флагом `--check`:

```
(venv) alex@example ~/repo/netology-ansible/ansible02/playbook (main) $ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "No RPM file matching 'clickhouse-common-static-22.3.10.22.rpm' found on system", "rc": 127, "results": ["No RPM file matching 'clickhouse-common-static-22.3.10.22.rpm' found on system"]}
...ignoring

TASK [Create database] ********************************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

PLAY [Deploy Vector] **********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get Vector version] *****************************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

TASK [Get RPM] ****************************************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

TASK [Install Vector] *********************************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

TASK [Configure Vector] *******************************************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Copy daemon script] *****************************************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Configuring service] ****************************************************************************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "Could not find the requested service vector: host"}
...ignoring

RUNNING HANDLER [restart-vector] **********************************************************************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "Could not find the requested service vector: host"}
...ignoring

PLAY RECAP ********************************************************************************************************************************************************************************************************************
clickhouse-01              : ok=8    changed=3    unreachable=0    failed=0    skipped=4    rescued=0    ignored=3   
```

Запустил playbook с флагом `--diff`:
```
(venv) alex@example ~/repo/netology-ansible/ansible02/playbook (main) $ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************************************************************************************************************
changed: [clickhouse-01]

RUNNING HANDLER [Start clickhouse service] ************************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Create database] ********************************************************************************************************************************************************************************************************
changed: [clickhouse-01]

PLAY [Deploy Vector] **********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get Vector version] *****************************************************************************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "cmd": "vector --version", "msg": "[Errno 2] Нет такого файла или каталога", "rc": 2}
...ignoring

TASK [Get RPM] ****************************************************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Install Vector] *********************************************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Configure Vector] *******************************************************************************************************************************************************************************************************
--- before: /etc/vector/vector.toml
+++ after: /home/alex/.ansible/tmp/ansible-local-4449175oax7ey/tmpkngdx2vm/vector.toml.j2
@@ -1,44 +1,12 @@
-#                                    __   __  __
-#                                    \ \ / / / /
-#                                     \ V / / /
-#                                      \_/  \/
-#
-#                                    V E C T O R
-#                                   Configuration
-#
-# ------------------------------------------------------------------------------
-# Website: https://vector.dev
-# Docs: https://vector.dev/docs
-# Chat: https://chat.vector.dev
-# ------------------------------------------------------------------------------
+data_dir = "/var/lib/vector"
 
-# Change this to use a non-default directory for Vector data storage:
-# data_dir = "/var/lib/vector"
+# Input data. Change me to a valid input source.
+[sources.in]
+  type = "stdin"
 
-# Random Syslog-formatted logs
-[sources.dummy_logs]
-type = "demo_logs"
-format = "syslog"
-interval = 1
+# Output data
+[sinks.out]
+  inputs   = ["in"]
+  type     = "console"
+  encoding.codec = "text"
 
-# Parse Syslog logs
-# See the Vector Remap Language reference for more info: https://vrl.dev
-[transforms.parse_logs]
-type = "remap"
-inputs = ["dummy_logs"]
-source = '''
-. = parse_syslog!(string!(.message))
-'''
-
-# Print parsed logs to stdout
-[sinks.print]
-type = "console"
-inputs = ["parse_logs"]
-encoding.codec = "json"
-
-# Vector's GraphQL API (disabled by default)
-# Uncomment to try it out with the `vector top` command or
-# in your browser at http://localhost:8686
-#[api]
-#enabled = true
-#address = "127.0.0.1:8686"

changed: [clickhouse-01]

TASK [Copy daemon script] *****************************************************************************************************************************************************************************************************
--- before
+++ after: /home/alex/.ansible/tmp/ansible-local-4449175oax7ey/tmpmma2yf4r/vector.service.j2
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

changed: [clickhouse-01]

TASK [Configuring service] ****************************************************************************************************************************************************************************************************
changed: [clickhouse-01]

RUNNING HANDLER [restart-vector] **********************************************************************************************************************************************************************************************
changed: [clickhouse-01]

PLAY RECAP ********************************************************************************************************************************************************************************************************************
clickhouse-01              : ok=13   changed=10   unreachable=0    failed=0    skipped=0    rescued=0    ignored=1   
```
Убедился, что изменения на системе произведены:

```
[centos@clickhouse ~]$ sudo clickhouse status
/var/run/clickhouse-server/clickhouse-server.pid file exists and contains pid = 11382.
The process with pid = 11382 is running.
[centos@clickhouse ~]$ sudo systemctl status vector.service
● vector.service - Vector
   Loaded: loaded (/etc/systemd/system/vector.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since Вс 2023-04-30 13:22:09 UTC; 19min ago
     Docs: https://vector.dev/docs/about/what-is-vector/
  Process: 13411 ExecStart=/usr/bin/vector (code=exited, status=0/SUCCESS)
 Main PID: 13411 (code=exited, status=0/SUCCESS)
```

Повторно запустил playbook с флагом `--diff`:
```
(venv) alex@example ~/repo/netology-ansible/ansible02/playbook (main) $ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] ********************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Create database] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY [Deploy Vector] **********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get Vector version] *****************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get RPM] ****************************************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

TASK [Install Vector] *********************************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

TASK [Configure Vector] *******************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Copy daemon script] *****************************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Configuring service] ****************************************************************************************************************************************************************************************************
changed: [clickhouse-01]

PLAY RECAP ********************************************************************************************************************************************************************************************************************
clickhouse-01              : ok=9    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
```

## Описание playbook

Устанавливает и настраивает Clickhouse и Vector.

### Задачи

#### PLAY [Install Clickhouse]
  - Get clickhouse distrib - скачивает пакеты для установки Clickhouse
  - Install clickhouse packages - устанавливает Clickhouse
  - Create database - создаёт БД

#### PLAY [Deploy Vector] 
  - Get Vector version - проверяет установлен ли Vector. Если нет, запустятся задачи на установку
  - Get RPM - скачивает пакеты для установки Vector
  - Install Vector - устанавливает Vector
  - Configure Vector - копирует конфигурационный файлы Vector из шаблона
  - Copy daemon script - копирует файл systemd-службы Vector из шаблона
  - Configuring service - добавляет службу Vector в автозагрузку и запускает

### Переменные

- `clickhouse_version` - версия Clickhouse
- `clickhouse_packages` - пакеты для установки Clickhouse
- `vector_version` - версия Vector
- `vector_config_template_path` - шаблон конфигурационного файла Vector 
- `vector_service_template_path` - шаблон файла для systemd-службы Vector
- `vector_data_dir` - директория с данными Vector
- `vector_documentation_link` - ссылка на документацию Vector
- `vector_log_output` - значение `StandardOutput` для systemd-службы Vector 
- ` vector_syslog_identifier` - значение `StandardError` для systemd-службы Vector 

### Теги

- `clickhouse` - установка и настройка Clickhouse
- `vector` - установка и настройка Vector




