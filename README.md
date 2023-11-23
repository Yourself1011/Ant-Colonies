# Ant Colonies

An implementation of Kenneth Stanley's NeuroEvolution of Augmenting Topologies (NEAT) that follows this paper: <https://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf>. In this implementation, ants in a colony share a network, and the entire colony is evaluated.

Results seem to occur at around 500-1000 generations

## How to run

1. Install [Processing](https://processing.org/download)
2. Clone this repo
3. Open the repo in the PDE
4. Run it

Play around with values inside of the `params.pde` file (rerun the program to apply parameter changes)

## Controls

- `Click and drag` to move
- `Click` an ant or colony to view more details
- `Scroll` to zoom
- `+` or `-` to change simulation speed
- `o` or `p` to change the number of generations skipped between rendered ones
- `n` to skip to the next generation
