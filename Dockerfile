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
RUN echo "export LC_CTYPE=en_US.UTF-8" >> ~/.zshrc
RUN curl -L https://raw.githubusercontent.com/dracula/zsh/master/dracula.zsh-theme > ~/.oh-my-zsh/themes/dracula.zsh-theme
RUN echo 'ZSH_THEME="dracula"' >> ~/.zshrc

# Configure vim
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN mkdir -p ~/.vim/colors
RUN curl -L https://raw.githubusercontent.com/dracula/vim/master/colors/dracula.vim > ~/.vim/colors/dracula.vim
RUN echo "call plug#begin('~/.vim/plugged')" >> ~/.vimrc
RUN echo "Plug 'vim-scripts/SyntaxComplete'" >> ~/.vimrc
RUN echo "Plug 'sheerun/vim-polyglot'" >> ~/.vimrc
# RUN echo "Plug 'ahayman/vim-nodejs-complete'" >> ~/.vimrc
# RUN echo "Plug 'pangloss/vim-javascript'" >> ~/.vimrc
# RUN echo "Plug 'othree/javascript-libraries-syntax.vim'" >> ~/.vimrc
RUN echo "call plug#end()" >> ~/.vimrc
RUN echo "syntax on" >> ~/.vimrc
RUN echo "color dracula" >> ~/.vimrc
RUN vim +PlugInstall +qall

RUN echo "set tabstop=2" >> ~/.vimrc
RUN echo "set shiftwidth=2" >> ~/.vimrc
RUN echo "set softtabstop=2" >> ~/.vimrc
RUN echo "set expandtab" >> ~/.vimrc

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

COPY start.sh .start

# start image with docker run -it -p 8080:8080 dev /root/.start
