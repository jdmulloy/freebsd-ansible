#!/bin/sh

ansible-playbook bootstrap.yml --diff $@
