#!/bin/bash

############################################################################
#									   #  
# 				MENÚ DINÀMIC 				   #
# IMPORTANT:  								   #
# Tots els menús i submenús d'opcions són Vectors.			   #
# Les opcions de menú han d'esser a l'hora, també Vectors.		   #
#	Excepció 1: excepte la darrera opció de Sortida o Menú Anterior    #
#	Excepció 2: quan es una opció per l'ejecució                       #
#									   #
############################################################################

# DEFINICIÓ DE FUNCIONS, VARIABLES I VECTORS

Principal=('Musica' 'Videos' 'WebCam' 'Sortida');

Musica=('Pop' 'Jazz' 'Rock' 'Reggeton' 'Clàsica' 'Chillout' 'Menú principal')
Pop=('Mecano' 'Radio Futura' 'Pink Floid' 'The Police' 'Menú anterior')
Jazz=('Colosseum' 'Soft Machine' 'Weather Report' 'Menú anterior')
Rock=('The Beatles' 'Queen' 'AC/DC' 'The Rolling Stones' 'Led Zeppelin' 'Menú anterior')
OpcionsMusica=('Escollir cançó' 'Escoltar Al·leatori' 'Menú anterior')

Videos=('Viatges' 'Festes' 'Receptes cuina' 'Excursions' 'Menú principal')
Viatges=('Italia' 'Londres' 'New York' 'Menú anterior')
Festes=('Nit vella' 'Cumples' 'Fi de curs' 'Aniversaris' 'Desfresses' 'Menú anterior')
OpcionsVideos=('Pantalla completa' 'Subtítols' 'Video-Wall' 'Menú anterior')

#Gestió del programa amb tres submenús, més les opcions adients al gènere escollit (Videos o Musica)
#MenuOpcio és un VECTOR
MenuOpcio[0]=0  #contendrà el nombre de l'opció escollida del Menu PRINCIPAL
MenuOpcio[1]=0	#	''			''	  del SEGON menú	
MenuOpcio[2]=0  #	''			''	  del TERCER menú

CadenaMenus="${MenuOpcio[@]}"
#"CadenaMenus" (string) contendrà en tot moment el número d'opció activa de cada un dels menús (al principi 0 0 0)
#												            | | |
#                                                  opció escollida en el menu Principal --------------------┘ | |
#						   opció escollida en el SEGON submenú  ----------------------┘ |
#						   opció escollida en el SEGON submenú  ------------------------┘

function pause()
{
  read -p "Press [Enter] key to continue..." fackEnterKey
}

function escollir()
#Mostra el contingut del directori ($Ruta) i enumera cada sortida, permetent
#a l'usuari escollir el video que vol
{
NumVideo=0	#Serà el número de la llista escollida per l'usuari
echo -e '\n'
echo '          LLISTA DE VIDEOS'
while true 
do
	local linia=0
        IFS=$'\n' 	#Combatim els espais en blanc dels noms dels arxius	
			
	for x in $(ls $Ruta*.mp4 | xargs -d '\n' -n 1 basename)		#Mostrarà els arxius del directori
	do 
 		linia=$(($linia + 1))
		if [ $linia -eq $NumVideo ]		#En la segona pasada es comprova que el num. video = linia
		then
			NomVideo=$x && return 		#S'agafa el nom de l'arxiu escollit per l'usuari
		else
			echo '            '$linia") $x"
		fi
	done
	echo -e '\n'
	read -p "      Indica el número del video: " NumVideo	#L'usuari indica el número de video que vol
done
}

function menu()
#Construéix un menú d'opcions i es crida amb dos paràmetres: Nom del menú, i el seu número de opcions
{
  Opcio=0
  MenuTriat=''
  local linia=0
  local -n NomArray=$1 

  clear
  echo 
  echo ---------- MENU $1 ---------- && echo -e '\n'

  for i in "${NomArray[@]}"			#..per cada valor del vertor
  do
     	linia=$(($linia + 1))			#Incrementa el número de opció
	if [ $2 -eq $linia ]; then echo ; fi	#Fa una linia en blanc per separar la opció de sortida del menú
	echo '           '$linia - $i		#Mostra enumerades totes les opcions del menú
	
  done

  echo -e '\n'
  read -p "      Indica una opció: " Opcio	#Opcio serà un valor numèric
 
  MenuTriat="${NomArray[$Opcio - 1]}" 		#Guarda el nom de l'opció de menú escollida
}

function opera()
{
Parametres=''
NomVideo=''
TancaVlc=''

	if [ "$SegonMenu" == "Videos" ]
	then
		TancaVlc=vlc://quit
		escollir #Mostra els videos disponibles i permet escollir-ne un
	fi

	case $Opcio in
		1)
			if [[ "$SegonMenu" == "Musica" ]]
			then
				Parametres="--intf dummy --extraintf ncurses" 		#Opció seleccionar música
			else
			
				Parametres="--fullscreen"				#Opció de Video escollit en Pantalla completa
			fi
			;;
		2)
			if [[ "$SegonMenu" == "Musica" ]]
			then
				Parametres="--intf dummy --random --play-and-exit" 	#Opció escoltar música aleatòria
			fi
			;;
		*)
			echo "Opció no vàlida"
			;;
esac
}

function InitCadena()
#actualitza el vector d'opcions de menú per permetre l'entrada al while adient.
{
    MenuOpcio[$1]=$2
    CadenaMenus="${MenuOpcio[@]}"
}

# LOGICA DE L'SCRIPT

while [ "${CadenaMenus:0:1}" -lt ${#Principal[@]} ]  		 #MENU PRINCIPAL
#Repetir mentres la opció escollida per l'usuari sigui menor que el NOMBRE TOTAL D'OPCIONS del menú Principal
do 
     Play=''
     menu Principal 4 		 		#crida la funció que crea el menú a partir del nom del verctor que conté les opcions
     InitCadena 0 $Opcio
     declare -n NumOpSegonMenu="$MenuTriat"	#${#NumOpSegonMenu[@]} conté el nombre d'opcions del segon menú 
     SegonMenu=$MenuTriat
     Ruta=$SegonMenu

     Play="Opcions$SegonMenu" 			#Valdrà OpcionsMusica o OpcionsVideos i s'empra per cridar el menú de opcions del gènere 
     declare -n NumOpMenuPlay="Opcions$SegonMenu" 

     while [ "${CadenaMenus:2:1}" -lt ${#NumOpSegonMenu[@]} ]	 #SEGON SUBMENU
     do
	menu $SegonMenu ${#NumOpSegonMenu[@]}
	InitCadena 1 $Opcio 
        if [ $Opcio -lt ${#NumOpSegonMenu[@]} ]
	then
	   	declare -n NumOpTercerMenu="$MenuTriat"
	   	TercerMenu=$MenuTriat
	   	Ruta=$SegonMenu/$TercerMenu

	   	while [ "${CadenaMenus:4:1}" -lt ${#NumOpTercerMenu[@]} ] #TERCER SUBMENU
	   	do
	      		menu $TercerMenu ${#NumOpTercerMenu[@]}
	      		InitCadena 2 $Opcio
	      		if [ $Opcio -lt ${#NumOpTercerMenu[@]} ]
	      		then 
	   	   		Ruta=$SegonMenu/$TercerMenu/$MenuTriat/ 
	
	           		menu $Play ${#NumOpMenuPlay[@]}			#OPCIONS DEL GÈNERE ESCOLLIT (Musica o Videos)
				if [ $Opcio -lt ${#NumOpMenuPlay[@]} ]		#Aquest if és per controlar si l'usuari escull "Menú anterior"
				then
	   	   			opera
					if [ "$SegonMenu" == "Musica" ]; then clear && echo "reproducció en curs..(CTRL+C per cancelar)"; fi
					vlc $Parametres "$Ruta"$NomVideo $TancaVlc 2> /dev/null    #CRIDA VLC (NomVideo és null amb Música)
				fi
	      		fi
	   	done
	   	InitCadena 2 0	#reseteja Segon Submenu
        fi
     done
     InitCadena 1 0	#reseteja Primer Submenu
done
clear
exit

	#https://gulvi.com/serie/curso-programacion-bash/capitulo/arrays-bash
	#https://askubuntu.com/questions/674333/how-to-pass-an-array-as-function-argument
	#https://unix.stackexchange.com/questions/60584/how-to-use-a-variable-as-part-of-an-array-name
    	#https://unix.stackexchange.com/questions/281390/how-to-get-the-size-of-an-indirect-array-in-bash
	#https://superuser.com/questions/31464/looping-through-ls-results-in-bash-shell-script
	#https://wiki.videolan.org/Documentation:Alternative_Interfaces/
	#https://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern
	#https://stackoverflow.com/questions/8518750/to-show-only-file-name-without-the-entire-directory-path

    	
