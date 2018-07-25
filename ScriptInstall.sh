#!/bin/bash

#Déclaration des variables
LogFile="/tmp/ScriptInstall.log"
vert="\033[32m"
rouge="\033[31m"
noir="\033[0m"
bleu="\033[34m"
sep="-------------------------------------------------------------------------------------------------"
SepLog=$($sep>>$LogFile)
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
echo "wget -P /tmp https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$release.noarch.rpm">>$LogFile
wget -P /tmp https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$release.noarch.rpm 2>>$LogFile 
echo "dnf localinstall /tmp/rpmfusion-free-release-$release.noarch.rpm">>$LogFile
dnf localinstall /tmp/rpmfusion-free-release-$release.noarch.rpm 2>>$LogFile
IfNoError
echo $SepLog
echo "wget -P /tmp https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$release.noarch.rpm">>$LogFile
wget -P /tmp https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$release.noarch.rpm 2>>$LogFile
echo "dnf localinstall /tmp/rpmfusion-nonfree-release-$release.noarch.rpm">>$LogFile
dnf localinstall /tmp/rpmfusion-nonfree-release-$release.noarch.rpm
IfNoError
echo $SepLog
#Mise à jour et installation des paquets
echo "dnf update -y">>$LogFile
dnf update -y 2>>$LogFile
IfNoError
echo "dnf install $packages -y">>$LogFile
dnf install $packages -y 2>>$LogFile
IfNoError
Config
exit
}

DebianInstall (){
echo "debian install"
exit
}

#Config non testé
Config (){
echo -e "Souhaitez vous lancer la Configuration de la distribution $rouge$distrib$noir (y/N) ? \c"
read confirm
[[ -z $confirm ]] && End
#Lancement de la Configuration si l'utilisateur à repondu OK 
if [[ $confirm = "y" ]]
	then 
	echo "Configuration de vim ..."
	echo "set number\nsource $VIMRUNTIME/mswin.vim\nbehave mswin\nsyntax on" >> /etc/vimrc
fi
}

IfNoError(){
echo " ">>$LogFile
[[ $? -eq 0 ]] && echo "***Pas d'erreurs !!***">>$LogFile
echo $sep>>$LogFile
}

End (){
echo $sep
echo "Fin de traitement : $(date)"|tee --append $LogFile
echo "Les erreurs d'installation ont été stockés dans le fichier : /tmp/script_install.log "
echo $sep
exit
}

########################################################################################################

#Scan des fichiers contenants distrib dans /etc afin de trouver le nom de l'OS
clear
echo $sep
#Création du fichier de logs
echo "Début de traitement : $(date)"|tee $LogFile
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
[[ -z $distrib ]] &&  echo "***Distribution inconnue***">>$LogFile && distrib="non detectée" && echo $sep && End
[[ -z $release ]] &&  echo "***Version inconnue***">>$LogFile && release="non detectée" 
#Menu d'installation
echo -e "La distribution detectée est : $rouge$distrib$noir "
echo -e "La version est $rouge$release$noir "
echo $sep
echo -e "Confirmez-vous l'installation et la Configuration de la distribution $rouge$distrib$noir (y/N) ? \c"
read confirm
[[ -z $confirm ]] && End
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
		DebianInstall
	fi
fi
End

 
