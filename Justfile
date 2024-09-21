check:
  pre-commit run -a

build:
  ansible-galaxy collection build

publish:
  ansible-galaxy collection publish meysam81-general-$(yq -r .version galaxy.yml).tar.gz --token $ANSIBLE_GALAXY_TOKEN

install:
  ansible-galaxy collection install meysam81-general-$(yq -r .version galaxy.yml).tar.gz

@role-init rolename:
  cd roles && \
    ansible-galaxy role init {{rolename}}

changelog:
  git-cliff --verbose --config cliff.toml > CHANGELOG.md
