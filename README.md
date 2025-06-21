# cephadmin-ansible
Automate the installation and management of cephadm
# How to run
## 1. Configure ssh non-encryption login
```
Configure ssh non-encryption login between the bootstrap node and other data nodes
```
## 2. Run the following command on the deployment node
```
sh init.sh --docker
sh init.sh --ansible
```
## 3. config hosts
change config to ansible's hosts file

## 4. Run playbook
```
ansible-playbook playbooks/ceph_cluster.yml
```
# Supported Linux versions
* Redhat8 Rocky8 CentOS8
* Centos7 Redhat7
