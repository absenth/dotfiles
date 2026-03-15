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
        sudo pkg install py311-ansible
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
    CHEZMOI_ANSIBLE_DIR="$HOME/.local/share/chezmoi/ansible"
    VAULT_FILE="$HOME/.local/share/chezmoi/dot_ssh_private_key.vault"
    SSH_KEY="$HOME/.ssh/id_ed25519"
    SSH_KEY_PUB="$HOME/.ssh/id_ed25519.pub"
    CURRENT_USER=$(whoami)
    EXTRA_VARS="target_user=$CURRENT_USER"

    if [ -f "$VAULT_FILE" ] && [ ! -f "$SSH_KEY" ]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        echo "Decrypting SSH private key..."
        ansible-vault decrypt "$VAULT_FILE" --output "$SSH_KEY"
        chmod 600 "$SSH_KEY"
    fi

    if [ -f "$HOME/.local/share/chezmoi/dot_ssh_public_key" ] && [ ! -f "$SSH_KEY_PUB" ]; then
        mkdir -p "$HOME/.ssh"
        cp "$HOME/.local/share/chezmoi/dot_ssh_public_key" "$SSH_KEY_PUB"
        chmod 644 "$SSH_KEY_PUB"
    fi

    COMMON_PLAYBOOK="$CHEZMOI_ANSIBLE_DIR/common.yml"
    if [ -f "$COMMON_PLAYBOOK" ]; then
        echo "Running common Ansible playbook: $COMMON_PLAYBOOK"
        ansible-playbook "$COMMON_PLAYBOOK" -e "$EXTRA_VARS"
    fi

    PLAYBOOK="$CHEZMOI_ANSIBLE_DIR/${OS}.yml"
    if [ -f "$PLAYBOOK" ]; then
        echo "Running Ansible playbook: $PLAYBOOK"
        if [ "$OS" = "linux" ] || [ "$OS" = "freebsd" ]; then
            ansible-playbook "$PLAYBOOK" --ask-become-pass -e "$EXTRA_VARS"
        else
            ansible-playbook "$PLAYBOOK" -e "$EXTRA_VARS"
        fi
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
