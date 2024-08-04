FROM maven:3-openjdk-8

ARG DEBIAN_FRONTEND=noninteractive

ENV DISPLAY :0

ENV USERNAME developer

WORKDIR /workspace

RUN apt update

RUN apt-get install -y --no-install-recommends \
    apt-transport-https sudo \
    software-properties-common \
    wget gpg-agent libswt-gtk-4-java

RUN wget https://dl-ssl.google.com/linux/linux_signing_key.pub -O /tmp/google.pub

RUN gpg --no-default-keyring --keyring /etc/apt/keyrings/google-chrome.gpg --import /tmp/google.pub
    
RUN echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
    
RUN apt update  \
    && apt install -yq google-chrome-stable

# create and switch to a user
RUN echo "backus ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN useradd --no-log-init --home-dir /home/$USERNAME --create-home --shell /bin/bash $USERNAME
RUN adduser $USERNAME sudo
USER $USERNAME

WORKDIR /home/$USERNAME

COPY bin .

ENTRYPOINT ["mvn"]

CMD ["clean", "install", "compile", "gwt:compile", "gwt:devmode"]
