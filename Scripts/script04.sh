#!/bin/bash

error()
{  
	echo $1 >&2
	exit $2
}

[ $# -ne 1 ] && error "Se debe indicar 1 parámetro" 1
[[ ! $1 =~ ^[0-9]+$ ]] && error "El parámetro recibido no es un número" 2

IFS=:
fichero=/etc/passwd
contador=0
exec 3<$fichero

while read -u3 usuario resto
do
	ficheros_de_usuario=$(find / -user $usuario -type f 2>/dev/null | wc -l)
	[ $ficheros_de_usuario -ge $1 ] && echo "Usuario $usuario: $ficheros_de_usuario ficheros" && let contador+=1
	
done

echo -e "\nHay un total de $contador usuarios propietarios de $1 ficheros o más"

exit 0
