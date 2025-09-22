#!/bin/bash

# techleef.yml gitignore docker > docker.sh > do_kas_shell

VENV_DIR="../yocto-venv"

do_prepare_env(){
    if [ -d "$VENV_DIR" ]; then
        # Make sure that is actually a python virtual environment
        # If it is not, then fail with an error message
        if [ ! -f "$VENV_DIR/bin/activate" ]; then
            echo "[X] $VENV_DIR exists but is not a valid Python virtual environment"
            exit 1
        fi
    else
        python3 -m venv "$VENV_DIR"
        if [ $? -ne 0 ]; then
            echo "[X] Failed to create the venv"
            exit 1
        fi
    fi
    
    # Source the venv
    echo "[+] Sourcing the Python venv"
    source "$VENV_DIR/bin/activate"
    if [ $? -ne 0 ]; then
        echo "[X] Failed to source the venv"
        exit 1
    fi
    
    # Install "kas"
    if ! pip3 install kas; then
        echo "[x] Error installing kas ..."
        exit 1
    fi
}

do_kas_checkout(){
    local yml="${1}"
    kas-container checkout "${yml}"
}

do_kas_build(){
    local yml="${1}"
    kas-container build "${yml}"
}

do_kas_shell(){
    kas-container shell "${1}"
}

main(){
    do_prepare_env
    local action="${1}"
    local yml="${2}"
    
    if [ ! -f "${yml}" ]; then
        echo "[x] ${yml} does not exist"
        exit 1
    fi
    
    if [ "${action}" == "checkout" ]; then
        do_kas_checkout "${yml}"
    elif [ "${action}" == "shell" ]; then
        do_kas_shell "${yml}"
    elif [ "${action}" == "build" ]; then
        do_kas_build "${yml}"
    else
        echo "[x] Wrong action. Use: checkout, shell, or build"
        exit 1
    fi
}

# Call main function with all arguments
main "$@"