#!/bin/bash

# Directorio en el que se almacenarán las copias de seguridad
dir="/backups"

# Se crea el directorio /backups si no existe
[ ! -d $dir ] && mkdir $dir

# Formato del nombre de la copia de seguridad de nivel 0 -> 2022-11-27-copia-nivel0.tgz
backup_name="$(date +%Y-%m-%d)-copia-nivel0"

# Creación de fichero testigo, en base al cual se harán las copias de nivel 1
touch $dir/testigo-nivel0

# Se crea un fichero .tgz de todos los archivos que se encuentren bajo el directorio home
# y que no pertenezcan al usuario root
find /home ! -user root | tar zcf "$dir/$backup_name.tgz" -T - \
				  2> "$dir/$backup_name-errores.txt" \
				  --no-recursion

exit 0