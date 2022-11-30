import crawler_gym
import gym

# Create the environment
def create_environment(headless, add_noise, add_bias, random_orient):
    env = gym.make('Crawler-v0', headless=headless, add_noise=add_noise, add_bias=add_bias, random_orient=random_orient)
    env.reset()
    return env