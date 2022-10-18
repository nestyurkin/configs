#!/bin/bash

lsb_dist=""
if [ -r /etc/os-release ]; then
	lsb_dist="$(. /etc/os-release && echo "$ID")"
    ver_id="$(. /etc/os-release && echo "$VERSION_ID")"
fi
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
case "$lsb_dist" in
    ubuntu|debian|raspbian)
        sudo apt install -y zsh git
    ;;
    centos|rhel|sles|almalinux)
        sudo yum install -y git
        if [[ $ver_id == "7" ]]; then
            if [ -f "/usr/bin/zsh" ]; then 
                if [ ! "$(zsh -c '[[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || echo oldzsh')" ]; then 
                    echo "ZSH >=5.1"
                else 
                    echo Installing ZSH 5.1 from RPM
                    sudo yum remove -y zsh
                    sudo rpm -i http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/zsh-5.1-1.gf.el7.x86_64.rpm
                fi
            else 
                echo Installing ZSH 5.1 from RPM
                sudo rpm -i http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/zsh-5.1-1.gf.el7.x86_64.rpm
            fi
        else 
            sudo yum install -y zsh
        fi
    ;;
    *)
        echo Unknown distro
        exit
    ;;
esac

if [ ! -f "/usr/local/bin/pygmentize" ]; then 
    echo Try Install Pygments
    sudo pip install Pygments
fi

if [ ! -f "/usr/local/bin/pygmentize" ]; then 
    if [ ! -f "/usr/local/bin/chroma" ]; then 
        echo Installing Chroma
        tmp=$(mktemp -d)
        curl -fsSL -o $tmp/chroma.tar.gz https://github.com/alecthomas/chroma/releases/download/v2.3.0/chroma-2.3.0-linux-amd64.tar.gz
        tar -xf $tmp/chroma.tar.gz -C $tmp
        sudo cp $tmp/chroma /usr/local/bin/
    fi
fi

touch ~/.zshrc
isldap=$(cat /etc/passwd | grep $USER)
if [ -n "$isldap" ]; then
    sudo usermod --shell /bin/zsh "$USER"
else
    echo Fix .bashrc with LDAP 
    curl -fsSL -o ~/.bashrc https://raw.githubusercontent.com/nestyurkin/configs/main/.bashrc
fi

#cleanup
echo Remove old configs
rm ~/.p10k.zsh ~/.zshrc
rm -rf ~/.oh-my-zsh/
#install plugins & theme
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone -q https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
#install configs
if [ ! "$(zsh -c '[[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || echo oldzsh')" ]; then 
    echo "ZSH >=5.1, installing powerlevel10k"
    git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    curl -fsSL -o ~/.p10k.zsh https://raw.githubusercontent.com/nestyurkin/configs/main/.p10k.comp.zsh
    curl -fsSL -o ~/.zshrc https://raw.githubusercontent.com/nestyurkin/configs/main/.zshrc
else 
    echo "ZSH < 5.1 to old, fallback to dafault theme"
    curl -fsSL -o ~/.zshrc https://raw.githubusercontent.com/nestyurkin/configs/main/.zshrc_old
fi
#fix group perms
chmod g-w -R ~/.oh-my-zsh

zsh
