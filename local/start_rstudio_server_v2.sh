#!/bin/bash

##############################################
# USAGE: ./start_rstudio_server <PORT>
#   e.g. ./start_rstudio_server 8787
##############################################

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
USER=$(whoami)
# set a user-specific secure cookie key
COOKIE_KEY_PATH=/tmp/rstudio-server/${USER}_secure-cookie-key
rm -f $COOKIE_KEY_PATH
mkdir -p $(dirname $COOKIE_KEY_PATH)
mkdir -p ${RSTUDIO_RUN_ROOT}/rstudio-server
mkdir -p ${RSTUDIO_RUN_ROOT}/database


cat << EOF  > ${RSTUDIO_CONFIG_ROOT}/rserver.conf
server-pid-file=${RSTUDIO_RUN_ROOT}/rstudio-server.pid
server-data-dir=${RSTUDIO_RUN_ROOT}/rstudio-server/
rsession-path=${RSTUDIO_CONFIG_ROOT}/rsession.sh
EOF

cat << EOF > ${RSTUDIO_CONFIG_ROOT}/database.conf
provider=sqlite
directory=${RSTUDIO_RUN_ROOT}/database
EOF

RSERVER_BIN=${RSTUDIO_SERVER_ROOT}/bin/rserver

# Rserver >= version 1.3 requires the --auth-revocation-list-dir parameter
if [ $(sed -n '/^1.3./p;q' $RSTUDIO_SERVER_ROOT/VERSION) ] ;
then
  REVOCATION_LIST_DIR=/tmp/rstudio-server/${USER}_revocation-list-dir
  mkdir -p $REVOCATION_LIST_DIR
  REVOCATION_LIST_PAR="--auth-revocation-list-dir=$REVOCATION_LIST_DIR"
else
  REVOCATION_LIST_PAR=""
fi

python -c 'import uuid; print(uuid.uuid4())' > $COOKIE_KEY_PATH
chmod 600 $COOKIE_KEY_PATH

# store the currently activated conda environment in a file to be read by rsession.sh
CONDA_ENV_PATH=/tmp/rstudio-server/${USER}_current_env
rm -f $CONDA_ENV_PATH
echo "## Current env is >>"
echo $CONDA_PREFIX
echo $CONDA_PREFIX > $CONDA_ENV_PATH

export RETICULATE_PYTHON=$CONDA_PREFIX/bin/python

export XDG_DATA_HOME=${PATH_TO_RUN_DIR}/.local/share
export XDG_STATE_HOME=${PATH_TO_RUN_DIR}/.local/state


$RSERVER_BIN --server-daemonize=0 \
  --www-port=$1 \
  --config-file=${RSTUDIO_CONFIG_ROOT}/rserver.conf \
  --secure-cookie-key-file=$COOKIE_KEY_PATH \
  --rsession-which-r=$(which R) \
  --rsession-ld-library-path=$CONDA_PREFIX/lib \
  --rsession-path=${RSTUDIO_CONFIG_ROOT}/rsession.sh \
  --server-user $USER \
  --auth-none 0 \
  --auth-pam-helper-path=${RSTUDIO_CONFIG_ROOT}/rstudio_auth.sh \
  --database-config-file=${RSTUDIO_CONFIG_ROOT}/database.conf \
  $REVOCATION_LIST_PAR
