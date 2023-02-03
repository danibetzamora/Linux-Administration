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

find $directorio -type f \( -iname '*.doc' -o -iname '*.docx' \) > $fichero 2>/dev/null

exec 3<$fichero

while read -u3 linea
do
	nombre_fichero=$(basename $linea)
	directorio_completo=$(readlink -e $linea)
	directorio_completo_sin_fichero=${directorio_completo%/*}
	nombre_fichero_lowercase=$(echo $nombre_fichero | tr '[:upper:]' '[:lower:]')

	mv $directorio_completo $directorio_completo_sin_fichero/$nombre_fichero_lowercase 2>/dev/null

	date=$(date --rfc-3339=seconds)

	[[ $nombre_fichero != $nombre_fichero_lowercase ]] && echo -e "$date\t$directorio_completo\t$nombre_fichero_lowercase" >> /var/log/cambiosDoc
done

rm $fichero

exit 0