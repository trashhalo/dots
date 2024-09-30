elixir_ls:
    #!/bin/env bash
    curl -OL https://github.com/elixir-lsp/elixir-ls/releases/download/v0.21.3/elixir-ls-v0.21.3.zip
    mkdir -p ~/.elixir-ls
    unzip elixir-ls-v0.21.3.zip -d ~/.elixir-ls
    chmod +x ~/.elixir-ls/language_server.sh
    echo "export PATH=\$PATH:~/.elixir-ls" >> ~/.bashrc

lua_ls:
    #!/bin/env bash
    curl -LO https://github.com/LuaLS/lua-language-server/releases/download/3.9.1/lua-language-server-3.9.1-linux-x64.tar.gz
    mkdir -p ~/.lua-ls
    tar -xvf lua-language-server-3.9.1-linux-x64.tar.gz -C ~/.lua-ls
    chmod +x ~/.lua-ls/bin/lua-language-server
    echo "export PATH=\$PATH:~/.lua-ls/bin" >> ~/.bashrc

neovim:
    #!/bin/env bash
    sudo apt-get install -y \
        ssh \
        ripgrep \
        fzf \
        ninja-build \
        gettext \
        cmake \
        unzip \
        curl \
        build-essential
    git clone https://github.com/neovim/neovim
    pushd neovim
    git checkout stable
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    cd build
    cpack -G DEB
    sudo dpkg -i --force-overwrite  nvim-linux64.deb
    popd

tmux:
    sudo apt-get install -y tmux

config:
    #!/bin/env bash
    mkdir -p ~/.config/nvim
    ln -s {{justfile_directory()}}/config/init.lua ~/.config/nvim/init.lua
    mkdir -p ~/.config/tmux
    ln -s {{justfile_directory()}}/config/tmux.conf ~/.config/tmux/tmux.conf

install: elixir_ls lua_ls neovim tmux config

uninstall:
    rm -rf ~/.elixir-ls
    rm -rf ~/.lua-ls
    rm -rf ~/.config/nvim
    rm -rf ~/.config/tmux
    rm -rf {{justfile_directory()}}/neovim

stow:
    stow -t ~ .
