#!/bin/sh
# Version: v1.0.0
# Auth: Hello-Linux
# Desc: initialize the cephadm Install Environment: Ansible、Docker、docker-composer

function init_myenv()
{
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    target_file="$SCRIPT_DIR/roles/ceph_prepare/files/docker-20.10.10.tgz"
    source_file="$SCRIPT_DIR/ansible_docker/docker_offline_package/docker-20.10.10.tgz"
    if [ ! -f "$target_file" ]; then
      cp "$source_file" "$target_file"
    fi
    os_version=$(cat /etc/os-release | grep -E 'NAME="CentOS Linux"|NAME="Rocky Linux"|NAME="Red Hat Enterprise Linux"' | head -n 1)
    if [[ "$os_version" == *"CentOS"* || "$os_version" == *"Rocky"* || "$os_version" == *"Red Hat"* ]]; then
        systemctl stop firewalld
        systemctl disable firewalld
    else
        echo "the current os is not  CentOS 8、Rocky 8 or Red Hat 8."
    fi
}

function init_Docker()
{
    # Install the docker software
    if command -v docker &> /dev/null; then
        echo -e "\033[31m the docker daemon is already running!\033[0m"
    else
        cd ansible_docker/docker_offline_package && tar -zxvf docker-20.10.10.tgz && mv docker/* /usr/bin/
cat << EOF | sed -e 's/^[ \t]*//' > /etc/systemd/system/docker.service
          [Unit]
          Description=Docker Application Container Engine
          Documentation=https://docs.docker.com
          After=network-online.target firewalld.service
          Wants=network-online.target

          [Service]
          Type=notify
          ExecStart=/usr/bin/dockerd --selinux-enabled=false
          ExecReload=/bin/kill -s HUP $MAINPID
          LimitNOFILE=infinity
          LimitNPROC=infinity
          LimitCORE=infinity
          Delegate=yes
          KillMode=process
          Restart=on-failure
          StartLimitBurst=3
          StartLimitInterval=60s

          [Install]
          WantedBy=multi-user.target
EOF
        mkdir -p /etc/docker
        echo '{"features": {"buildkit": true}}' > /etc/docker/daemon.json
        systemctl daemon-reload && systemctl start docker.service && systemctl enable docker.service
    fi
}

function start_Ansible()
{
    # start the ansible's docker for cephadm-ansible
    image_name=$(docker images --format="{{.Repository}}")
    container_name=$(docker ps --format "{{.Names}}")

    if [[ "${image_name[@]}" =~ "cephadm-ansible" ]];then
        echo -e "\033[31m the ansible image is already build!\033[0m"
    else
        gunzip -c ${SCRIPT_DIR}/ansible_docker/ansible_dockerfile/cephadm-ansible.tar.gz | docker load
    fi

    if [[ "${container_name[@]}" =~ "cephadm-ansible" ]];then
        echo -e "\033[31m the cephadm-ansible container is running!\033[0m"
    else
        docker run --rm --name cephadm-ansible -t -i -v /root/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub:ro -v /root/.ssh/id_rsa:/root/.ssh/id_rsa:ro -v ${SCRIPT_DIR}:/etc/ansible -v /tmp:/tmp  cephadm-ansible:v1.0.1 /bin/bash
    fi
}

function start_docker_compose()
{
    cp -rf ansible_docker/docker-compose/docker-compose /usr/local/bin/docker-compose
    if docker-compose --version &> /dev/null; then
        echo -e "\033[32minit docker compose successed!!!!\033[0m"
    else
        echo -e "\033[33minit docker compose failed!!!!\033[0m"
    fi
}

function display_help() {
    echo "Usage: $(basename $0) [options]"
    echo "Options:"
    echo "  --docker         Init Docker"
    echo "  --ansible        Init Ansible"
    echo "  --docker-compose Init docker compose"
    echo "  --help           Display this help message"
}

if [ $# -eq 0 ]; then
    display_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --docker)
            echo "Start docker"
            init_myenv
            init_Docker
            break
            ;;
        --ansible)
            echo "Start ansible"
            start_Ansible
            break
            ;;
        --docker-compose)
            echo "Init docker compose"
            start_docker_compose
            break
            ;;
        --help)
            display_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            display_help
            exit 1
            ;;
    esac
done
