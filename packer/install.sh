#!/bin/bash

USERNAME="${1}"
SSH_KEY=$(cat /tmp/id_rsa.pub)

adduser "${USERNAME}"
usermod -aG 'wheel' "${USERNAME}"

mkdir "/home/${USERNAME}/.ssh"
chown "${USERNAME}":"${USERNAME}" "/home/${USERNAME}/.ssh"
echo "${SSH_KEY}" | tee "/home/${USERNAME}/.ssh/authorized_keys"

chmod 600 "/home/${USERNAME}/.ssh/authorized_keys"
chown "${USERNAME}":"${USERNAME}" "/home/${USERNAME}/.ssh/authorized_keys"

# GCE
[[ -n "$(grep google-sudoers /etc/group)" ]] && usermod -aG 'google-sudoers' "${USERNAME}" && exit 0
