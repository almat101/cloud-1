# Cloud-1 Ansible Deployment Documentation

## Overview

This documentation covers the Ansible-based deployment system for the cloud-1 project, a containerized web application stack featuring WordPress, MariaDB, phpMyAdmin, and Nginx with automated SSL certificate management via Let's Encrypt and Cloudfalre DNS
## Table of Contents

1. [Architecture](#architecture)
2. [Prerequisites](#prerequisites)
3. [Directory Structure](#directory-structure)
4. [Configuration](#configuration)
5. [Deployment](#deployment)
6. [Roles Documentation](#roles-documentation)
7. [Environment Management](#environment-management)
8. [Troubleshooting](#troubleshooting)

## Architecture

The Ansible deployment system follows a role-based architecture with the following components:

```
ansible/
├── inventory/          # Host definitions and variables
├── playbooks/         # Orchestration playbooks
├── roles/            # Reusable automation roles
└── vars/             # Encrypted secrets and variables
```

### Deployment Flow

1. **base_setup**: System preparation and Docker installation
2. **app_code**: Application code deployment from Git
3. **app_config**: Configuration file deployment (.env)
4. **docker_app**: Container orchestration and service management

## Prerequisites

### System Requirements

- **Control Node**: Linux/macOS with Python 3.9+
- **Target Hosts**: 
  - Ubuntu 22+ or Debian 11+
  - Minimum 1GB RAM, 15GB disk space
  - SSH access with sudo privileges

## Directory Structure

```
ansible/
├── ansible.cfg                 # Ansible configuration
├── ansible_venv.sh            # Virtual environment setup script
├── inventory/
│   ├── hosts.ini              # Host inventory
│   └── group_vars/
│       ├── all.yml            # Global variables
│       ├── dev.yml            # Development environment
│       └── prod.yml           # Production environment
├── playbooks/
│   └── deploy.yml             # Main deployment playbook
├── roles/
│   ├── base_setup/            # System setup and Docker installation
│   ├── app_code/              # Git repository management
│   ├── app_config/            # Configuration deployment
│   └── docker_app/            # Container management
└── vars/
    ├── secrets.yml            # Encrypted global secrets
    ├── secrets_dev.yml        # Development secrets
    └── secrets_prod.yml       # Production secrets
```

## Configuration

### Inventory Configuration

#### Development Environment (`inventory/hosts.ini`)

```ini
[dev]
localhost ansible_connection=local ansible_user=ale
```

#### Production Environment (`inventory/hosts.ini`)

```ini
[prod]
ec2_instance ansible_host=your-ec2-instance.compute.amazonaws.com ansible_user=ubuntu
```

### Group Variables

#### Global Variables (`inventory/group_vars/all.yml`)

```yaml
---
app_project: "cloud1"
docker_compose_command: "docker compose"
app_repo_url: "git@github.com:username/cloud-1.git"
app_branch: "main"
```

#### Environment-Specific Variables

**Development** (`inventory/group_vars/dev.yml`):
```yaml
---
app_owner_user: "ale"
app_dest_path: "/home/{{ app_owner_user}}/{{ app_project }}"
app_dest_path_compose: "/home/{{ app_owner_user }}/{{ app_project }}/srcs"
```

**Production** (`inventory/group_vars/prod.yml`):
```yaml
---
app_owner_user: "ubuntu"
app_dest_path: "/home/{{ app_owner_user}}/{{ app_project }}"
app_dest_path_compose: "/home/{{ app_owner_user }}/{{ app_project }}/srcs"
```

### Secrets Management

Secrets are encrypted using Ansible Vault:

```bash
# Create encrypted secrets file
ansible-vault create vars/secrets_prod.yml

# Edit existing secrets
ansible-vault edit vars/secrets_prod.yml

# View encrypted content
ansible-vault view vars/secrets_prod.yml
```

## Deployment

### Environment Setup

1. **Prepare Ansible Environment**:
```bash
cd ansible/
source ansible_venv.sh
```

2. **Configure SSH Access** (Production only):
```bash
# Ensure SSH key is available
chmod 600 ~/.ssh/ec2_ubuntu.pem
```

### Deployment Commands

#### Development Deployment

```bash
# Deploy to localhost
ansible-playbook playbooks/deploy.yml --limit dev --ask-vault-pass --ask-become-pass
```

#### Production Deployment

```bash
# Deploy to EC2 instance
ansible-playbook playbooks/deploy.yml --limit prod --ask-vault-pass
```

#### Specific Role Execution

```bash
# Run only specific roles
ansible-playbook playbooks/deploy.yml --limit dev --tags "app_config" --ask-vault-pass
```

## Roles Documentation

### base_setup Role

**Purpose**: System preparation and Docker installation

**Tasks**:
- Update system packages
- Install Docker Engine and Docker Compose
- Configure user permissions
- Create application directories

**Key Files**:
- [`ansible/roles/base_setup/tasks/main.yml`](ansible/roles/base_setup/tasks/main.yml)

### app_code Role

**Purpose**: Application code deployment from Git repository

**Tasks**:
- Clone/update application code
- Handle Git authentication
- Verify deployment success

**Key Files**:
- [`ansible/roles/app_code/tasks/main.yml`](ansible/roles/app_code/tasks/main.yml)

### app_config Role

**Purpose**: Configuration file deployment

**Tasks**:
- Deploy `.env` file from Jinja2 template
- Set secure file permissions
- Trigger service restart notifications

**Key Files**:
- [`ansible/roles/app_config/tasks/main.yml`](ansible/roles/app_config/tasks/main.yml)
- [`ansible/roles/app_config/templates/.env.j2`](ansible/roles/app_config/templates/.env.j2)

**Handler Integration**:
```yaml
# Uncomment to enable automatic service restart
notify: Restart Docker Compose Services
```

### docker_app Role

**Purpose**: Container lifecycle management

**Tasks**:
- Stop existing containers
- Build Docker images
- Start services with health checks
- Display deployment status

**Key Files**:
- [`ansible/roles/docker_app/tasks/main.yml`](ansible/roles/docker_app/tasks/main.yml)
- [`ansible/roles/docker_app/handlers/main.yml`](ansible/roles/docker_app/handlers/main.yml)

**Handler**:
```yaml
- name: Restart Docker Compose Services
  community.docker.docker_compose_v2:
    project_src: "{{ app_dest_path_compose }}"
    state: restarted
```

## Environment Management

### Environment Variables

The following variables are deployed via the `.env.j2` template:

| Variable | Description | Example |
|----------|-------------|---------|
| **Core Configuration** |
| `DOMAIN_NAME` | Application domain | `cloud1.example.com` |
| `CLOUDFLARE_API_TOKEN` | Cloudflare DNS API token | `abc123...` |
| `EMAIL` | Admin email for SSL certificates | `admin@your-domain.com` |
| `USER` | System user for deployment | `ubuntu` or `ale` |
| **Database Configuration** |
| `MARIA_DB` | MariaDB service name | `mariadb` |
| `MARIA_DB_NAME` | MariaDB database name | `wordpress_db` |
| `MARIA_USER` | WordPress database user | `wp_user` |
| `MARIA_PASSWORD` | WordPress database password | `secure_password123` |
| `MARIA_ROOT_PASSWORD` | MariaDB root password | `root_password123` |
| **WordPress Configuration** |
| `WP_TITLE` | WordPress site title | `cloud1` |
| `WP_USER` | WordPress editor user | `editor` |
| `WP_PASSWORD` | WordPress editor password | `editor_password` |
| `WP_EMAIL` | WordPress editor email | `editor@example.it` |
| `WP_ROOT_USER` | WordPress admin user | `admin` |
| `WP_ROOT_PASSWORD` | WordPress admin password | `admin_password` |
| `WP_ROOT_EMAIL` | WordPress admin email | `admin@example.com` |
| **Access Control** |
| `WP_ADMIN_ACCESSIBLE` | WordPress admin access control | `true/false` |
| `PMA_ACCESSIBLE` | phpMyAdmin access control | `true/false` |
| **phpMyAdmin Configuration** |
| `BLOWFISH_SECRET` | phpMyAdmin encryption secret (32 chars) | `your_blowfish_secret` |
| **Optional Features** |
| `CLOUDFLARE_TUNNEL_TOKEN` | Cloudflare Tunnel token (optional) | `your_tunnel_token` |
| `COMPOSE_BAKE` | Docker Compose build optimization | `true/false` |

### Required Variables by Environment

#### Development Environment (`vars/secrets_dev.yml`)
```yaml
# Core settings
DOMAIN_NAME: "localhost"
CLOUDFLARE_API_TOKEN: "not_required_for_dev"
EMAIL: "dev@localhost"
USER: "ale"

# Database
MARIA_DB: "mariadb"
MARIA_DB_NAME: "wordpress_db"
MARIA_USER: "wp_user"
MARIA_PASSWORD: "dev_password123"
MARIA_ROOT_PASSWORD: "dev_root123"

# WordPress
WP_TITLE: "cloud1-dev"
WP_USER: "dev_user"
WP_PASSWORD: "dev_password"
WP_EMAIL: "dev@localhost"
WP_ROOT_USER: "dev_admin"
WP_ROOT_PASSWORD: "dev_admin_pass"
WP_ROOT_EMAIL: "admin@localhost"

# Access Control (full access for development)
WP_ADMIN_ACCESSIBLE: "true"
PMA_ACCESSIBLE: "true"

# phpMyAdmin
BLOWFISH_SECRET: "dev_secret_32_chars_exactly_123"

# Optional
COMPOSE_BAKE: "true"
```

### Configuration Template

The [`ansible/roles/app_config/templates/.env.j2`](ansible/roles/app_config/templates/.env.j2) template processes these variables:

```jinja2
# Core Configuration
DOMAIN_NAME={{DOMAIN_NAME}}
CLOUDFLARE_API_TOKEN={{CLOUDFLARE_API_TOKEN}}
EMAIL={{EMAIL}}
USER={{USER}}

# Database Configuration
MARIA_DB={{MARIA_DB}}
MARIA_DB_NAME={{MARIA_DB_NAME}}
MARIA_USER={{MARIA_USER}}
MARIA_PASSWORD={{MARIA_PASSWORD}}
MARIA_ROOT_PASSWORD={{MARIA_ROOT_PASSWORD}}

# WordPress Configuration
WP_TITLE={{WP_TITLE}}
WP_USER={{WP_USER}}
WP_PASSWORD={{WP_PASSWORD}}
WP_EMAIL={{WP_EMAIL}}
WP_ROOT_USER={{WP_ROOT_USER}}
WP_ROOT_PASSWORD={{WP_ROOT_PASSWORD}}
WP_ROOT_EMAIL={{WP_ROOT_EMAIL}}

# Access Control
WP_ADMIN_ACCESSIBLE={{WP_ADMIN_ACCESSIBLE}}
PMA_ACCESSIBLE={{PMA_ACCESSIBLE}}

# phpMyAdmin Configuration
BLOWFISH_SECRET={{BLOWFISH_SECRET}}

COMPOSE_BAKE={{COMPOSE_BAKE}}
```

## Troubleshooting

### Common Issues

#### 1. SSH Connection Failures

```bash
# Test SSH connectivity
ansible all -m ping --limit prod

# Debug SSH issues
ansible-playbook playbooks/deploy.yml --limit prod -vvv
```

#### 2. Docker Permission Errors

```bash
# Verify Docker group membership
ansible all -m command -a "groups" --limit prod

# Manual Docker group addition
sudo usermod -aG docker $USER
```

#### 3. Vault Password Issues

```bash
# Store vault password in file
echo "your_vault_password" > .vault_pass
chmod 600 .vault_pass

# Use password file
ansible-playbook playbooks/deploy.yml --vault-password-file .vault_pass
```

#### 4. Service Restart Issues

Enable handler notification in [`ansible/roles/app_config/tasks/main.yml`](ansible/roles/app_config/tasks/main.yml):

```yaml
- name: Deploy .env file from template
  ansible.builtin.template:
    src: .env.j2
    dest: "{{ app_dest_path_compose }}/.env"
    # ... other parameters
  notify: Restart Docker Compose Services  # Uncomment this line
```

### Debugging Commands

```bash
# Check role syntax
ansible-playbook playbooks/deploy.yml --syntax-check

# Dry run deployment
ansible-playbook playbooks/deploy.yml --check --limit dev

# Verbose output
ansible-playbook playbooks/deploy.yml --limit dev -vv
```

### Log Locations

- **Docker logs**: `docker logs <container_name>`
- **System logs**: `/var/log/syslog` or `journalctl -u docker`

## Best Practices

1. **Security**:
   - Always use Ansible Vault for sensitive data
   - Implement proper SSH key management:  
     - Ensure that SSH private keys are securely generated, stored, and used only by authorized users. This includes setting strict file permissions (e.g., `chmod 600 ~/.ssh/ec2_ubuntu.pem`), never sharing private keys, and using a dedicated non-root user (such as `app_owner_user: ubuntu` in the Ansible inventory) for SSH access to the
   - Use least privilege principles:
     - `app_owner_user: ubuntu` in Ansible inventory restricts SSH and OS-level access on the server/EC2 to a non-root user.
     - `nginx` user/group in the container Dockerfiles for WordPress/phpMyAdmin ensures application processes run with

## Advanced Configuration

### Custom Handlers

Create custom handlers for specific restart scenarios:

```yaml
# Custom handler example
- name: Restart Specific Service
  community.docker.docker_compose_v2:
    project_src: "{{ app_dest_path_compose }}"
    restarted: true
    services:
      - nginx
      - wordpress
```

### Conditional Deployments

Use conditionals for environment-specific tasks:

```yaml
- name: Production-only task
  ansible.builtin.debug:
    msg: "This runs only in production"
  when: inventory_hostname in groups['prod']
```

This documentation provides a comprehensive guide for managing the cloud-1 application deployment using Ansible. For container-specific documentation, refer to the companion Container Documentation.