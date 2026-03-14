#!/usr/bin/env sh

SCRIPT_DIR="$(dirname "$0")"

detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macos"
            ;;
        FreeBSD*)
            OS="freebsd"
            ;;
        Linux*)
            OS="linux"
            detect_linux_distro
            ;;
        *)
            OS="unknown"
            ;;
    esac
}

detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="$ID"
    elif [ -f /etc/redhat-release ]; then
        if grep -q "Fedora" /etc/redhat-release; then
            DISTRO="fedora"
        else
            DISTRO="rhel"
        fi
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    else
        DISTRO="unknown"
    fi
}

install_ansible_macos() {
    if ! command -v ansible >/dev/null 2>&1; then
        if ! command -v brew >/dev/null 2>&1; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        echo "Installing Ansible on macOS..."
        brew install ansible
    fi
}

install_ansible_freebsd() {
    if ! command -v ansible >/dev/null 2>&1; then
        echo "Installing Ansible on FreeBSD..."
        pkg install py311-ansible
    fi
}

install_ansible_fedora() {
    if ! command -v ansible >/dev/null 2>&1; then
        echo "Installing Ansible on Fedora..."
        sudo dnf install -y ansible
    fi
}

install_ansible_ubuntu() {
    if ! command -v ansible >/dev/null 2>&1; then
        echo "Installing Ansible on Ubuntu..."
        sudo apt update
        sudo apt install -y ansible
    fi
}

install_ansible_arch() {
    if ! command -v ansible >/dev/null 2>&1; then
        echo "Installing Ansible on Arch..."
        sudo pacman -S --noconfirm ansible
    fi
}

install_ansible_alpine() {
    if ! command -v ansible >/dev/null 2>&1; then
        echo "Installing Ansible on Alpine..."
        apk add ansible
    fi
}

install_ansible() {
    case "$OS" in
        macos)
            install_ansible_macos
            ;;
        freebsd)
            install_ansible_freebsd
            ;;
        linux)
            case "$DISTRO" in
                fedora|rhel)
                    install_ansible_fedora
                    ;;
                debian|ubuntu)
                    install_ansible_ubuntu
                    ;;
                arch)
                    install_ansible_arch
                    ;;
                alpine)
                    install_ansible_alpine
                    ;;
                *)
                    echo "Unsupported distribution: $DISTRO"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

run_ansible_playbook() {
    COMMON_PLAYBOOK="$SCRIPT_DIR/ansible/common.yml"
    if [ -f "$COMMON_PLAYBOOK" ]; then
        echo "Running common Ansible playbook: $COMMON_PLAYBOOK"
        ansible-playbook "$COMMON_PLAYBOOK"
    fi

    PLAYBOOK="$SCRIPT_DIR/ansible/${OS}.yml"
    if [ -f "$PLAYBOOK" ]; then
        echo "Running Ansible playbook: $PLAYBOOK"
        ansible-playbook "$PLAYBOOK"
    else
        echo "No playbook found for $OS at $PLAYBOOK"
        exit 1
    fi
}

main() {
    detect_os

    echo "Operating System: $OS"
    if [ "$OS" = "linux" ]; then
        echo "Distribution: $DISTRO"
    fi

    install_ansible
    run_ansible_playbook
}

main "$@"
