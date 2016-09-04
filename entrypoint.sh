#!/usr/bin/env bash

TIMEOUT=30

POSTGRES_DB_HOST=${POSTGRES_DB_HOST:-$POSTGRES_PORT_5432_TCP_ADDR}
POSTGRES_DB_PORT=${POSTGRES_DB_PORT:-$POSTGRES_PORT_5432_TCP_PORT}
POSTGRES_DB_PORT=${POSTGRES_DB_PORT:-5432}
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
echo "ncat $POSTGRES_DB_HOST $POSTGRES_DB_PORT"
if ncat $POSTGRES_DB_HOST $POSTGRES_DB_PORT -w $TIMEOUT --send-only < /dev/null > /dev/null 2>&1 ; then
   echo Postgres running;
else

   echo "ncat $POSTGRES_DB_HOST $POSTGRES_DB_PORT -w $TIMEOUT --send-only < /dev/null "
   ncat $POSTGRES_DB_HOST $POSTGRES_DB_PORT -w $TIMEOUT --send-only < /dev/null 
   echo $?	
   echo Required service Postgres not running. Have you started the required services?
   sleep 360
   exit 1
fi

# Create DSpace administrator
dspace create-administrator -e ${ADMIN_EMAIL:-devops@1science.com} -f ${ADMIN_FIRSTNAME:-DSpace} -l ${ADMIN_LASTNAME:-Admin} -p ${ADMIN_PASSWD:-admin123} -c ${ADMIN_LANGUAGE:-en}

# Start Tomcat
exec catalina.sh run
