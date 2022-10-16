#!/bin/bash

lsb_dist=""
if [ -r /etc/os-release ]; then
	lsb_dist="$(. /etc/os-release && echo "$ID")"
fi
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
case "$lsb_dist" in
    ubuntu|debian|raspbian)
        sudo apt install -y zsh git python-pip
    ;;
    centos|rhel|sles|almalinux)
        sudo yum install -y zsh git python-pip
    ;;
    *)
        echo Unknown distro
        exit
    ;;
esac

sudo pip install Pygments
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
#fix group perms
chmod g-w -R ~/.oh-my-zsh
#install configs
zshv=(`echo $(zsh --version) | tr ' ' ' '`)
if [ $(echo -e "${zshv[1]}\n5.1"|sort -V|head -1) != "${zshv[1]}" ]; then 
    echo "ZSH >=5.1"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    curl -L -o ~/.p10k.zsh https://raw.githubusercontent.com/nestyurkin/configs/main/.p10k.comp.zsh
    curl -L -o ~/.zshrc https://raw.githubusercontent.com/nestyurkin/configs/main/.zshrc
else 
    echo "ZSH < 5.1 to old"
    curl -L -o ~/.zshrc https://raw.githubusercontent.com/nestyurkin/configs/main/.zshrc_old
fi



