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


SEED_RL_SESSION=$1
get_descendants ()
{
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children
  do
    get_descendants "$pid"
  done
  if (( $1 != $$ && $1 != $PPID )); then
    echo "$1 "
  fi
}

if [ ! -n "${SEED_RL_SESSION}" ]; then
  echo "SEED_RL tmux session not specified."
  echo "Running sessions:"
  tmux list-sessions -F#{session_name}
  exit 1
fi
echo "Shutting down ${SEED_RL_SESSION}!! You may see some error messages below saying that docker can't stop some containers but this is normal for now. This is not an error"
while IFS="," read -r pc_name ip_address status
do
  if [[ $status = "disabled" ]];then
    continue
  fi
  ssh -f dream_user@$pc_name docker stop $(ssh -f dream_user@$pc_name docker ps | grep seed | awk '{print $1}')
done < <(tail -n +2 ./scripts/actor_pcs.csv)
docker stop $(docker ps | grep seed | awk '{print $1}')
processes=''
for C in `tmux list-panes -t ${SEED_RL_SESSION} -s -F "#{pane_pid} #{pane_current_command}" 2> /dev/null | grep -v tmux | awk '{print $1}'`; do
  processes+=$(get_descendants $C)
done
if [[ $processes != '' ]]; then
  kill -9 $processes 2> /dev/null
  tmux kill-session -t ${SEED_RL_SESSION}
fi