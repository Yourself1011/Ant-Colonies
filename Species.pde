int globalSpeciesId = 0;
class Species {
    Colony bestColony;
    float bestScore, totalFitness;
    List<Colony> colonies = new ArrayList<Colony>();
    color baseCol;
    int id, stagnantGenerations;

    Species(Colony baseColony) {
        bestColony = baseColony;
        colonies.add(baseColony);
        baseColony.species = this;
        baseCol = (int) random(16777216);
        
        id = globalSpeciesId;
        globalSpeciesId++;
    }

    boolean compare(Colony colony) {
        NetworkDifference difference = bestColony.network.compare(colony.network);
        return difference.disjoint.size() * disjointCoefficient + difference.excess.size() * excessCoefficient + difference.avgWeightDiff * weightDifferenceCoefficient < compatibilityThreshold;
    }

    void performNaturalSelection() {
        int surviveIndex = floor(colonies.size() * generationPercent);

        Collections.sort(colonies, Comparator.comparing((Colony c) -> c.fitness).reversed());

        float highScore = colonies.get(0).fitness;

        if (highScore > bestScore) {
            bestColony = colonies.get(0);
            bestScore = highScore;
            stagnantGenerations = 0;
        } else {
            stagnantGenerations++;
        }

        if (highScore * colonies.size() > population.topScore) {
            population.topScore = highScore * colonies.size(); // to undo fitness sharing
            population.topScoreGeneration = generationCount;
        }
        if (highScore * colonies.size() > population.generationTopScore) {
            population.generationTopScore = highScore * colonies.size();// to undo fitness sharing
        }

        colonies = colonies.subList(0, surviveIndex);
    }

    Colony weightedRandomColony() {
        float rand = random(totalFitness);
        for (Colony colony : colonies) {
            rand -= colony.fitness;

            if (rand <= 0) {
                return colony;
            }
        }

        return colonies.get(colonies.size() - 1);
    }

    void fitnessSharing() {
        for (Colony colony : colonies) {
            colony.fitness /= colonies.size();
            totalFitness += colony.fitness;
        }
    }
}
