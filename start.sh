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

set -e
die () {
    echo >&2 "$@"
    exit 1
}

ENVIRONMENTS="atari|dmlab|football|mujoco|crawler"
AGENTS="r2d2|vtrace|sac|ppo"
HOST_ADDRESS_PORT="192.93.8.119:8686"
HOST_LOGDIR="/cs-share/pradalier/dream_user/seed_rl/tensorboard_logs"
[ "$#" -ne 0 ] || die "Usage: nodes.sh [$ENVIRONMENTS] [$AGENTS] [Num. actors]"
echo $1 | grep -E -q $ENVIRONMENTS || die "Supported games: $ENVIRONMENTS"
echo $2 | grep -E -q $AGENTS || die "Supported agents: $AGENTS"
echo $3 | grep -E -q "^((0|([1-9][0-9]*))|(0x[0-9a-fA-F]+))$" || die "Number of actors should be a non-negative integer without leading zeros"
export ENVIRONMENT=$1
export AGENT=$2
export NUM_ACTORS=$3
shift 3
if [[ $1 ]]; then
  echo $1 | grep -E -q "^((0|([1-9][0-9]*))|(0x[0-9a-fA-F]+))$" || die "Number of environments per actor should be a non-negative integer without leading zeros"
  export ENV_BATCH_SIZE=$1
  shift 1
else
  export ENV_BATCH_SIZE=1
fi

tmux new-session -d -t seed_rl
mkdir -p /tmp/seed_rl
cat >/tmp/seed_rl/instructions <<EOF
Welcome to the SEED local training of ${ENVIRONMENT} with ${AGENT}.
SEED uses tmux for easy navigation between different tasks involved
in the training process. To switch to a specific task, press CTRL+b, [tab id].
You can stop training at any time by executing 'stop_seed'
EOF
tmux send-keys "alias stop_seed='./scripts/stop.sh seed_rl'" ENTER
tmux send-keys clear
tmux send-keys KPEnter
tmux send-keys "cat /tmp/seed_rl/instructions"
tmux send-keys KPEnter
tmux send-keys "python3 check_gpu.py 2> /dev/null"
tmux send-keys KPEnter
tmux send-keys "stop_seed"
tmux new-window -d -n learner

COMMAND='scripts/run.sh '"$ENVIRONMENT"' '"$AGENT"' '"$NUM_ACTORS"' '"$ENV_BATCH_SIZE"' '"$HOST_ADDRESS_PORT"' learner learner '"$HOST_LOGDIR"''
tmux send-keys -t learner "$COMMAND" ENTER

id=0
while IFS="," read -r pc_name ip_address status
do
  if [[ ${id} = $NUM_ACTORS ]];then
    break
  fi
  if [[ $status = "disabled" ]];then
    continue
  fi
  tmux new-window -d -n "actor_${id}"
  COMMAND='ssh -t dream_user@'"$pc_name"' /cs-share/pradalier/dream_user/seed_rl/seed_rl/scripts/run.sh '"$ENVIRONMENT"' '"$AGENT"' '"$NUM_ACTORS"' '"$ENV_BATCH_SIZE"' '"$HOST_ADDRESS_PORT"' '"${id}"' actor '"$HOST_LOGDIR"''
  tmux send-keys -t "actor_${id}" "$COMMAND" ENTER
  let id=$id+1
done < <(tail -n +2 ./scripts/actor_pcs.csv)

if [[ ${id} != $NUM_ACTORS ]];then
  echo "not enough machines available, found $id machines but we wanted $NUM_ACTORS actors"
  ./scripts/stop.sh seed_rl
else
  tmux attach -t seed_rl
fi