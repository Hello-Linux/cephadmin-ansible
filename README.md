# cephadmin-ansible
Automate the installation and management of cephadm
# How to run
## 1. Init the environment
```
sh init.sh --docker
sh init.sh --ansible
```
## 3. config hosts
change config to ansible's hosts file

## 2. Run playbook
```
ansible-playbook playbooks/ceph_cluster.yml
```
# Supported Linux versions
* Redhat8
* Centos7 Centos8
* Rocky8
