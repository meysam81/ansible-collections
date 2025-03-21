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

ansible-doctor:
  ansible-doctor -rf ./roles

reqs:
  pip install -U pip -r requirements.txt

test-vagrant *args:
  ansible-playbook \
    -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory \
    --ssh-common-args "-o StrictHostKeyChecking=no -o PasswordAuthentication=no -o UserKnownHostsFile=/dev/null" \
    playbook.yml {{args}}
