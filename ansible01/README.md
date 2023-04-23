# Домашнее задание к занятию 1 «Введение в Ansible»

## Основная часть


1. Запустил playbook на окружении из `test.yml`. Значение факта `some_fact` - 12. 
2. В файле group_vars/all/examp.yml заменил значение 12 на `all default fact`.
3. Создал окружение для проведения дальнейших испытаний:
    ```
    docker run -d --name centos7 -it pycontribs/centos:7
    docker run -d --name ubuntu -it pycontribs/ubuntu:latest
    ```
4. Запустил playbook на окружении из `prod.yml`. Значения `some_fact` - `deb`, `el`
5. Заменил значение фактов в `group_vars` на `deb default fact` и `el default fact`.
6. Повторил запуск playbook на окружении `prod.yml`. Убедился, что выдаются корректные значения для всех хостов.
7. Зашифровал факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустил playbook на окружении `prod.yml`. Проверил - пароль запрашивается.
9. Посмотрел при помощи `ansible-doc` список плагинов для подключения. Плагин, подходящий для работы на `control node` - `local`.
10. В `prod.yml` добавил новую группу хостов с именем  `local`, в ней разместил localhost с необходимым типом подключения.
11. Запустил playbook на окружении `prod.yml`. Убедился, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполнил `README.md` ответами на вопросы:
    1. Где расположен файл с `some_fact` из второго пункта задания?
        ```
        /group_vars/all/examp.yml
        ```
    2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?
        ```
        ansible-playbook site.yml -i inventory/test.yml
        ```    
    3. Какой командой можно зашифровать файл?
        ```
        ansible-vault encrypt group_vars/deb/examp.yml    
        ```
    4. Какой командой можно расшифровать файл?
        ```
        ansible-vault decrypt group_vars/deb/examp.yml    
        ```
    5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?
        ```
        ansible-vault view group_vars/deb/examp.yml    
        ```
    6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?
        ```
        ansible-playbook --ask-vault-pass site.yml -i inventory/prod.yml
        ```
    7. Как называется модуль подключения к host на windows?
        ```
        local
        ```
    8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh
        ```
        ansible-doc -t connection ssh
        ```
    9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?
        ```
        remote_user
        ```

## Необязательная часть

1. Расшифровал все зашифрованные файлы с переменными.
2. Зашифровал отдельное значение PaSSw0rd для переменной some_fact паролем netology. Д
    ```
    ansible-vault encrypt_string PaSSw0rd
    ```
   Добавил полученное значение в group_vars/all/examp.yml.
3. Запустил playbook, убедился, что для нужных хостов применился новый fact.
4. Добавил новую группу хостов fedora.
5. Написал [скрипт на bash](auto.sh) для автоматизации поднятия необходимых контейнеров, запуска ansible-playbook и остановки контейнеров.