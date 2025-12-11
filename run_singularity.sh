#!/bin/bash

# See also https://www.rocker-project.org/use/singularity/

# Main parameters for the script with default values
PORT=${PORT:-8787}
USER=$(whoami)
PASSWORD=${PASSWORD:-notsafe}
TMPDIR=${TMPDIR:-tmp}
#CONTAINER="rstudio_latest.sif"  # path to singularity container (will be automatically downloaded)
CONTAINER="rstudio_docker.sif"
WORKDIRECTORY="${WORKDIRECTORY:-$HOME}"

if [ ! -f 'database.conf' ]; then
	printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > database.conf
fi

if [ ! -f 'rsession.conf' ]; then
	echo 'session-default-working-dir=/home/.session/\nsession-default-new-project-dir=/home/.session/' > rsession.conf
fi

# Set-up temporary paths
RSTUDIO_TMP="${TMPDIR}/$(echo -n $CONDA_PREFIX | md5sum | awk '{print $1}')"
mkdir -p $RSTUDIO_TMP/{run,var-lib-rstudio-server,local-share-rstudio,data}

R_BIN=$CONDA_PREFIX/bin/R
PY_BIN=$CONDA_PREFIX/bin/python

if [ ! -f $CONTAINER ]; then
    singularity pull docker://rocker/rstudio
	singularity build --fakeroot $CONTAINER rocker/rstudio
fi

if [ -z "$CONDA_PREFIX" ]; then
  echo "Activate a conda env or specify \$CONDA_PREFIX"
  exit 1
fi

echo "Starting rstudio service on port $PORT ..."
singularity exec \
	--bind $RSTUDIO_TMP/run:/run \
	--bind $RSTUDIO_TMP/var-lib-rstudio-server:/var/lib/rstudio-server \
	--bind /sys/fs/cgroup/:/sys/fs/cgroup/:ro \
	--bind database.conf:/etc/rstudio/database.conf \
	--bind rsession.conf:/etc/rstudio/rsession.conf \
	--bind $RSTUDIO_TMP/local-share-rstudio:/home/rstudio/.local/share/rstudio \
	--bind ${CONDA_PREFIX}:${CONDA_PREFIX} \
 	--bind $RSTUDIO_TMP/data:/home/.session \
	--bind $HOME/.config/rstudio:/home/rstudio/.config/rstudio \
        `# add additional bind mount required for your use-case` \
	--bind ${WORKDIRECTORY}:/data \
	--bind ${WORKDIRECTORY}:${WORKDIRECTORY} \
	--env CONDA_PREFIX=$CONDA_PREFIX \
	--env RSTUDIO_WHICH_R=$R_BIN \
	--env RETICULATE_PYTHON=$PY_BIN \
	--env PASSWORD=$PASSWORD \
	--env PORT=$PORT \
	--env USER=$USER \
	$CONTAINER \
	/usr/lib/rstudio-server/bin/rserver --auth-none=0 --auth-pam-helper-path=pam-helper --server-user=$(whoami) --www-address=127.0.0.1 --www-port=$PORT


