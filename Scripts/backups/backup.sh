#!/bin/bash

# Las copias de nivel 0 copian todo, y las de nivel 1 solo lo nuevo

error()
{
	echo $1 >&2
	exit $2
}

[ $# -ne 2 ] && error "Uso: $0 [0|1] directorio" 1 
[[ ! $1 =~ [0-1] ]] && error "Niveles aceptados: 0 y 1" 2

dir="./BACKUP"
[ ! -d $dir ] && mkdir $dir

sufijo="_nivel$1_$(date +%Y%m%d_%H%M)"

if [ $1 -eq 0 ]
then
	touch $dir/testigo_nivel0

# -print0 imprime un caracter nulo despues de cada búsqueda
# -T- indica que los ficheros vienen de una lista dada por el canal de entrada (pipe)
# --null indica que la lista viene separada por caracter nulo
find $2 -print0 | tar zcvf "$dir/backup$sufijo.tgz" -T- \
				  > "$dir/catalogo$sufijo.txt" \
				  2> "$dir/error$sufijo.txt" \
				  --null --no-recursion
else
	if [[ ! -f "$dir/testigo_nivel0" ]]
	then
		.backup.sh 0 $2
	else
	find $2 -newer "$dir/testigo_nivel0" -print0 | \
				  tar zcvf "$dir/backup$sufijo.tgz" -T- \
				  > "$dir/catalogo$sufijo.txt" \
				  2> "$dir/error$sufijo.txt" \
				  --null --no-recursion
	fi
fi

exit 0

# tar tf BACKUP/backup_nivel0_20221115_1152.tgz -> Para ver lo que hay dentro del tgz