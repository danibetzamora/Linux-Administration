#!/bin/bash	

error()
{
	echo $1 >&2
	exit $2
}

# Directorio en el que se almacenarán las copias de seguridad
dir="/backups"

# Da error si el directorio /backups si no existe
[ ! -d $dir ] && error "No existe la carpeta de backups" 1

# Si el fichero testigo-nivel0 no existe, no existe ninguna copia de nivel 0 y da error
[ ! -f "$dir/testigo-nivel0" ] && error "No existe ninguna copia de nivel 0" 2

# Formato del nombre de la copia de seguridad de nivel 1 -> 2022-11-27-copia-nivel1.tgz
backup_name="$(date +%Y-%m-%d)-copia-nivel1"

# Creación de fichero testigo, en base al cual se harán las copias de nivel 2
touch $dir/testigo-nivel1

# Creación de la copia de seguridad de nivel 1 de aquellos archivos que sean más recientes
# que el fichero testigo-nivel0 (Ficheros no existentes en la copia de nivel 0)
find /home ! -user root -newer "$dir/testigo-nivel0" | \
				  tar zcf "$dir/$backup_name.tgz" -T - \
				  2> "$dir/$backup_name-errores.txt" \
				  --no-recursion

exit 0