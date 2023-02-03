#!/bin/bash

error()
{
	echo $1 >&2
	exit $2
}

[ $# -ne 2 ] && error "Debe indicar 2 parámetros -> Fichero1 y Fichero2" 1
[ ! -f $1 ] && error "El parámetro 1 no es un fichero o no existe" 2
[ ! -f $2 ] && error "El parámetro 2 no es un fichero o no existe" 3

exec 3<$1
exec 4<$2

while true
do
	read -u3 linea1
	read -u4 linea2

	[ -n "$linea1" ] && echo $linea1
	[ -n "$linea2" ] && echo $linea2
	[ -z "$linea1" ] && [ -z "$linea2" ] && break
done

exit 0