#!/bin/bash

#Déclaration des variables
log_file="/tmp/script_install.log"
vert="\033[32m"
rouge="\033[31m"
noir="\033[0m"
bleu="\033[34m"
sep="-------------------------------------------------------------------------------------------------"
packages="keepass-2* openssh-server redshift libreoffice firefox tilda clementine qbittorrent vlc mpv vim thunderbird fail2ban calibre"
ad_packages="virtualbox"

#Desaffection de la variable $distrib
unset distrib
unset release

########################################################################################################
############################################  Fonctions  ###############################################
########################################################################################################

FedoraInstall (){
#Installation des packets et inscriptions des erreurs dans un fichier log
[[ -d /tmp ]] || mkdir /tmp
#Installation des repo rpm fusion free et non-free
wget -P /tmp https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$release.noarch.rpm 
dnf localinstall /tmp/rpmfusion-free-release-$release.noarch.rpm
wget -P /tmp https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$release.noarch.rpm
dnf localinstall /tmp/rpmfusion-nonfree-release-$release.noarch.rpm
#Mise à jour et installation des paquets
echo "dnf update -y">>$log_file
dnf update -y 2>>$log_file
[[ $? -eq 0 ]] && echo "***Pas d'erreurs !!***">>$log_file 
echo $sep>>$log_file
echo "dnf install $packages -y">>$log_file
dnf install $packages -y 2>>$log_file
[[ $? -eq 0 ]] && echo "***Pas d'erreurs !!***">>$log_file 
echo $sep>>$log_file
config
exit
}

debian_install (){
echo "debian install"
exit
}

#Config non testé
config (){
echo -e "Souhaitez vous lancer la configuration de la distribution $rouge$distrib$noir (y/N) ? "
read confirm
[[ -z $confirm ]] && end
#Lancement de la configuration si l'utilisateur à repondu OK 
if [[ $confirm = "y" ]]
	then 
	echo "Configuration de vim ..."
	echo "set number\nsource $VIMRUNTIME/mswin.vim\nbehave mswin\nsyntax on" >> /etc/vimrc
fi
}

end (){
echo $sep
echo "Fin de traitement : $(date)"|tee $log_file
echo "Les erreurs d'installation ont été stockés dans le fichier : /tmp/script_install.log "
echo $sep
exit
}

########################################################################################################

#Scan des fichiers contenants distrib dans /etc afin de trouver le nom de l'OS
clear
echo $sep
#Création du fichier de logs
echo "Début de traitement : $(date)"|tee $log_file
echo $sep
echo "Detection du système d'exploitation"
echo $sep
while read distrib_file
	do
	distrib=$(grep -iwo "fedora\|ubuntu\|debian" $distrib_file | head -n 1 | tr '[A-Z]' '[a-z]')
	### echo $distrib
	[[ -n $distrib ]] && break
 	done < <(find /etc | grep .*release.*)
while read distrib_file
	do
	release=$(grep .*VERSION.* $distrib_file | grep -iwo [0-9]* | head -n 1)
	### echo $release
 	[[ -n $release ]] && break
	done < <(find /etc | grep .*release.*)
#Si $distrib non trouvée dans les fichiers
[[ -z $distrib ]] &&  echo "***Distribution inconnue***">>$log_file && distrib="non detectée" && echo $sep && end
[[ -z $release ]] &&  echo "***Version inconnue***">>$log_file && release="non detectée" 
#Menu d'installation
echo -e "La distribution detectée est : $rouge$distrib$noir "
echo -e "La version est $rouge$release$noir "
echo $sep
echo -e "Confirmez-vous l'installation et la configuration de la distribution $rouge$distrib$noir (y/N) ? \c"
read confirm
[[ -z $confirm ]] && end
#Lancement des fonctions d'installation en fonction de la variable $distrib
if [[ $confirm = "y" ]]
	then 
	echo $sep
	if [[ $distrib = fedora ]]
		then 
		FedoraInstall
	fi
	if [[ $distrib = debian\|ubuntu ]]
		then 
		debian_install
	fi
fi
end

 
