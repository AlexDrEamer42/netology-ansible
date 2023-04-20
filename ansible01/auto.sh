#!/bin/bash
# Creating containers
docker run -d --name centos7 -it pycontribs/centos:7
docker run -d --name ubuntu -it pycontribs/ubuntu:latest
docker run -d --name fedora -it pycontribs/fedora:latest
# Running playbook
ansible-playbook --ask-vault-pass site.yml -i inventory/prod.yml
# Stopping containers
docker stop centos7 ubuntu fedora

