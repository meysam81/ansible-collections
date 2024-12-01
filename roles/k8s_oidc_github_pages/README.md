# k8s_oidc_github_pages

Fetch Kubernetes OpenID Configuration and JWKs keys and push and deploy them to GitHub Pages as static files.

Grab the OIDC configuration file from K8s API server and push it into a
GitHub repository with Pages enabled.

This will ultimately result in serving static files from a public URL with TLS
enabled.

As a result, the administrator can set up trust relationship with other
service providers, such as AWS, to allow pods inside the Kubernetes cluster
access to third-party cloud services.

Although this is tailored for K3d Kubernetes cluster, there is nothing stopping
it from being used on other Kubernetes clusters.


## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [k8s_oidc_github_pages_commit_email](#k8s_oidc_github_pages_commit_email)
  - [k8s_oidc_github_pages_commit_name](#k8s_oidc_github_pages_commit_name)
  - [k8s_oidc_github_pages_debug](#k8s_oidc_github_pages_debug)
  - [k8s_oidc_github_pages_environments](#k8s_oidc_github_pages_environments)
  - [k8s_oidc_github_pages_github_deploy_key](#k8s_oidc_github_pages_github_deploy_key)
  - [k8s_oidc_github_pages_github_known_hosts_path](#k8s_oidc_github_pages_github_known_hosts_path)
  - [k8s_oidc_github_pages_gpg_private_key_path](#k8s_oidc_github_pages_gpg_private_key_path)
  - [k8s_oidc_github_pages_random_sleep_enabled](#k8s_oidc_github_pages_random_sleep_enabled)
  - [k8s_oidc_github_pages_repository_name](#k8s_oidc_github_pages_repository_name)
  - [k8s_oidc_github_pages_repository_owner](#k8s_oidc_github_pages_repository_owner)
  - [k8s_oidc_github_pages_repository_ssh_url](#k8s_oidc_github_pages_repository_ssh_url)
  - [k8s_oidc_github_pages_sign_gpg_private_key](#k8s_oidc_github_pages_sign_gpg_private_key)
  - [k8s_oidc_github_pages_ssh_config_host](#k8s_oidc_github_pages_ssh_config_host)
  - [k8s_oidc_github_pages_ssh_config_path](#k8s_oidc_github_pages_ssh_config_path)
  - [k8s_oidc_github_pages_ssh_private_key_path](#k8s_oidc_github_pages_ssh_private_key_path)
  - [k8s_oidc_github_pages_timer_calendar](#k8s_oidc_github_pages_timer_calendar)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### k8s_oidc_github_pages_commit_email

#### Default value

```YAML
k8s_oidc_github_pages_commit_email: k8s-oidc-github-pages[bot]@users.noreply.github.com
```

### k8s_oidc_github_pages_commit_name

#### Default value

```YAML
k8s_oidc_github_pages_commit_name: K8s OIDC GitHub Pages
```

### k8s_oidc_github_pages_debug

#### Default value

```YAML
k8s_oidc_github_pages_debug: true
```

### k8s_oidc_github_pages_environments

#### Default value

```YAML
k8s_oidc_github_pages_environments: |
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

### k8s_oidc_github_pages_github_deploy_key

#### Default value

```YAML
k8s_oidc_github_pages_github_deploy_key:
```

### k8s_oidc_github_pages_github_known_hosts_path

#### Default value

```YAML
k8s_oidc_github_pages_github_known_hosts_path: .ssh/known_hosts
```

### k8s_oidc_github_pages_gpg_private_key_path

#### Default value

```YAML
k8s_oidc_github_pages_gpg_private_key_path: .gnupg/github-signing-key.asc
```

### k8s_oidc_github_pages_random_sleep_enabled

#### Default value

```YAML
k8s_oidc_github_pages_random_sleep_enabled: false
```

### k8s_oidc_github_pages_repository_name

#### Default value

```YAML
k8s_oidc_github_pages_repository_name:
```

### k8s_oidc_github_pages_repository_owner

#### Default value

```YAML
k8s_oidc_github_pages_repository_owner:
```

### k8s_oidc_github_pages_repository_ssh_url

#### Default value

```YAML
k8s_oidc_github_pages_repository_ssh_url: git@github.com:{{ k8s_oidc_github_pages_repository_owner
  }}/{{ k8s_oidc_github_pages_repository_name }}.git
```

### k8s_oidc_github_pages_sign_gpg_private_key

#### Default value

```YAML
k8s_oidc_github_pages_sign_gpg_private_key:
```

### k8s_oidc_github_pages_ssh_config_host

#### Default value

```YAML
k8s_oidc_github_pages_ssh_config_host: k8s-oidc-github-pages
```

### k8s_oidc_github_pages_ssh_config_path

#### Default value

```YAML
k8s_oidc_github_pages_ssh_config_path: .ssh/config
```

### k8s_oidc_github_pages_ssh_private_key_path

#### Default value

```YAML
k8s_oidc_github_pages_ssh_private_key_path: .ssh/github-deploy-key
```

### k8s_oidc_github_pages_timer_calendar

#### Default value

```YAML
k8s_oidc_github_pages_timer_calendar: '*:0/5'
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
