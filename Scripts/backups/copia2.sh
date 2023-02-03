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

# Si el fichero testigo-nivel1 no existe, no existe ninguna copia de nivel 1 y da error
[ ! -f "$dir/testigo-nivel1" ] && error "No existe ninguna copia de nivel 1" 2

# Formato del nombre de la copia de seguridad de nivel 2 -> 2022-11-27-copia-nivel2.tgz
backup_name="$(date +%Y-%m-%d)-copia-nivel2"

# Creación de la copia de seguridad de nivel 2 de aquellos archivos que sean más recientes
# que el fichero testigo-nivel1 (Ficheros no existentes en la copia de nivel 1)
find /home ! -user root -newer "$dir/testigo-nivel1" | \
				  tar zcf "$dir/$backup_name.tgz" -T - \
				  2> "$dir/$backup_name-errores.txt" \
				  --no-recursion

exit 0