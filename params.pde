// PROGRAM PARAMETERS

/**
 * How much food a colony needs to make a new ant
 */
float foodForBaby = 2.5;

/**
 * How many ants a colony starts with
 */
int startingAnts = 12;

/**
 * How many frames a generation lasts for
 */
int generationLength = 3600;

/**
 * How many iterations a pheromone lasts for
 */
int pheromoneLength = 75;

/**
 * If true, ants will wrap around to the opposite side when hitting the edge. If false, they will just not move in that direction
 */
boolean wrapAround = false;

/**
 * Percent of initially connected neurons (excluding bias neuron)
 */
float initConnectionsChance = 1;

// Food generation
/**
 * The minimum value the noise function needs to return to consider a tile to have food in it
 */
float foodCutoff = 0.45;

/**
 * "step" of each tile in the Perlin function for food generation
 */
float noiseCoefficient = 0.05;


// Neural network parameters
/**
 * Number of colonies every generation
 */
int populationSize = 25;

/**
 * The target number of species
 */
int numSpecies = 5;

/**
 * Likelihoods of different mutation types
 */
float weightChance = 0.8;
float connectionChance = 0.05;
float neuronChance = 0.03;

/**
 * Parameters for determining how each type of difference in networks will affect its difference score for speciation
 */
float disjointCoefficient = 2;
float excessCoefficient = 2;
float weightDifferenceCoefficient = 1;

/**
 * How large the difference score needs to be to consider a network a different species
 */
float compatibilityThreshold = 6;

/**
 * How much the compatibility threshold will change every generation to try to hit the target number of species
 */
float compatibilityModifier = 0.3;

/**
 * For how many generations a species can remain stagnant before we destroy it
 */
float dropoffAge = 15;

/**
 * The amount of each species that continue to the next generation
 */
float generationPercent = 0.2;

/**
 * The maximum and minimum (negative of this number) that weights can be
 */
float weightLimit = 1;