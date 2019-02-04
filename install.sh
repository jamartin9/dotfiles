#!/usr/bin/env bash

set -Eeuxo pipefail
trap "ERROR TRAPPED" ERR

_install_dotfiles(){
    # setup dir
    local OLD_DIR="$( pwd )"
    local CUR_DIR="$( dirname $0 )"
    cd ${CUR_DIR}

    # get branch heads
    git submodule foreach '
    if [ "$path" = "emacs-config" ]; then
        git -C spacemacs checkout develop
    fi
    git checkout master'

    # update
    git submodule update --recursive --merge --remote

    # ensure ansible-playbook
    local ANSIBLE_CMD="ansible-playbook"
    if ! [ -x "$(command -v ${ANSIBLE_CMD})" ]; then
        local PIP_CMD="pip3"
        if ! [ -x "$(command -v ${PIP_CMD})" ]; then
            printf 'PIP INFO: Using pip instead of pip3'
            PIP_CMD="pip"
        fi
        ${PIP_CMD} install --user ansible
        ANSIBLE_CMD="${HOME}/.local/bin/ansible-playbook"
    fi

    # run all playbooks
    for dir in ${CUR_DIR}/*/; do
        cd ${dir}
        ${ANSIBLE_CMD} ./*-playbook.yaml
        cd ..
    done

    ${ANSIBLE_CMD} ./*-playbook.yaml -K

    # return to calling dir
    cd ${OLD_DIR}
}

# run and cleanup
_install_dotfiles
unset _install_dotfiles
