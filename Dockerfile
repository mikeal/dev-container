FROM debian:latest
FROM node:10

WORKDIR /root

RUN apt-get update && apt-get install -y \
  git \
  vim \
  zsh \
  tmux \
  locales \
  curl

RUN zsh -c exit

# Configure locale

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen

# Configure zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

RUN echo "export LC_CTYPE=en_US.UTF-8" >> ~/.zshrc

# Configure npm
RUN echo "export PATH=$PATH:./node_modules/.bin" >> /root/.zshrc

# Configure git
RUN git config --global user.name "Mikeal Rogers"
RUN git config --global user.email mikeal.rogers@gmail.com
RUN git config --global core.editor vim
RUN git config --global credential.helper 'store --file ~/.git-credentials'

WORKDIR /root

EXPOSE 8080

# Configure tmux
RUN git clone https://github.com/gpakosz/.tmux.git
RUN ln -s -f .tmux/.tmux.conf
RUN cp .tmux/.tmux.conf.local .

# start image with docker run -it -p 8080:8080 dev /bin/zsh
