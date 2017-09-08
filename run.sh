#!/bin/sh

ansible-playbook test.yml -e@secrets.yaml --diff $@
