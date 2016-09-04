#!/usr/bin/env bash

TIMEOUT=60

POSTGRES_DB_HOST=${POSTGRES_DB_HOST:-$POSTGRES_PORT_5432_TCP_ADDR}
POSTGRES_DB_PORT=${POSTGRES_DB_PORT:-$POSTGRES_PORT_5432_TCP_PORT}
POSTGRES_USER=${POSTGRES_USER:-dspace}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-dspace}
POSTGRES_SCHEMA=${POSTGRES_SCHEMA:-dspace}
MAIL_SERVER=${MAIL_SERVER:-smtp.ncsa.illinois.edu}


DSPACE_CFG=/dspace/config/dspace.cfg
# Configure database in dspace.cfg
sed -i "s#db.url = jdbc:postgresql://localhost:5432/dspace#db.url = jdbc:postgresql://${POSTGRES_DB_HOST}:${POSTGRES_DB_PORT}/${POSTGRES_SCHEMA}#" ${DSPACE_CFG}
sed -i "s#db.username = dspace#db.username = ${POSTGRES_USER}#" ${DSPACE_CFG}
sed -i "s#db.password = dspace#db.password = ${POSTGRES_PASSWORD}#" ${DSPACE_CFG}
sed -i "s#smtp.example.com#${MAIL_SERVER}#" ${DSPACE_CFG}
sed -i "s#dspace-noreply@myu.edu#${ADMIN_EMAIL}#" ${DSPACE_CFG}
sed -i "s#dspace-help@myu.edu#${ADMIN_EMAIL}#" ${DSPACE_CFG}

echo "Dspace configuration changed"

echo "Connecting to Postgres on $POSTGRES_DB_HOST $POSTGRES_DB_PORT"
i=0
while true; do
    if ncat $POSTGRES_DB_HOST $POSTGRES_DB_PORT --send-only < /dev/null > /dev/null 2>&1 ; then
       echo Postgres running;
	   break
    else
       if [ "$i" -lt "$TIMEOUT" ]; then 
         echo Waiting for postgres;
		 i=$((i+10))
	     sleep 10 
       else 
         echo Required service Postgres not running. Have you started the required services?
         exit 1
	   fi
    fi
done

if [ -z "$ADMIN_EMAIL" ]; then
   echo "Admin email must be specified"
   exit 1
else
   echo "Creating admin user $ADMIN_EMAIL $ADMIN_PASSWD"
   dspace create-administrator -e ${ADMIN_EMAIL} -f DSpace -l Admin -p ${ADMIN_PASSWD} -c en
fi  

exec catalina.sh run
