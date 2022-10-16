#!/bin/bash

lsb_dist=""
if [ -r /etc/os-release ]; then
	lsb_dist="$(. /etc/os-release && echo "$ID")"
fi
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
case "$lsb_dist" in
    ubuntu|debian|raspbian)
        sudo apt install -y zsh git
    ;;
    centos|rhel|sles|almalinux)
        sudo yum install -y zsh git
    ;;
    *)
        echo Unknown distro
        exit
    ;;
esac

sudo pip install Pygments
pygm=$(pygmentize -V|grep -i Pygments)
if [ -n "$pygm" ]; then
    echo "Found Pygments"    
else
    echo Install Chroma
    tmp=$(mktemp -d)
    curl -L -o $tmp/chroma.tar.gz https://github.com/alecthomas/chroma/releases/download/v2.3.0/chroma-2.3.0-linux-amd64.tar.gz
    tar -xf $tmp/chroma.tar.gz -C $tmp
    sudo cp $tmp/chroma /usr/local/bin/
fi

touch ~/.zshrc
isldap=$(cat /etc/passwd | grep $USER)
if [ -n "$isldap" ]; then
    sudo -k chsh -s /bin/zsh "$USER"
else
    curl -L -o ~/.bashrc https://raw.githubusercontent.com/nestyurkin/configs/main/.bashrc
fi

#cleanup
rm ~/.p10k.zsh ~/.zshrc
rm -rf ~/.oh-my-zsh/
#install plugins & theme
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
#install configs
zshv=$(zsh --version | cut -d' ' -f 2)
if [ $(echo -e "${zshv}\n5.1"|sort -V|head -1) != "${zshv}" ]; then 
    echo "ZSH >=5.1"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    curl -L -o ~/.p10k.zsh https://raw.githubusercontent.com/nestyurkin/configs/main/.p10k.comp.zsh
    curl -L -o ~/.zshrc https://raw.githubusercontent.com/nestyurkin/configs/main/.zshrc
else 
    echo "ZSH < 5.1 to old"
    curl -L -o ~/.zshrc https://raw.githubusercontent.com/nestyurkin/configs/main/.zshrc_old
fi
#fix group perms
chmod g-w -R ~/.oh-my-zsh


