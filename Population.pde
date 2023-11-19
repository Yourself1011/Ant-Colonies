class Population {
    ArrayList<Colony> colonies = new ArrayList<Colony>();
    ArrayList<Colony> nextGenColonies = new ArrayList<Colony>();
    ArrayList<Species> species = new ArrayList<Species>();
    float totalAvgFitness = 0;
    int population = 0;
    float topScore, generationTopScore;
    int topScoreGeneration, noMoveTurns;
    boolean movement;

    Population() {
    }

    void frame() {
        generationElapsed++;
        for (Colony colony : colonies) {
            colony.frame();
        }

        for (Tile[] column : grid) {
            for (Tile tile : column) {
                tile.frame();
            }
        }

        if (!movement) {
            noMoveTurns++;
        } else {
            noMoveTurns = 0;
        }
        movement = false;

        if (generationElapsed >= generationLength || population == 0 || (noMoveTurns > 3 && generationElapsed > 3) ) {
            generationElapsed = 0;
            skipGeneration = false;
            generationCount++;
            generationIteration++;
            if (generationIteration >= generationSpeed) {
                generationIteration = 0;
            }
            noMoveTurns = 0;

            endGeneration();
            beginGeneration();
        }
    }

    void firstGeneration() {
        for (int i = 0; i < populationSize; i++) {
            colonies.add(new Colony());
        }

        beginGeneration();

    }

    void beginGeneration() {
        population = 0;
        speciation();
        noiseSeed(millis()); // ensures a different seed every generation

        setFood();
    }

    void endGeneration() {
        generationTopScore = 0;
        // Give some fitness for ants that have food, but haven't made it back to the hill, and for every ant that exists
        for (Colony colony : colonies) {
            for (Ant ant : colony.ants) {
                colony.fitness += ant.foodLevel * 0.01;
                colony.fitness += 0.001;
            }
        }

        grid.reset();

        totalAvgFitness = 0;
        for (Species specie : species) {
            specie.fitnessSharing();
            totalAvgFitness += specie.totalFitness;
        }

        createOffspring();

        for (int i = 0; i < species.size(); i++) {
            Species specie = species.get(i);
            
            specie.performNaturalSelection();
            nextGenColonies.addAll(0, specie.colonies);

            if (specie.colonies.isEmpty()) {
                species.remove(specie);
                i--;
            }
            for (Colony colony : specie.colonies) {
                colony.reset();
            }
        }

        colonies = (ArrayList<Colony>) nextGenColonies.clone();
        nextGenColonies.clear();
        for (Colony colony : colonies) {
            if (!colony.spawned) {
                colony.spawn();
            }
        }
        println("Generation", generationCount, "top score:", generationTopScore);
    }

    void createOffspring() {
        for (Species specie : species) {
            for (int i = 0; i < ceil((specie.totalFitness / totalAvgFitness) * populationSize - specie.colonies.size() * generationPercent); i++) {
                Species chosenSpecies = specie; 
                if (specie.stagnantGenerations > dropoffAge) {
                    chosenSpecies = weightedRandomSpecies();
                }

                if (random(1) < 0.25) {
                    // Just mutate a random colony
                    Network network = chosenSpecies.weightedRandomColony().network.copy();
                    nextGenColonies.add(new Colony(network.mutate()));
                } else if (random(1) < 0.001) {
                    // Mutate between species

                    Colony colony1 = weightedRandomColony(), colony2 = weightedRandomColony();
                    nextGenColonies.add(new Colony(colony1.network.createOffspring(colony2.network, colony1.fitness, colony2.fitness).mutate()));
                } else {
                    // Mutate within species

                    Colony colony1 = chosenSpecies.weightedRandomColony(), colony2 = chosenSpecies.weightedRandomColony();
                    nextGenColonies.add(new Colony(colony1.network.createOffspring(colony2.network, colony1.fitness, colony2.fitness).mutate()));
                }
            } 
        }
    }

    Species weightedRandomSpecies() {
        float rand = random(totalAvgFitness);
        for (int i = 0; i < species.size(); i++) {
            Species specie = species.get(i);
            rand -= specie.totalFitness;

            if (rand <= 0) {
                if (specie.stagnantGenerations > dropoffAge) {
                    i = 0;
                    rand = random(totalAvgFitness);
                } else {
                    return specie;
                }
            }
        }

        return species.get(species.size() - 1);
    }
    Colony weightedRandomColony() {
        float rand = random(totalAvgFitness);
        for (int i = 0; i < colonies.size(); i++) {
            Colony colony = colonies.get(i);
            rand -= colony.fitness;

            if (rand <= 0) {
                if (colony.species.stagnantGenerations > dropoffAge) {
                    i = 0;
                    rand = random(totalAvgFitness);
                } else {
                    return colony;
                }
            }
        }

        return colonies.get(colonies.size() - 1);
    }

    void setFood() {
        for (int x = 0; x < grid.width; x++) {
            for (int y = 0; y < grid.height; y++) {
                Tile tile = grid.get(x, y);
                if (tile.agent == null) { // no colony or ant on this tile
                    float noiseValue = noise(x * noiseCoefficient, y * noiseCoefficient);
                    for (Tile neighbor : tile.neighbors()) {
                        if (neighbor.agent instanceof Colony) noiseValue = 1; // start each colony with food surrounding it
                    }

                    // tile.pushFood(max(0, noiseValue - foodConcentration) / (1 - foodConcentration));
                    tile.pushFood(noiseValue < foodCutoff ? 0 : noiseValue);
                } 
            }
        }
    }

    void speciation() {
        for (Colony colony : colonies) {
            if (colony.species == null) {
                for (Species specie : species) {
                    if (specie.compare(colony)) {
                        colony.species = specie;
                        specie.colonies.add(colony);
                    }
                }
                if (colony.species == null) {
                    species.add(new Species(colony));
                }

                colony.chooseColor();
            }
            colony.initialPopulation();
        }

        if (species.size() > numSpecies) {
            compatibilityThreshold += compatibilityModifier;
        } else if (species.size() < numSpecies) {
            compatibilityThreshold -= compatibilityModifier;
        }
    }
}