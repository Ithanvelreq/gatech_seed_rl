set -e
die () {
    echo >&2 "$@"
    exit 1
}
export ENVIRONMENT=$1
export AGENT=$2
export NUM_ACTORS=$3
export ENV_BATCH_SIZE=$4
export HOST_ADDRESS_PORT=$5
export ID=$6
export MODE=$7
export HOST_LOGDIR=$8
shift 8
cd /home/GTL/ivelarde/repos/seed_rl
export CONFIG=$ENVIRONMENT
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR
../docker/build.sh
docker_version=$(docker version --format '{{.Server.Version}}')
if [[ $MODE = "learner" ]]; then
    NAME="seed_learner"
else
    NAME="seed_actor_$ID"
fi

docker run --entrypoint ./docker/my_run.sh -ti -it -v $HOST_LOGDIR:/tmp/agent \
 -p 8686:8686 --network=host -e HOST_PERMS=$HOSTPERMS -e DISPLAY=$DISPLAY --name $NAME \
 -v $HOME/.Xauthority:/root/.Xauthority:rw -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
 --rm seed_rl:$ENVIRONMENT $ENVIRONMENT $AGENT $NUM_ACTORS $ENV_BATCH_SIZE $HOST_ADDRESS_PORT $ID $MODE /tmp/agent $@

