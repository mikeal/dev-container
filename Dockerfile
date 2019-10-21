FROM debian:latest
FROM node:12

WORKDIR /root

RUN apt-get update && apt-get install -y \
  git \
  vim \
  zsh \
  tmux \
  locales \
  curl \
  unzip \
  awscli \
  net-tools \
  build-essential \
  golang \
  jq
  
# Install Puppeteer Deps
RUN apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
  libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
  libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
  libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
  ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget


RUN zsh -c exit

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Install 1password
RUN curl -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/v0.5.5/op_linux_amd64_v0.5.5.zip && \
    unzip 1password.zip -d /usr/bin && \
rm 1password.zip

# Configure locale

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen

# Configure zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

RUN echo "\n\
export PATH=$PATH:./node_modules/.bin:../node_modules/.bin \n\
export LC_CTYPE=en_US.UTF-8 \n\
alias coverage='npx http-server coverage' \n\
alias tmux='tmux -2' \n\
export AWS_REGION=us-west-2 \n\
export AWS_PROFILE=pl \n\
export GOROOT=/usr/lib/go \n\
export GOPATH=$HOME/go \n\
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/go/bin:/root/go/bin:./node_modules/.bin:../node_modules/.bin \n\
" >> ~/.zshrc

RUN curl -L https://raw.githubusercontent.com/dracula/zsh/master/dracula.zsh-theme > ~/.oh-my-zsh/themes/dracula.zsh-theme

RUN echo "\n\
access=public\n\
init-author-name=Mikeal Rogers\n\
init-author-email=mikeal.rogers@gmail.com\n\
init-author-url=https://www.mikealrogers.com/\n\
init-license=(Apache-2.0 AND MIT)\n\
init-version=0.0.0\n\
" >> ~/.npmrc

# Configure git
RUN git config --global user.name "Mikeal Rogers" && \
    git config --global user.email mikeal.rogers@gmail.com && \
    git config --global core.editor vim && \
    git config --global credential.helper 'store --file ~/.git-credentials'

EXPOSE 8080

# Configure tmux
RUN git clone https://github.com/gpakosz/.tmux.git && \
    ln -s -f .tmux/.tmux.conf && \
    cp .tmux/.tmux.conf.local .

# Configure zsh in tmux
RUN echo "\n\
set-option -g default-shell /bin/zsh \n\
" >> ~/.tmux.conf.local

COPY start.sh .start

RUN mkdir -p /root/.aws

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

RUN /root/.cargo/bin/cargo install starship

RUN echo "\neval \"$(starship init zsh)\""

COPY tmux.conf.txt /root/.tmux.conf.local

RUN mkdir /root/.config

COPY starship.txt /root/.confg/starship.toml

COPY vimrc.txt /root/.vimrc

# start image with docker run -it -p 8080:8080 dev /root/.start
