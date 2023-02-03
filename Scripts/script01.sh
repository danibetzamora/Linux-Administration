#!/bin/bash

#Uso -> ./nombre.sh -par/-impar fichero1 fichero2 fichero3 ...

error()
{
	echo $1 >&2
	exit $2
}

control=0
lineaElegida=1

[ $# -le 1 ] && error "Debe indicar al menos dos parámetros: $0 -[par/impar] [fichero1]..." 1

[[ $1 == "-par" ]] || [[ $1 == "-impar" ]] || error "El primer parámetro debe ser \"-par\" o \"-impar\"" 2

for fichero in $@
do

	[ $control -eq 0 ] && control=1 && continue

	[ ! -f $fichero ] && echo -e "\nNo existe el fichero \"$fichero\"\n" >&2 && continue

	echo -e "\nFICHERO: $fichero\n"

	while read linea
	do
		case $1 in
			-par)
				[[ $lineaElegida%2 -eq 0 ]] && echo "$linea"
				let lineaElegida+=1
			;;

			-impar)
				[[ $lineaElegida%2 -ne 0 ]] && echo "$linea"
				let lineaElegida+=1
			;;
		esac
	done <"$fichero"

	lineaElegida=1
	echo -e "\n"

done

exit 0




	




		
