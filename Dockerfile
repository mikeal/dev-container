FROM debian:latest
FROM node:10

WORKDIR /root

RUN apt-get update && apt-get install -y \
  git \
  vim \
  zsh \
  screen \
  curl

RUN zsh -c exit

# Configure zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Configure screen
RUN echo "startup_message off" >> /root/.screenrc
RUN echo 'shell "/usr/bin/zsh"' >> /root/.screenrc
RUN echo "screen -U" >> /root/.profile

# Configure npm
RUN echo "export PATH=$PATH:./node_modules/.bin" >> /root/.zshrc

# Configure git
RUN git config --global user.name "Mikeal Rogers"
RUN git config --global user.email mikeal.rogers@gmail.com
RUN git config --global core.editor vim
RUN git config --global credential.helper 'store --file ~/.git-credentials'

RUN git clone https://github.com/mikeal/mikealrogers.com.git
RUN git clone https://github.com/ProtoSchool/protoschool.github.io.git
RUN git clone https://github.com/protocol/github-org-metrics.git

WORKDIR /root/mikealrogers.com
RUN npm install
WORKDIR /root/protoschool
RUN npm install
WORKDIR /root/github-org-metrics
RUN npm install

WORKDIR /root

EXPOSE 8080

# start image with docker run -it -p 8080:8080 dev /bin/zsh