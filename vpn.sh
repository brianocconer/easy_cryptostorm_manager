#!/bin/bash

yellowColour='\e[1;33m'
grayColour='\e[0;37m'
purpleColour='\e[0;35m'
redColour='\e[0;31m'
endColour='\e[0m'

# Función para manejar Ctrl+C
function ctrl_c(){
    echo -e "\n\n${redColour}[!] Saliendo....\n${endColour}"
    exit 1
}

# Capturar Ctrl+C
trap ctrl_c INT


function helpPanel(){
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:\n${endColour}"
    echo -e "\t${purpleColour}p)${endColour} ${grayColour}Pais al que desea conectarse${endColour}"
    echo -e "\t${purpleColour}l)${endColour} ${grayColour}Listar los paises disponibles${endColour}"
    echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}\n"
}


function listCountry(){
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} Lista de paises disponibles:\n${endColour}"
	 ls /etc/openvpn/client | awk -F'_' '{print $1}' | sort | uniq | column
}


function setCountry(){
    country="$1"
    declare -a countries=()
    countries=($(ls /etc/openvpn/client | awk -F'_' '{print $1}' | column))
    
    if [[ " ${countries[@]} " =~ " ${country} " ]]; then

	echo -e "\n${yellowColour}Protocolos${endColour}"
    	echo -e "\t${purpleColour}U)${endColour} ${grayColour}protocolo UDP${endColour}"
   	echo -e "\t${purpleColour}T)${endColour} ${grayColour}protocolo TCP${endColour}"
    	echo -e -n "${yellowColour}Opcion:${endColour}"
    	read protocolo

    	if [ "$protocolo" == "U" ]; then 
        	sudo openvpn --config /etc/openvpn/client/"$country"_UDP.ovpn
    	elif [ "$protocolo" == "T" ]; then 
        	sudo openvpn --config /etc/openvpn/client/"$country"_TCP.ovpn
    	else
        	echo -e "\n${redColour}[!] El protocolo seleccionado no es correcto, por favor ingrese 'U' o 'T'${endColour}"
        	setCountry $country
    	fi
    else
	echo -e "\n${redColour}[!] El pais ingresado no esta disponible${endColour}"
        exit 1
    fi
}

# indicadores
declare -i parameter_counter=0

# leer opciones
while getopts "p:lh" arg; do 
    case $arg in 
        p) country="$OPTARG"; let parameter_counter+=1;;
	l) let parameter_counter+=2;;
        h) helpPanel;;
    esac 
done

# validación de parámetros
if [ $parameter_counter -eq 1 ]; then
    setCountry $country
elif [ $parameter_counter -eq 2 ]; then
    listCountry
else
    helpPanel
fi

