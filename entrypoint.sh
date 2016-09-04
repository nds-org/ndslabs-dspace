#!/usr/bin/env bash

TIMEOUT=60

POSTGRES_DB_HOST=${POSTGRES_DB_HOST:-$POSTGRES_PORT_5432_TCP_ADDR}
POSTGRES_DB_PORT=${POSTGRES_DB_PORT:-$POSTGRES_PORT_5432_TCP_PORT}
POSTGRES_USER=${POSTGRES_USER:-dspace}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-dspace}
POSTGRES_SCHEMA=${POSTGRES_SCHEMA:-dspace}


DSPACE_CFG=/dspace/config/dspace.cfg
# Configure database in dspace.cfg
sed -i "s#db.url = jdbc:postgresql://localhost:5432/dspace#db.url = jdbc:postgresql://${POSTGRES_DB_HOST}:${POSTGRES_DB_PORT}/${POSTGRES_SCHEMA}#" ${DSPACE_CFG}
sed -i "s#db.username = dspace#db.username = ${POSTGRES_USER}#" ${DSPACE_CFG}
sed -i "s#db.password = dspace#db.password = ${POSTGRES_PASSWORD}#" ${DSPACE_CFG}
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
		 i=$((i+5))
	     sleep 5
       else 
         echo Required service Postgres not running. Have you started the required services?
         exit 1
	   fi
    fi
done

dspace create-administrator -e ${ADMIN_EMAIL} -f DSpace -l Admin -p ${ADMIN_PASSWD} -c en

exec catalina.sh run
