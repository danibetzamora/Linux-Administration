#!/bin/bash

error() 
{
	echo $1 >&2
	exit $2
}

[ $# -ne 0 ] && error "No se ha de pasar ningún parámetro" 1

shells_usuarios=$(mktemp)
shells_existentes=$(mktemp)

cut -d: -f7 /etc/passwd > $shells_usuarios
cat /etc/shells > $shells_existentes

exec 3<$shells_usuarios
exec 4<$shells_existentes

control=0

while read -u3 linea1
do
	while read -u4 linea2
	do
		[[ $linea1 == $linea2 ]] && control=1
	done

	[ $control -eq 0 ] && echo "El shell \"$linea1\" no se encuentra en el fichero /etc/shells" 
	control=0
	exec 4<$shells_existentes
done

rm $shells_usuarios $shells_existentes

exit 0