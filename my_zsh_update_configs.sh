#!/bin/bash
#
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/nestyurkin/configs/main/my_zsh_update_configs.sh)"
#
isldap=$(cat /etc/passwd | grep $USER)
if [ -n "$isldap" ]; then
    sudo usermod --shell /bin/zsh "$USER"
else
    echo Fix .bashrc with LDAP 
    curl -fsSL -o ~/.bashrc https://raw.githubusercontent.com/nestyurkin/configs/main/.bashrc
fi
#cleanup
echo Remove old configs
rm -f ~/.p10k.zsh ~/.zshrc
#install configs
if [ ! "$(zsh -c '[[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || echo oldzsh')" ]; then 
    echo "ZSH >=5.1, installing powerlevel10k configs"
    curl -fsSL -o ~/.p10k.zsh https://raw.githubusercontent.com/nestyurkin/configs/main/.p10k.comp.zsh
    curl -fsSL -o ~/.zshrc https://raw.githubusercontent.com/nestyurkin/configs/main/.zshrc
else 
    echo "ZSH < 5.1 to old, fallback to dafault theme"
    curl -fsSL -o ~/.zshrc https://raw.githubusercontent.com/nestyurkin/configs/main/.zshrc_old
fi


