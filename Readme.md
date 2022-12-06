# Georgia Tech's SEED RL
This repository contains a customized version of Google Brain's SEED-RL. The framework has been adapted to be able to run in the facility's infrastructure. Please check-out the presentation on the presentation folder to have a better insight about the reults and metrics of the project.

Two agents are implemented:

- [R2D2 (Recurrent Experience Replay in Distributed Reinforcement Learning)](https://openreview.net/forum?id=r1lyTjAqYX)

- [Configurable On-Policy Agent](https://arxiv.org/abs/2006.05990) implementing [PPO: Proximal Policy Optimization](https://arxiv.org/abs/1707.06347)

The code is already interfaced with the following environments:

- [Crawler Gym](https://github.com/devarsi-rawal/crawler_gym) Developed by Devarsi Rawal for his MS thesis.

- [ATARI games](https://github.com/openai/atari-py/tree/master/atari_py)

However, any reinforcement learning environment using the [gym
API](https://github.com/openai/gym/blob/master/gym/core.py) can be used.

For a detailed description of the architecture please read the
[original paper](https://arxiv.org/abs/1910.06591).
Please cite the paper, the [original repository](https://github.com/google-research/seed_rl) and this repository if you use the code from this repository in your work.

### Bibtex

```
@article{espeholt2019seed,
    title={SEED RL: Scalable and Efficient Deep-RL with Accelerated Central Inference},
    author={Lasse Espeholt and Rapha{\"e}l Marinier and Piotr Stanczyk and Ke Wang and Marcin Michalski},
    year={2019},
    eprint={1910.06591},
    archivePrefix={arXiv},
    primaryClass={cs.LG}
}
@misc{velarde2022gatechseed,
    title={Georgia Tech's SEED-RL},
    author={Ithan Velarde Requena, Devarsi Rawal, Luis Wolf Batista, Cedric Pradalier},
    year={2022},
    link={https://github.com/Ithanvelreq/gatech_seed_rl}
}
```

## Pull Requests

Please feel free to open a pull request!

## Prerequisites

There are a few steps you need to take before playing with SEED. Instructions
below assume you run the Ubuntu distribution.

- Install docker by following instructions at https://docs.docker.com/install/linux/docker-ce/ubuntu/.

- Install git:

```shell
apt-get install git
```

- Clone SEED git repository:

```shell
git clone https://github.com/Ithanvelreq/gatech_seed_rl.git
cd gatech_seed_rl
```

## Local Insfrastructure training

To easily start with SEED we provide a way of running it on a local
machine. You just need to run one of the following commands (adjusting
`number of actors` and `number of envs. per actor/env. batch size`
to your machine):

```shell
./start.sh [Game] [Agent] [number of actors] [number of envs. per actor]
./start.sh atari r2d2 4 4
./start.sh crawler ppo 4 1
```
Currently, the number of environements per actor is not supported by the crawler environement.

It will build a Docker image using SEED source code and start the training
inside the Docker image. Note that hyper parameters are not tuned in the runs
above. Tensorboard is started as part of the training. It can be viewed under
[http://localhost:6006](http://localhost:6006) by default.


## DeepMind Lab Level Cache

By default majority of DeepMind Lab's CPU usage is generated by creating new
scenarios. This cost can be eliminated by enabling level cache. To enable it,
set the ```level_cache_dir``` flag in the ```dmlab/config.py```.
As there are many unique episodes it is a good idea to share the same cache
across multiple experiments.
For AI Platform you can add
```--level_cache_dir=gs://${BUCKET_NAME}/dmlab_cache```
to the list of parameters passed in ```gcp/submit.sh``` to the experiment.

## Additional links

SEED was used as a core infrastructure piece for the [What Matters In On-Policy Reinforcement Learning? A Large-Scale Empirical Study](https://arxiv.org/abs/2006.05990) paper.
A colab that reproduces plots from the paper can be found [here](https://github.com/google-research/seed_rl/tree/master/mujoco/what_matters_in_on_policy_rl.ipynb).