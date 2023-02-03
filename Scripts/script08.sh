#!/bin/bash

error()
{
	echo $1 >&2
	exit $2
}

[ $# -lt 2 ] && error "Debe indicar al menos 2 parámetros -> Fichero1 Fichero2 ..." 1

i=1
error=2
declare -a canales

for fichero in $@
do
	[ ! -f $fichero ] && error "El parámetro $i no es un fichero o no existe" $error
	
	exec {fd}<$fichero
	canales[$i]=$fd

	let i++
	let error++
	# let canal$i=$fd
done

i=1
contador_ficheros=0
contador_lineas_vacias=0

while true
do
	canal=${canales[$i]}
	read -u$canal linea
	let i++
	let contador_ficheros++
	[ -n "$linea" ] && echo $linea
	[ -z "$linea" ] && let contador_lineas_vacias++
	[ $contador_lineas_vacias -eq $# ] && break 
	[ $contador_ficheros -eq $# ] && contador_ficheros=0 && contador_lineas_vacias=0 && i=1
done

exit 0