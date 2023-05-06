# Домашнее задание к занятию 4 «Работа с roles»

1. Создал файл `requirements.yml`, добавил туда источник роли `clickhouse`.
2. Скачал роль `clickhouse`:
    ```
    ansible-galaxy install -r requirements.yml -p roles
    ```
3. Создал каталог для роли `vector-role`:
    ```
    ansible-galaxy role init vector-role
    ```
4. Перенёс задачи и переменные из плейбука в созданную роль.
5. Перенёс шаблоны из плейбука в созданную роль.
6. Добавил описание роли в `README.md`.
7. Выполнил аналогичные действия для роли `lighthouse-role`.
8. Загрузил созданные роли в репозитории. Указал для них версию 1.0.0. Добавил роли в `requirements.yml`.
9. Переписал плейбук на использование ролей.
10. Загрузил плейбук в репозиторий.
11. Ссылки на репозитории:

    | Репозиторий       | Ссылка                                                               |
    |-------------------|----------------------------------------------------------------------|
    | Основной плейбук | https://github.com/AlexDrEamer42/netology-ansible/tree/main/ansible04 |
    | vector-role       | https://github.com/AlexDrEamer42/vector-role              |
    | lighthouse-role   | https://github.com/AlexDrEamer42/lighthouse-role       |
    