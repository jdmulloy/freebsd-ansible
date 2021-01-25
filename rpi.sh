#!/bin/sh
set -x

HOST="upi"
KEY=~/.ssh/id_ed25519.pub 
DEFAULT_USER="ubuntu"

##### BEGIN VirtualBox Testing Setup #####
VM_NAME=upi
SNAPSHOT_ID="fec668d3-4791-4b78-a0d1-fe7c23b9656a"
SSH_HOST=localhost
SSH_PORT=2222
#RESET_VM=false
RESET_VM=true

if ${RESET_VM}; then
    VBoxManage controlvm ${VM_NAME} poweroff
    VBoxManage snapshot ${VM_NAME} restore ${SNAPSHOT_ID}
    sleep 1
    while ! VBoxManage startvm ${VM_NAME}; do
        sleep 2
    done

    set +x
    printf "Waiting for ssh to start on VM "
    while ! nc -4w 1 localhost 2222 | grep -q '^SSH'; do
        printf "."
        sleep 1
    done
    echo
    set -x
fi
##### END VirtualBox Testing Setup #####

##### BEGIN Bootstrap Process #####
if ! ssh -o PasswordAuthentication=no ansible@${HOST} whoami > /dev/null; then
    echo "Can't ssh as ansible user, bootstraping"
    # Add ssh key if we can't ssh as the default user
    if ! ssh -o PasswordAuthentication=no ${DEFAULT_USER}@${HOST} whoami > /dev/null; then
        ssh ${DEFAULT_USER}@${HOST} "mkdir -p .ssh; chmod 700 .ssh; echo $(cat ${KEY}) > .ssh/authorized_keys; chmod 600 .ssh/authorized_keys"
    fi
    ansible-playbook bootstrap_ubuntu_rpi.yml -e@secrets.yaml --diff $@
fi
##### END Bootstrap Process #####

# Run regular play
ansible-playbook rpi.yml -e@secrets.yaml --diff $@
