check:
  pre-commit run -a

build:
  ansible-galaxy collection build

publish:
  ansible-galaxy collection publish meysam81-general-$(yq -r .version galaxy.yml).tar.gz --token $ANSIBLE_GALAXY_TOKEN

install:
  ansible-galaxy collection install meysam81-general-$(yq -r .version galaxy.yml).tar.gz

changelog:
  antsibull-changelog lint
  antsibull-changelog release --version $(yq -r .version galaxy.yml)
