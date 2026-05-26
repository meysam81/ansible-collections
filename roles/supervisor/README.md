
Install supervisord and render program blocks from a caller-supplied list

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [supervisor_apt_package](#supervisor_apt_package)
  - [supervisor_config_path](#supervisor_config_path)
  - [supervisor_home](#supervisor_home)
  - [supervisor_logfile_backups](#supervisor_logfile_backups)
  - [supervisor_logfile_maxbytes](#supervisor_logfile_maxbytes)
  - [supervisor_loglevel](#supervisor_loglevel)
  - [supervisor_minfds](#supervisor_minfds)
  - [supervisor_minprocs](#supervisor_minprocs)
  - [supervisor_programs](#supervisor_programs)
  - [supervisor_socket_password](#supervisor_socket_password)
  - [supervisor_socket_path](#supervisor_socket_path)
  - [supervisor_socket_username](#supervisor_socket_username)
  - [supervisor_user](#supervisor_user)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### supervisor_apt_package

#### Default value

```YAML
supervisor_apt_package: supervisor
```

### supervisor_config_path

#### Default value

```YAML
supervisor_config_path: /etc/supervisor/supervisord.conf
```

### supervisor_home

#### Default value

```YAML
supervisor_home: /opt/supervisor
```

### supervisor_logfile_backups

#### Default value

```YAML
supervisor_logfile_backups: 10
```

### supervisor_logfile_maxbytes

#### Default value

```YAML
supervisor_logfile_maxbytes: 50MB
```

### supervisor_loglevel

#### Default value

```YAML
supervisor_loglevel: info
```

### supervisor_minfds

#### Default value

```YAML
supervisor_minfds: 1024
```

### supervisor_minprocs

#### Default value

```YAML
supervisor_minprocs: 200
```

### supervisor_programs

#### Default value

```YAML
supervisor_programs: []
```

### supervisor_socket_password

#### Default value

```YAML
supervisor_socket_password: "{{ ansible_facts['machine_id'] | default('supervisor-change-me') }}"
```

### supervisor_socket_path

#### Default value

```YAML
supervisor_socket_path: /var/run/supervisor.sock
```

### supervisor_socket_username

#### Default value

```YAML
supervisor_socket_username: supervisor
```

### supervisor_user

#### Default value

```YAML
supervisor_user: root
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
