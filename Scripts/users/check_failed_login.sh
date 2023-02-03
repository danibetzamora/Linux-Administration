#!/bin/bash

error() 
{
	echo $1 >&2
	exit $2
}

# Gestión de errores
[ $# -ne 1 ] && error "¡Error! Sintaxis correcta: ./check_unsuccesful treshold" 1
[[ ! $1 =~ ^[0-9]+$ ]] && error "El parámetro \"treshold\" tiene que ser un número" 2
[ $1 -le 0 ] && error "El parámetro \"treshold\" debe ser un número mayor que 0"

# Variable que almacena el parámetro de mínimos accesos fallidos
treshold=$1

# Fichero temporal en el que se almacenan los usuarios junto con su número de accesos fallidos
failed_user_access_file=$(mktemp)

# Fichero en el que se almacenarán los resultados finales
log_file="/var/log/login_unsuccessful"

# Variables de control para indicar si el usuario tiene caducidad de cuenta y de contraseña
user_expiration_date=0
user_passwd_expiration_date=0

# Obtención UID MIN Y MAX DEL SISTEMA 
min=$(grep -E "^UID_MIN" /etc/login.defs | grep -Eo "[0-9]+$")
max=$(grep -E "^UID_MAX" /etc/login.defs | grep -Eo "[0-9]+$")

# Cabecera del fichero "login_unsuccessful" (Cada vez que se ejecuta el programa se actualiza el fichero)
echo "----------------------------------------------------------------------" > $log_file
echo "Threshold = $treshold	 " $(date "+%A, %d de %B de %Y, %T") >> $log_file
echo -e "[*] -> Indica que la cuenta tiene fecha de caducidad \n[#] -> Indica que la contraseña del usuario tiene fecha de caducidad" >> $log_file
echo -e "----------------------------------------------------------------------\n" >> $log_file

# Se extraen todos los usuarios del fichero "secure" que hayan tenido fallos de autenticación
grep "authentication failure;" /var/log/secure | tr -s " " | cut -d " " -f 15 \
											   | cut -d "=" -f2 | sort | uniq -c \
											   | tr -s " " > $failed_user_access_file

exec 3<$failed_user_access_file

# Bucle que se encarga de leer el fichero con los usarios que han tenido fallos de autenticación
while read -u3 line
do
	# Variables para el nombre del usuario y el número de fallos de acceso para ese usuario
	failures_count=$(echo $line | cut -d " " -f 1) 
	username=$(echo $line | cut -d " " -f 2)

	# Obtención de ID de usuario para el control de las cuentas de servicios
	uid=$(grep -E "^$username:" /etc/passwd | cut -d ":" -f 3)

	# Si el UID no se encuentra entre UID_MIN y UID_MAX se pasa a la siguiente iteración
	[[ $uid < $min ]] && [[ "$username" != "root" ]] && continue
	[[ $uid > $max ]] && continue

	# Si el número de fallos es mayor que el límite indicado como parámetro...
	if [ $failures_count -gt $treshold ]
	then
		# Se comprueba si la cuenta tiene caducidad y, en ese caso, se pone a 1 la variable de control
		chage -l "$username" | grep "La cuenta caduca" | grep "nunca" > /dev/null
		[ $? -eq 1 ] && user_expiration_date=1

		# Se comprueba si la contraseña tiene caducidad y, en ese caso, se pone a 1 la variable de control
		chage -l "$username" | grep "La contraseña caduca" | grep "nunca" > /dev/null
		[ $? -eq 1 ] && user_passwd_expiration_date=1

		# Dependiendo de si la cuenta y la contraseña tienen caducidad, en el fichero final se muestra un output u otro
		if [ $user_expiration_date -eq 1 ] && [ $user_passwd_expiration_date -eq 1 ]
		then
			echo "Se han detectado $failures_count accesos fallidos para el usuario \"$username\" [*] [#]" \
			>> $log_file
		elif [ $user_expiration_date -eq 1 ]
		then
			echo "Se han detectado $failures_count accesos fallidos para el usuario \"$username\" [*]" \
			>> $log_file
		elif [ $user_passwd_expiration_date -eq 1 ]
		then
			echo "Se han detectado $failures_count accesos fallidos para el usuario \"$username\" [#]" \
			>> $log_file
		else
			echo "Se han detectado $failures_count accesos fallidos para el usuario \"$username\"" \
			>> $log_file
		fi
	fi

	# Se vuelven a poner a 0 las variables de control para el próximo usuario
	user_expiration_date=0
	user_passwd_expiration_date=0
done

# Se borra el fichero temporal
rm $failed_user_access_file

echo "¡Monitorización de accesos realizada! Revise el fichero /var/log/login_unsuccessful"

exit 0