FROM ubuntu:24.04

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]
COPY cli-plugins.json /tmp/config.json

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=dumb \
    PAGER=cat \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# hadolint ignore=DL3008,SC2174,DL4001
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci && \
    echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci && apt-get update && \
    apt-get install --no-install-recommends -y \
            curl \
            locales \
            autoconf \
            build-essential \
            ca-certificates \
            gettext-base \
            apt-transport-https \
            lsb-release \
            libcurl4-openssl-dev \
            libssl-dev \
            software-properties-common \
            gcc \
            g++ \
            cmake \
            make \
            lsof \
            pkg-config \
            retry \
            file \
            gnupg \
            gnupg-agent \
            jq \
            tar \
            tzdata \
            unzip \
            wget \
            gzip \
            bzip2 \
            zip && \
    add-apt-repository ppa:git-core/ppa && apt-get update && \
    apt-get install --no-install-recommends -y git && \
    download_version="$(curl -s https://api.github.com/repos/powerman/dockerize/tags | jq -r '.[0].name' | head -n 1)" && \
    curl -SL --output dockerize "https://github.com/powerman/dockerize/releases/download/$download_version/dockerize-$download_version-linux-amd64" && \
    chmod +x dockerize && mv dockerize /usr/local/bin && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && apt-get install --no-install-recommends -y git-lfs && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && apt-get update && \
    apt-get install --no-install-recommends -y \
            gh \
            vault \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin && \
    download_version=$(curl -s "https://api.github.com/repos/docker/scout-cli/releases/latest" | jq -r .tag_name) && \
    download_url="https://github.com/docker/scout-cli/releases/download/${download_version}/docker-scout_${download_version:1}_linux_amd64.tar.gz" && \
    curl -fL -O "${download_url}" && \
    tar -xzf "docker-scout_${download_version:1}_linux_amd64.tar.gz" docker-scout && rm "docker-scout_${download_version:1}_linux_amd64.tar.gz" && \
    mkdir -p "$HOME/.docker/cli-plugins" && mv docker-scout "$HOME/.docker/cli-plugins/docker-scout" && \
    mv /tmp/config.json "$HOME/.docker/config.json" && \
    current_version="v$(curl https://app-updates.agilebits.com/check/1/0/CLI2/en/2.0.0/N -s | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')" && \
    curl -sSfo op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/$current_version/op_linux_amd64_$current_version.zip" && \
    unzip -od /usr/local/bin/ op.zip && rm op.zip && \
    curl -SLO "https://github.com/tellerops/teller/releases/download/v1.5.6/teller_1.5.6_Linux_x86_64.tar.gz" && \
    tar -xvf teller_1.5.6_Linux_x86_64.tar.gz teller && \
    mv ./teller /usr/local/bin/teller && \
    rm teller_1.5.6_Linux_x86_64.tar.gz && \
    mkdir /root/.gnupg && \
    bash -c "echo 'allow-loopback-pinentry' > /root/.gnupg/gpg-agent.conf" && \
    bash -c "echo 'pinentry-mode loopback' > /root/.gnupg/gpg.conf" && \
    chmod 700 /root/.gnupg && chmod 600 /root/.gnupg/* && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
