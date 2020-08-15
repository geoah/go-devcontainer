# Update the VARIANT arg in devcontainer.json to pick an Go version
ARG VARIANT=1.15
FROM golang:${VARIANT}

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Your actual UID, GID on Linux if not the default 1000
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Make git fetch repos from git over https
RUN git config --global url."https://github.com/".insteadOf git@github.com: \
    && git config --global url."https://".insteadOf git://

# Install needed packages.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        apt-utils \
        dialog \
        nano \
        vim \
        zsh \
        wget \
    && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -r /var/cache/* /var/lib/apt/lists/*

# Create a non-root user to use.
RUN groupadd --gid $USER_GID $USERNAME
RUN useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME

ENV GO111MODULE=auto

# Install Go tools
RUN go get -v \
    # Base Go tools needed for VS code Go extension
    github.com/mdempsky/gocode \
    github.com/uudashr/gopkgs/v2/cmd/gopkgs \
    github.com/ramya-rao-a/go-outline \
    github.com/acroca/go-symbols \
    golang.org/x/tools/cmd/guru \
    golang.org/x/tools/cmd/gorename \
    github.com/cweill/gotests/... \
    github.com/fatih/gomodifytags \
    github.com/josharian/impl \
    github.com/davidrjenni/reftools/cmd/fillstruct \
    github.com/haya14busa/goplay/cmd/goplay \
    github.com/godoctor/godoctor \
    github.com/go-delve/delve/cmd/dlv \
    github.com/stamblerre/gocode \
    github.com/rogpeppe/godef \
    golang.org/x/tools/cmd/goimports \
    golang.org/x/tools/gopls \
    2>&1

RUN rm -rf $GOPATH/pkg/* $GOPATH/src/* /root/.cache/go-build
RUN chown -R ${USER_UID}:${USER_GID} $GOPATH
RUN chmod -R 777 $GOPATH

USER vscode

# Install zsh
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> /home/${USERNAME}/.zshrc
