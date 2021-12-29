#!/bin/bash

#AUTHOR Thespartoos (Alejandro Ruiz)


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

# VARIABLES

declare -r salir=("echo -e \n\n${yellowColour}[!]${endColour} ${grayColour}Debes de ser root para poder ejecutarlo..${blueColour}\n\n")

# CTRL + C

function ctrl_c(){
	echo -e "\n\n${redColour}[!] ${endColour}${grayColour}Saliendo...${endColour}\n\n"
	exit 1
	clear
	tput cnorm;
}

function printTable(){

local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function menu(){
	if [ "$(id -u)" == "0" ]; then
		clear; echo -e "\n\n${purpleColour}[$] MENU${endColour}\n"
		for i in $(seq 1 50); do echo -ne "${purpleColour}-"; done; echo -ne "${endColour}\n"
		echo -e "\n${yellowColour}[*]${endColour} ${grayColour}Author: Thespartoos (Alejandro Ruiz)${endColour}\n\n"	
		echo -e "\t\t${yellowColour}[1]${endColour} ${blueColour}Crear de Usuarios${endColour}\n\n"
		echo -e "\t\t${yellowColour}[2]${endColour} ${blueColour}Modificar Usuarios${endColour}\n\n"
		echo -e "\t\t${yellowColour}[3]${endColour} ${blueColour}Eliminar Usuarios${endColour}\n\n"

		read -p "Escoja una opcion: " opcion
		
		if [ "$opcion" == '' ]; then
			echo -e "\n${redColour}[!]${endColour}${grayColour} Debes especificar un número válido${endColour}\n"
			menu
		
		elif [ $opcion == 1 ]; then
			opcion1

		elif [ $opcion == 2 ]; then
			opcion2

		elif [ $opcion == 3 ]; then
			opcion3
		else
			echo -e "\n${redColour}[!]${endColour}${grayColour} Debes especificar un número válido${endColour}\n"
			sleep 2; menu
		fi
	else
		$salir
	fi
}

function opcion1(){
	clear
	echo -e "\n\n${redColour}[!]${endColour} ${blueColour}Rellene los siguientes campos${endColour}\n"
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Escriba el nombre de usuario e.x (pepe)${endColour}\n" && read usuario
	
	if [ "$(cat /etc/passwd | grep "sh$" | grep "$usuario" | cut -d ':' -f 1)" == "$usuario" ]; then
		echo -e "\n${redColour}[!]${endColour}${yellowColour} El usuario ya existe${endColour}\n"
		sleep 2; opcion1

	elif [ "$usuario" == "" ]; then
		echo -e "\n${redColour}[!] Debes de especificar un nombre de usuario${endColour}\n"
		sleep 3
		opcion1
	fi

	echo -e "\n${yellowColour}[*]${endColour} ${grayColour}Escriba el nombre del directorio personal, (ex: /home/pepe):${endColour}\n" && read directorio
	if [ "$directorio" == "" ]; then
		echo -e "\n${redColour}[!] Debes de especificar un nombre de directorio${endColour}\n"
		sleep 3
		opcion1
	fi
	
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Escriba el nombre del tipo de shell a utilzar, (ex: /bin/bash)${endColour}\n" && read shell
	
	if [ "$(/bin/cat /etc/shells | grep -v '#' | grep "^$shell")" == "$shell" ]; then
		echo	
	elif [ "$shell" ==  "" ]; then
		echo -e "\n${redColour}[!] Debes de especificar un tipo de shell${endColour}\n\n"
		sleep 3
		opcion1
	else
		echo -e "\n${redColour}[!] Debes especificar un tipo de shell existente${endColour}\n"
		sleep 2; opcion1
	fi
	
	mkdir $directorio 2>/dev/null
	useradd -d $directorio -s $shell $usuario 2>/dev/null
	echo -e "${yellowColour}[+]${endColour}${grayColour} Vamos a asignarle Contraseña al usuario ($usuario)${endColour}\n"; passwd $usuario
	echo "$usuario    ALL=(ALL:ALL) ALL" >> /etc/sudoers
	sleep 3; clear
	echo -ne "\n${yellowColour}"

	sleep 2; clear
	echo -ne "\n${greenColour}[*]${endColour}${purpleColour} CONFIGURACIÓN USUARIO${endColour}\n\n"
	printTable '_' "$(echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Nuevo usuario ===========> $usuario${endColour}\n"
	echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Directorio personal =====> $directorio${endColour}\n"
	echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Tipo de shell ===========> $shell${endColour}\n\n")"
	sleep 5; menu
}

function opcion2(){
	clear
	echo -e "\n\n${redColour}[!]${endColour} ${blueColour}Rellene los siguientes campos${endColour}\n"
	echo -e "\n${purpleColour}[*]${endColour}${yellowColour} USUARIOS EN EL SISTEMA${endColour}\n"
	echo -ne "${greenColour}"
	printTable '_' "$(cat /etc/passwd | grep "sh$" | cut -d ':' -f 1)"
	echo -ne "${endColour}"
	echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Especifica el nombre de usuario a modificar\n" && read usuario

	if [ "$(cat /etc/passwd | grep "sh$" | grep "$usuario" | cut -d ':' -f 1)" != "$usuario" ]; then
		echo -e "\n${redColour}[!]${endColour} ${yellowColour}El usuario no existe${endColour}\n"
		sleep 3
		opcion2
	fi

	echo -e "\n${yellowColour}[*]${endColour}${grayColour} ¿Desea cambiar el directorio de trabajo? (s/n)${endColour}\n" && read directorio
	if [ "$directorio" == "s" ]; then
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Escriba el nuevo nombre de directorio e.x (/home/rosa)${endColour}\n" && read new_directorio
		
		if [ "$new_directorio" == "" ]; then
		echo -e "\n${redColour}[!] Debes de especificar una nombre de directorio${endColour}\n"
		sleep 3
		opcion2
		else
			mkdir $new_directorio 2>/dev/null
			usermod -d $new_directorio $usuario &> /dev/null 2>/dev/null
			echo
		fi

	elif [ "$directorio" == "n" ]; then
		echo
	else
		echo -e "\n${redColour}[!] Debes de especificar una letra correspondiente${endColour}\n"
		sleep 3
		opcion2
	fi

	echo -e "${yellowColour}[*]${endColour}${grayColour} ¿Desea cambiar la shell del usuario? (s/n)${endColour}\n" && read shell

	if [ "$shell" == "s" ]; then
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Escriba el nombre del tipo de shell a modificar, (ex: /bin/bash)${endColour}\n" && read shell_mod
		
		if [ "$(/bin/cat /etc/shells | grep -v '#' | grep "^$shell_mod")" == "$shell_mod" ]; then
			usermod -s $shell_mod $usuario &> /dev/null 2>/dev/null
			echo
		elif [ "$shell_mod" ==  "" ]; then
			echo -e "\n${redColour}[!] Debes de especificar un tipo de shell${endColour}\n\n"
			sleep 3
			opcion2
		else
			echo -e "\n${redColour}[!]${endColour}${yellowColour} Debes especificar un tipo de shell existente${endColour}\n"
			sleep 3; opcion2
		fi
	elif [ "$shell" == "n" ]; then
		echo
	else
		echo -e "\n${redColour}[!] Debes especificar una letra correspondiente${endColour}\n"
		sleep 3
		opcion2
	fi

	echo -e "${yellowColour}[*]${endColour}${grayColour} ¿Desea cambiar el UID del usuario? (s/n)${endColour}\n" && read uid

	if [ "$uid" == "s" ]; then
	
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Escriba el nuevo UID del usuario ${endColour}\n" && read UID_mod
		if [ "$UID_mod" ==  "" ]; then
			echo -e "\n${redColour}[!] Debes especificar un tipo de shell${endColour}\n\n"
			sleep 3
			opcion2
		else
			usermod -u $UID_mod $usuario 2>/dev/null
			echo
		fi
	elif [ "$uid" == "n" ]; then
		echo
	else
		echo -e "\n${redColour}[!] Debes especificar una letra correspondiente${endColour}\n"
		sleep 3
		opcion2
	fi

	echo -e "${yellowColour}[*]${endColour}${grayColour} ¿Desea cambiar el nombre del usuario? (s/n)\n${endColour}" && read user

	if [ "$user" == "s" ]; then
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Escriba el nuevo nombre de usuario${endColour}\n" && read new_user
		
		if [ "$new_user" == "" ]; then
		echo -e "\n${redColour}[!] Debes especificar un nombre de directorio${endColour}\n"
		sleep 3
		opcion2
		else
			usermod -l $new_user $usuario 2>/dev/null
			echo -e "\n"
		fi
	elif [ "$user" == "n" ]; then
		echo
	else
		echo -e "\n${redColour}[!] Debes especificar una letra correspondiente${endColour}\n"
		sleep 3
		opcion2
	fi

	sleep 2; clear
	echo -ne "\n${greenColour}[*]${endColour}${purpleColour} CONFIGURACIÓN USUARIO${endColour}\n\n"
	printTable '_' "$(echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Nuevo usuario ===========> $usuario${endColour}\n"
	echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Directorio personal =====> $directorio${endColour}\n"
	echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Tipo de shell ===========> $shell${endColour}\n\n")"
	sleep 5; menu
}

function opcion3(){
	clear
	echo -e "\n\n${redColour}[!]${endColour} ${blueColour}Rellene los siguientes campos${endColour}\n"
	echo -e "\n${purpleColour}[*]${endColour}${yellowColour} USUARIOS EN EL SISTEMA${endColour}\n"
	echo -ne "${greenColour}"
	printTable '_' "$(cat /etc/passwd | grep "sh$" | cut -d ':' -f 1)"
	echo -ne "${endColour}"

	echo -e "\n${yellowColour}[*]${endColour}${grayColour} ¿Qué usuario desea eliminar?${endColour}\n" && read del_user

	if [ "$(cat /etc/passwd | grep "^$del_user" | cut -d ':' -f 1)" == "$del_user" ]; then
		deluser $del_user &>/dev/null 2>/dev/null
		echo -e "\n${yellowColour}[*]${endColour}${blueColour} El usuario $del_user ha sido eliminado... (${endColour}${greenColour}V${endColour}${blueColour})${endColour}\n"
		sleep 2; menu
	elif [ "$del_user" == "" ]; then
		echo -e "\n${redColour}[!] Debes especificar un nombre de usuario${endColour}\n"
	else
		echo -e "\n${redColour}[!]${endColour}${yellowColour} Debes de especificar un usario existente${endColour}\n"
		sleep 2; opcion3
	fi
}

menu