#!/bin/bash
# Copyright 2019 The SEED Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


die () {
    echo >&2 "$@"
    exit 1
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

ENVIRONMENT=$1
AGENT=$2
NUM_ACTORS=$3
ENV_BATCH_SIZE=$4
LEARNER=$5
SERVER_ADDRESS=$6
shift 6

export PYTHONPATH=$PYTHONPATH:/

ACTOR_BINARY="python3 ../${ENVIRONMENT}/${AGENT}_main.py --run_mode=actor";
LEARNER_BINARY="python3 ../${ENVIRONMENT}/${AGENT}_main.py --run_mode=learner";
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
NUM_ENVS=$(($NUM_ACTORS*$ENV_BATCH_SIZE))


mkdir -p /tmp/seed_rl
rm /tmp/agent -Rf
if [[ "1" = ${LEARNER} ]]; then
    COMMAND=''"${LEARNER_BINARY}"' --logtostderr --pdb_post_mortem '"$@"' --num_envs='"${NUM_ENVS}"' --env_batch_size='"${ENV_BATCH_SIZE}"''
else
    COMMAND=''"${ACTOR_BINARY}"' --logtostderr --pdb_post_mortem '"$@"' --num_envs='"${NUM_ENVS}"' --task=0 --env_batch_size='"${ENV_BATCH_SIZE} --server_address='"${SERVER_ADDRESS}"'"''
fi
echo $COMMAND
exec $COMMAND
