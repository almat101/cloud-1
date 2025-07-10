# Cloud-1: Containerized WordPress Stack with Ansible Deployment

A production-ready, containerized WordPress application stack featuring automated SSL certificate management, database administration, and multi-environment deployment using Ansible.

## 🎯 Project Overview

Cloud-1 demonstrates **Infrastructure as Code** principles by combining Docker containerization with Ansible automation to deploy a complete WordPress stack. The project showcases modern DevOps practices including automated SSL certificate management, multi-environment deployment, and secure configuration management.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                             │
└─────────────────────┬───────────────────────────────────────┘
                      │
                ┌─────▼─────┐
                │   Nginx   │ (Port 80/443)
                │  Reverse  │ SSL/TLS Termination
                │   Proxy   │ Let's Encrypt + Cloudflare
                └─────┬─────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
  ┌─────▼─────┐ ┌─────▼─────┐ ┌─────▼─────┐
  │WordPress  │ │phpMyAdmin │ │  Certbot  │
  │   (PHP)   │ │   (Admin) │ │   (SSL)   │
  └─────┬─────┘ └─────┬─────┘ └───────────┘
        │             │
        └─────────────┼─────────────┘
                      │
                ┌─────▼─────┐
                │  MariaDB  │
                │ Database  │
                └───────────┘
```

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- SSH access to target servers (for production)
- Cloudflare account with API token (for production SSL)


### Local Testing
- No SSH required for local testing
- Project runs directly on your current machine
- You have to create your own secrets file (vars/secrets_dev.yml) - see [Configuration](#🔧-configuration)


## 🌟 Key Features

- **🐳 Containerized Stack**: WordPress, MariaDB, phpMyAdmin, Nginx with Alpine Linux base
- **🔐 Automated SSL**: Let's Encrypt certificates with Cloudflare DNS challenge
- **🚀 Multi-Environment**: Separate dev/prod configurations with Ansible
- **🔒 Security-First**: Vault-encrypted secrets, access controls, security headers
- **⚡ Zero-Downtime**: Health checks and graceful service management
- **📊 Monitoring**: Health endpoints and comprehensive logging

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[📖 Ansible Documentation](ansible_doc.md)** | Complete deployment automation guide |
| **[🐳 Microservices Documentation](containers_doc.md)** | Detailed container architecture and services |


## 🔧 Configuration

### Local Development Setup

```bash
# Clone and setup 
git clone https://github.com/almat101/cloud-1.git
cd cloud-1/ansible
# Source the script to enter in the python virtual environment(this install ansible and all its dependencies)
source ansible_venv.sh
```

### Required Environment Variables

Create a Vault-encrypted file for development environment with the following variables. These will be securely transformed into a `.env` file during deployment:

```bash
# Reomove my vault vars
rm -rf vars/secrets_dev.yml
#Create the vault vars
ansible-vault create vars/secrets_dev.yml

```

Each environment file should contain these variables, customized for your specific deployment:

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


## 🏗️ Project Structure

```
cloud-1/
├── README.md                          # Project overview (this file)
├── ansible_doc.md                     # Ansible deployment guide
├── Container_doc.md                   # Container architecture guide
├── ansible/                           # Deployment automation
│   ├── inventory/hosts.ini            # Dev/prod host definitions
│   ├── playbooks/deploy.yml           # Main deployment playbook
│   ├── roles/                         # Ansible automation roles
│   └── vars/                          # Encrypted secrets (Vault)
└── srcs/                              # Container source code
    ├── docker-compose.yml             # Service orchestration
    └── requirements/                  # Service configurations
        ├── nginx/                     # Web server & reverse proxy
        ├── wordpress/                 # WordPress application
        ├── mariadb/                   # Database server
        ├── phpmyadmin/               # Database administration
        └── certbot/                  # SSL certificate management
```

## 🔄 Common Operations

| Task | Command | Requirements |
|------|---------|-------------|
| **Deploy to dev** | `ansible-playbook playbooks/deploy.yml --limit dev --ask-vault-pass --ask-become-pass` | ✅ **Available now** - Local machine only |
| **Deploy to prod** | `ansible-playbook playbooks/deploy.yml --limit prod --ask-vault-pass` | 🚧 **Requires**: AWS instance + domain + DNS |
| **Update code only** | `ansible-playbook playbooks/deploy.yml --limit prod --tags "app_code"` | For production updates |
| **Update config** | `ansible-playbook playbooks/deploy.yml --limit dev --tags "app_config"` | Redeploy environment variables |

### Development Commands (Available Now)
```bash
# Quick development deployment
cd cloud-1/ansible && source ansible_venv.sh
ansible-playbook playbooks/deploy.yml --limit dev --ask-vault-pass --ask-become-pass

# Check your local deployment
docker compose ps
curl -k https://localhost/health
```

## 🛡️ Security Features

- **SSL/TLS**: Automated Let's Encrypt certificates with auto-renewal
- **Access Control**: IP-based restrictions for admin interfaces
- **Secrets Management**: Ansible Vault encryption for sensitive data
- **Network Isolation**: Docker network segmentation
- **Security Headers**: HSTS, secure ciphers, and CSRF protection

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Technologies Used

- **Containerization**: Docker & Docker Compose
- **Automation**: Ansible with role-based architecture
- **Web Server**: Nginx (Alpine Linux)
- **Application**: WordPress with PHP 8.4
- **Database**: MariaDB (Alpine Linux)
- **SSL**: Let's Encrypt with Certbot + Cloudflare DNS
- **Security**: Ansible Vault for secrets management

---

**📖 For detailed technical documentation, see [Ansible Documentation](ansible_doc.md) and [Container Documentation](containers_doc.md)**

Made with ❤️ demonstrating modern DevOps practices with Infrastructure as Code