# Kratos

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.7.0
```

## Usage

### kratos-server-config.yml.j2

```yaml
dsn: memory

courier:
  smtp:
    # checkov:skip=CKV_SECRET_4:Basic Auth Credentials
    connection_uri: smtps://test:test@mailslurper:1025/?skip_ssl_verify=true

selfservice:
  default_browser_return_url: http://example.com

identity:
  schemas:
    - id: default
      url: https://github.com/ory/kratos/raw/refs/tags/v1.3.1/contrib/quickstart/kratos/email-password/identity.schema.json
```

### kratos-envs.yml.j2

```yaml
COURIER_SMTP_CONNECTION_URI: "{{ kratos_courier_smtp_connection_uri }}"
DSN: postgres://kratos:{{ postgres_kratos_password }}@localhost:5432/kratos?sslmode=disable
SECRETS_CIPHER_0: "{{ kratos_secrets_cipher }}"
SECRETS_COOKIE_0: "{{ kratos_secrets_cookie }}"
SECRETS_DEFAULT_0: "{{ kratos_secrets_default }}"
SELFSERVICE_METHODS_OIDC_CONFIG_PROVIDERS_0_CLIENT_ID: "{{ kratos_oidc_microsoft_client_id }}"
SELFSERVICE_METHODS_OIDC_CONFIG_PROVIDERS_0_CLIENT_SECRET: "{{ kratos_oidc_microsoft_client_secret }}"
```

### playbook.yml

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  tasks:
  roles:
    - name: meysam81.general.kratos
      tags: kratos
      vars:
        kratos_version: v1.3.1
        kratos_configuration: "{{ lookup('ansible.builtin.template', 'kratos-server-config.yml.j2') }}"
        kratos_envs: "{{ lookup('ansible.builtin.template', 'kratos-envs.yml.j2') }}"
```
