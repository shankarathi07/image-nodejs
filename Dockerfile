FROM node:11-stretch-slim

RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list && \
    wget https://dl-ssl.google.com/linux/linux_signing_key.pub && \
    apt-key add linux_signing_key.pub && \
    rm linux_signing_key.pub

RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y openssl && \
    apt-get install -y google-chrome-stable

RUN chmod u+w /etc/sudoers && echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV HOME /home/devops

# Create devops user
RUN groupadd --force sudo && \
    groupadd -g 10000 devops && \
    useradd -u 10000 -g 10000 -G sudo -d ${HOME} -m devops && \
    usermod --password $(echo password | openssl passwd -1 -stdin) devops

USER devops
WORKDIR ${HOME}

RUN curl -sL https://ibm.biz/idt-installer | bash

COPY src/npm-bashrc ${HOME}/.npm-bashrc

RUN mkdir "${HOME}/.npm-packages" && \
    echo "prefix=${HOME}/.npm-packages" >> ${HOME}/.npmrc && \
    cat ${HOME}/.npm-bashrc >> ${HOME}/.bashrc && \
    cat ${HOME}/.npm-bashrc >> ${HOME}/.zshrc

ENTRYPOINT /bin/bash
