#!/bin/bash

error()
{
	echo $1 >&2
	exit $2
}

if [[ $# -ge 2 ]]
then
	error "Se debe indicar como parámetro un único directorio o ninguno (Directorio actual)" 1
elif [[ $# -eq 0 ]]
then
	directorio=$(pwd)
else
	[ -d $1 ] && directorio=$1 || error "El directorio no existe" 2
fi

fichero=$(mktemp)

find $directorio -type f -name "*.cpp" > $fichero 2>/dev/null

exec 3<$fichero

while read -u3 linea
do
	nombre_fichero=$(basename $linea)
	nombre_fichero_sin_extension=${nombre_fichero%.*}
	linea_sin_fichero=${linea%/*}

	mv $linea $linea_sin_fichero/$nombre_fichero_sin_extension.cc
done

rm $fichero

exit 0