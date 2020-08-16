FROM node:12-stretch-slim

RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y openssl && \
    apt-get install -y curl && \
    apt-get install -y gnupg

RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list
RUN curl -O https://dl-ssl.google.com/linux/linux_signing_key.pub
RUN apt-key add linux_signing_key.pub
RUN rm linux_signing_key.pub

RUN apt-get update && \
    apt-get install -y google-chrome-stable

RUN chmod u+w /etc/sudoers && echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV HOME /home/devops

# Create devops user
RUN groupadd --force sudo && \
    useradd -u 10000 -g 0 -G sudo -d ${HOME} -m devops && \
    usermod --password $(echo password | openssl passwd -1 -stdin) devops && \
    chmod g+wx -R ${HOME}

USER devops
WORKDIR ${HOME}

COPY src/npm-bashrc ${HOME}/.npm-bashrc

RUN mkdir "${HOME}/.npm-packages" && \
    chmod g+w "${HOME}/.npm-packages" && \
    mkdir "${HOME}/.npm" && \
    chmod g+w "${HOME}/.npm" && \
    echo "prefix=${HOME}/.npm-packages" >> ${HOME}/.npmrc && \
    cat ${HOME}/.npm-bashrc >> ${HOME}/.bashrc && \
    cat ${HOME}/.npm-bashrc >> ${HOME}/.zshrc

ENTRYPOINT /bin/bash
