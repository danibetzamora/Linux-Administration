#!/bin/bash

error()
{
	echo $1 >&2
	exit $2
}

if [ $# -eq 0 ]
then
	uid_min=$(grep -E "^UID_MIN" /etc/login.defs | sed -E 's/ +/ /' | cut -d" " -f2)
	uid_max=$(grep -E "^UID_MAX" /etc/login.defs | sed -E 's/ +/ /' | cut -d" " -f2)
else
	[ $# -ne 2 ] && error "El número de parámetros debe ser 0 (MIN y MAX por defecto), o 2 (MIN y MAX)" 1
	[[ ! $1 =~ ^[0-9]+$ ]] || [[ ! $2 =~ ^[0-9]+$ ]] && error "Cada uno de los parámetros debe ser un número" 2
	[ $1 -gt $2 ] && error "El parámetro 1 debe ser menor que el parámetro 2" 3
fi

IFS=:
fichero=/etc/passwd

exec 3<$fichero

while read -u3 usuario password uid resto
do
	case $# in
		0)
			if [ $uid -ge $uid_min ] && [ $uid -le $uid_max ]
			then
				echo "Usuario:$usuario, UID:$uid"
			fi
		;;
	
		2)
			if [ $uid -ge $1 ] && [ $uid -le $2 ]
			then
				echo "Usuario:$usuario, UID:$uid"
			fi
		;;
	esac
done

exit 0
