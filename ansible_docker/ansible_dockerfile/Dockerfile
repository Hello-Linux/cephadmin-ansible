# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 alpine:3.15.11
LABEL author="Hello-Linux"
ENV LANG en_US.utf8
ENV PS1='\[\033[1;32m\]\u@\h\[\033[0m\]\[\033[1;31m\]:Cephadm\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ '
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && echo "nameserver 114.114.114.114" >> /etc/resolv.conf \ 
    && apk update \
    && apk --no-cache add bash vim openssh openssh-server sshpass ansible figlet \
    && ssh-keygen -t rsa -b 4096 -C "Hello-Linux@example.com" -f ~/.ssh/id_rsa -N "" \
    && echo 'figlet -w 105 -f standard -r "Cephadm with Ansible"' > ~/.bashrc \
    && source ~/.bashrc
WORKDIR /etc/ansible
USER root
HEALTHCHECK --interval=5m --timeout=5s --retries=3 CMD ansible localhost -m ping  || exit 1
