#!/bin/bash

export IS_DOTFILES_INSTALL="true"

read -p "Selecciona el sistema operativo: " system

if [[ "$system" != "macOS" && "$system" != "linux" ]]
then
    echo "El sistema operativo $system no esta soportado"
    echo "Los sistemas operativos soportados son:"
    echo " > macOS"
    echo " > linux"
    exit 1
fi


so_install_script="install-${system,,}.sh"
dotfiles_directory="$HOME/dotfiles"

if [[ ! -d "$dotfiles_directory" ]]
then
    echo "No se encuentra el directorio de los dotfiles en $dotfiles_directory."
    exit 1
fi

home_dotfiles_backups="$dotfiles_directory/backups"

echo "La ruta de los dotfiles se ha configurado en $dotfiles_directory"

bashrc_file="$HOME/.bashrc"

if [[ -f "$HOME/.zshrc" ]]
then
    bashrc_file="$HOME/.zshrc"
fi

if [[ ! -d "$home_dotfiles_backups" ]]
then
    mkdir ${home_dotfiles_backups}
fi

bash_rc_file_backup=$home_dotfiles_backups/$(basename $bashrc_file)

if [[ ! -f "$bash_rc_file_backup" ]]
then
  echo "Creando copia de seguridad de $bashrc_file en $bash_rc_file_backup"
  cp ${bashrc_file} ${bash_rc_file_backup}
fi

echo "" > ${bashrc_file} # empty rc file
echo "export DOTFILES_STARTUP_SCRIPT=$bashrc_file" >> ${bashrc_file}
echo "export DOTFILES_ROOT_DIRECTORY=$dotfiles_directory" >> ${bashrc_file}
echo "export DOTFILES_DIRECTORY=$dotfiles_directory/$system" >> ${bashrc_file}
echo 'source ${DOTFILES_ROOT_DIRECTORY}/shell.sh' >> ${bashrc_file}
echo 'source ${DOTFILES_ROOT_DIRECTORY}/init.sh' >> ${bashrc_file}

export DOTFILES_STARTUP_SCRIPT="$bashrc_file"
export DOTFILES_ROOT_DIRECTORY="$dotfiles_directory"
export DOTFILES_DIRECTORY="$dotfiles_directory/$system"
source ${DOTFILES_ROOT_DIRECTORY}/init.sh

# Operating system specific install
if [[ -f $so_install_script ]]
then
    $so_install_script
fi

which python3

if [[ $? -gt 0 ]]
then
  echo "Se necesita Python 3.9 o mayor para continuar"
fi

pip3 install -r ${DOTFILES_ROOT_DIRECTORY}/share/scripts/requirements.txt
python3 ${DOTFILES_ROOT_DIRECTORY}/share/scripts/symlinks.py

if [[ $? -gt 0 ]]
then
    echo "No se ha podido crear los enlaces simbolicos debido a un error!"
    exit 1
fi

export IS_DOTFILES_INSTALL="false"

echo "Para aplicar los cambios reinicia la terminal"
