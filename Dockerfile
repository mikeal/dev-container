FROM debian:latest
FROM node:10

WORKDIR /root

RUN apt-get update && apt-get install -y \
  git \
  vim \
  zsh \
  tmux \
  locales \
  curl \
  unzip \
  jq

RUN zsh -c exit

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
export PATH=$PATH:./node_modules/.bin \n\
export LC_CTYPE=en_US.UTF-8 \n\
ZSH_THEME=dracula \n\
" >> ~/.zshrc

RUN curl -L https://raw.githubusercontent.com/dracula/zsh/master/dracula.zsh-theme > ~/.oh-my-zsh/themes/dracula.zsh-theme

# Configure vim
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    mkdir -p ~/.vim/colors && \
    curl -L \
    https://raw.githubusercontent.com/dracula/vim/master/colors/dracula.vim > ~/.vim/colors/dracula.vim


RUN echo "\n\
call plug#begin('~/.vim/plugged') \n\
Plug 'vim-scripts/SyntaxComplete' \n\
Plug 'sheerun/vim-polyglot' \n\
call plug#end() \n\
syntax on \n\
color dracula \n\
highlight Visual cterm=reverse ctermbg=NONE \n\
set tabstop=2 \n\
set shiftwidth=2 \n\
set softtabstop=2 \n\
set expandtab \n\
" >> ~/.vimrc

RUN vim +PlugInstall +qall

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

COPY start.sh .start

# start image with docker run -it -p 8080:8080 dev /root/.start
