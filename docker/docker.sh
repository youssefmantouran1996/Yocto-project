#!/bin/bash

# techleef.yml gitignore docker > docker.sh > do_kas_shell
if [ $# -ne 2 ]; then
    echo "Usage: $0 checkout|shell|build <path/to/yml>"
    exit 1 
fi

PROJECT_DIR="$(realpath $(dirname "$0")/..)"

VENV_DIR="${PROJECT_DIR}/yocto-venv"

# Install dependencies for Yocto Scarthgap 
RUN apt-get update && \
    apt-get install -y \
    sudo build-essential chrpath cpio debianutils diffstat file gawk gcc git \
    iputils-ping libacl1 liblz4-tool locales python3 python3-git python3-jinja2 \
    python3-pexpect python3-pip python3-subunit socat texinfo unzip wget \
    xz-utils zstd libncurses5-dev libtinfo-dev\
    && rm -rf /var/lib/apt/lists/*

# Configure locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

do_prepare_env(){
    if [ -d "$VENV_DIR" ]; then
        # Make sure that is actually a python virtual environment
        # If it is not, then fail with an error message
        if [ ! -f "$VENV_DIR/pyvenv.cfg" ]; then
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