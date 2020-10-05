FROM ubuntu:18.04

# apt prerequisites
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    gnupg-agent \
    iptables \
    lsb-release \
    libdevmapper1.02.1 \
    sudo \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# docker prep
COPY files/ .
RUN dpkg -i containerd.io_1.3.7-1_amd64.deb
RUN dpkg -i docker-ce-cli_19.03.9_3-0_ubuntu-bionic_amd64.deb
RUN dpkg -i docker-ce_19.03.9_3-0_ubuntu-bionic_amd64.deb

# kubectl prep
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list

# apt install
RUN apt-get update && apt-get install -y \
    bash \
    gnupg \
    ca-certificates \
    gettext-base \
    git \
    jq \
    kubectl \
    openssh-client \
    perl \
    vim-tiny \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

#install python
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

#install yq
ENV YQ_VERSION=2.4.0
ENV YQ_SHA256SUM=E49496D75FA3BAE1AE91DB98E6820B153A3727654CA34419BF72117490EEA12C
ADD https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 /usr/local/bin/yq
RUN echo "${YQ_SHA256SUM} /usr/local/bin/yq"
RUN chmod +x /usr/local/bin/yq

# install helm v3
ENV HELM3_VERSION=v3.1.2
ENV HELM3_SHA256SUM=e6be589df85076108c33e12e60cfb85dcd82c5d756a6f6ebc8de0ee505c9fd4c
ADD https://get.helm.sh/helm-${HELM3_VERSION}-linux-amd64.tar.gz /tmp/helm3.tar.gz
RUN echo "${HELM3_SHA256SUM} /tmp/helm3.tar.gz" | sha256sum -c \
    && tar -zxvf /tmp/helm3.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm3 \
    && rm -rf /tmp/helm3.tar.gz


# configure non-root user to run as
RUN adduser --disabled-password -u 1000 --shell /bin/sh user --gecos ""
USER user

WORKDIR /src

ENTRYPOINT /bin/sh