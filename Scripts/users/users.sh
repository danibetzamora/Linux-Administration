#!/bin/bash

# Si el directorio home de los usuarios no existe se crea
[ -d /Users ] || mkdir /Users

# Si la carpeta común de los usuarios no existe se crea, y se le dan todos los permisos
# tanto al propietario como al grupo
[ -d /Users/myusers ] || mkdir /Users/myusers && chmod 770 /Users/myusers

# Se comprueba si el grupo "myusers" existe
grep ^myusers: /etc/group > /dev/null

# Si no existe el grupo "myusers" se crea
[ $? -eq 1 ] && groupadd myusers

# Se crea el usuario administrador del grupo, sin directorio home
useradd -M -g myusers -c "myusers Administrator" -s /bin/bash poweruser > /dev/null 

# Se le dan privilegios de administrador al usuario "poweruser" del grupo "myusers"
gpasswd -A poweruser myusers > /dev/null

# Se cambia el propietario de la carpeta común a "poweruser", y el grupo a "myusers"
chown poweruser:myusers /Users/myusers

iterador=1

# Iterador de 40 iteraciones para crear los 40 usuarios
while (( $iterador <= 40 )) 
do
	# Los 10 primeros usuarios se crearán con el siguiente formato -> user01
	# Se establece la caducidad de la contraseña para un mes, con 7 días de gracia y 7 días de aviso
	[ $iterador -lt 10 ] && useradd -g myusers -d /Users/user0$iterador -c "user0$iterador" -s /bin/bash user0$iterador \
						 && passwd -n 15 -x 30 -w 7 -i 7 user0$iterador > /dev/null \
						 && let iterador++ \
						 && continue
	# El resto de usuarios se crea con el formato -> user10, user11...
	useradd -g myusers -d /Users/user$iterador -c "user$iterador" -s /bin/bash user$iterador
	passwd -n 15 -x 30 -w 7 -i 7 user$iterador > /dev/null
	let iterador++
done

echo "Usuarios creados con éxito!"

exit 0