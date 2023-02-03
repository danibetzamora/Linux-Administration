#!/bin/bash

error()
{
	echo $1 >&2
	exit $2
}

[ $# -ne 2 ] && error "El número de parámetros debe ser 2" 1
[[ ! $1 =~ ^[0-9]+$ ]] || [[ ! $2 =~ ^[0-9]+$ ]] && error "Cada uno de los parámetros debe ser un número" 2
[ $1 -gt $2 ] && error "El parámetro 1 debe ser menor que el parámetro 2" 3

IFS=:
fichero=/etc/passwd

exec 3<$fichero

while read -u3 usuario password uid resto
do
	if [ $uid -ge $1 ] && [ $uid -le $2 ]
	then
		echo "Usuario:$usuario, UID:$uid"
	fi
done

exit 0


