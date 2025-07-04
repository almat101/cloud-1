#!/bin/bash

ANSIBLE_PROJECT_DIR=$(pwd)
VENV_NAME="venv"
VENV_PATH="$ANSIBLE_PROJECT_DIR/$VENV_NAME"

echo "Checking python version..."
python3 --version

cd "$ANSIBLE_PROJECT_DIR" || { echo "Error: Could not change to directory $ANSIBLE_PROJECT_DIR"; exit 1; }

echo "installing venv..."
if [ ! -d "$VENV_PATH" ]; then
	echo "venv not found. Creating it..."
	python3 -m venv "$VENV_PATH"
	if [ $? -ne 0 ]; then
		echo "error creating venv"
		exit 1
	fi
	echo "venv created at $VENV_PATH"
fi

echo "activating venv..."

if [ -f "$VENV_PATH/bin/activate" ]; then
	source "$VENV_PATH/bin/activate"
	if [ $? -ne 0 ]; then
		echo "error sourcing venv"
		exit 1
	fi
	echo "venv $VENV_NAME activated!"
fi


#install Ansible and community.docker if not present
echo "Checking for Ansible and community.docker installation..."
if ! python -c "import ansible" &> /dev/null; then
    echo "Ansible not found. Installing..."
    pip install ansible
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install Ansible."
        exit 1
    fi
    echo "Ansible installed successfully."
fi

# Verify ansible-galaxy is available after installation
echo "Verifying ansible-galaxy command..."
if ! command -v ansible-galaxy &> /dev/null; then
    echo "Error: ansible-galaxy command not found even after Ansible installation."
    echo "This might indicate an issue with the virtual environment PATH."
    echo "Try running: pip install --upgrade ansible"
    exit 1
fi

if ! python -c "import ansible.collections.community.docker" &> /dev/null; then
    echo "community.docker collection not found. Installing..."
    # The 'community.docker' collection is installed via 'ansible-galaxy collection install'
    ansible-galaxy collection install community.docker
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install community.docker collection."
        exit 1
    fi
    echo "community.docker collection installed successfully."
fi

echo "Ansible and community.docker are ready."
echo "You are now in the Ansible virtual environment."
echo "You can now run Ansible commands (e.g., 'ansible --version', 'ansible-playbook')."
echo "To exit the virtual environment, simply type 'deactivate'."

# Keep the shell open so the venv remains active
# This script does not exit the shell, it just activates the venv within the current shell.
# If you run this script with `bash setup_ansible_venv.sh`, it will activate the venv
# in a sub-shell and then deactivate when the script finishes.
# To activate it in your *current* shell, you must `source` the script:
# `source setup_ansible_venv.sh` or `. setup_ansible_venv.sh`
