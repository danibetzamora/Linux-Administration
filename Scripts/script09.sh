#!/bin/bash

error()
{
	echo $1 >&2
	exit $2
}

[ $# -ne 2 ] && error "Se deben pasar dos parámetros -> [Carpeta A] [Carpeta B]" 1
[ ! -d $1 ] && error "El parámetro 1 no es una carpeta o no existe" 2
[ ! -d $2 ] && error "El parámetro 2 no es una carpeta o no existe" 3

fichero1=$(mktemp)
fichero2=$(mktemp)
fichero3=$(mktemp)

find $1 -maxdepth 1 -type f > "$fichero1"
find $2 -maxdepth 1 -type f > "$fichero2"

read result <"$fichero1"
[ -z $result ] && error "No es posible acceder a la carpeta A o no tiene ficheros" 4

read result <"$fichero2"
[ -z $result ] && error "No es posible acceder a la carpeta B o no tiene ficheros" 5

exec 3<"$fichero1"
exec 4<"$fichero2"

while read -u3 linea
do
	nombre_fichero=$(basename $linea)
	find $2 -maxdepth 1 -type f -name "$nombre_fichero" > "$fichero3"
	read result <"$fichero3"
	[ -z $result ] && echo "Fichero único de la carpeta A: $linea"
done

echo -e "\r"

while read -u4 linea
do
	nombre_fichero=$(basename $linea)
	find $1 -maxdepth 1 -type f -name "$nombre_fichero" > "$fichero3"
	read result <"$fichero3"
	[ -z $result ] && echo "Fichero único de la carpeta B: $linea"
done

rm $fichero1 $fichero2 $fichero3

exit 0