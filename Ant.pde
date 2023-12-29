class Ant extends TileAgent {
    Network network;
    Colony colony;
    float foodLevel = 0;
    boolean inHole = true, dead = false;
    int cooldown = 0;

    Ant(color col, Network network, Colony colony) {
        this.col = col;
        this.network = network;
        this.colony = colony;
        population.population++;
    }

    void think() {
        // run through the neural network
        int inputNodeIndex = 0;

        // bias node
        network.inputLayer.get(0).output = 1;
        inputNodeIndex++;

        for (Tile tile : grid.get(x, y).neighbors()) {
            float[] inputs;
            if (wrapAround) {
                inputs = new float[]{
                    tile.agent instanceof
                    Ant && ((Ant) tile.agent).colony == this.colony
                        ? 1
                        : tile.agent instanceof
                    Ant && ((Ant) tile.agent).colony != this.colony
                        ? -1
                        : 0, // if there is an ant on this tile, and whether it
                             // is from our colony, or from a different one
                    tile.agent instanceof
                    Colony && ((Colony) tile.agent) == this.colony
                        ? 1
                        : tile.agent instanceof
                    Colony && ((Colony) tile.agent) != this.colony
                        ? -1
                        : 0, // if there is a colony on this tile, and whether
                             // it is our colony, or a different one
                    tile.containsPheromone(colony, 0) ? 1
                    : tile.containsPheromone(colony, 1)
                        ? -1
                        : 0, // whether this contains pheromone type 1 or 2
                    tile.foodLevel // amount of food on this tile
                };
            } else {
                inputs = new float[]{
                    tile.agent instanceof
                    Ant && ((Ant) tile.agent).colony == this.colony
                        ? 1
                        : tile.agent instanceof
                    Ant && ((Ant) tile.agent).colony != this.colony
                        ? -1
                        : 0, // if there is an ant on this tile, and whether it
                             // is from our colony, or from a different one
                    tile.agent instanceof
                    Colony && ((Colony) tile.agent) == this.colony
                        ? 1
                        : tile.agent instanceof
                    Colony && ((Colony) tile.agent) != this.colony
                        ? -1
                        : 0, // if there is a colony on this tile, and whether
                             // it is our colony, or a different one
                    tile.containsPheromone(colony, 0) ? 1
                    : tile.containsPheromone(colony, 1)
                        ? -1
                        : 0, // whether this contains pheromone type 1 or 2
                    tile.foodLevel, // amount of food on this tile
                    tile.x == 0 || tile.x == grid.width - 1 || tile.y == 0 ||
                            tile.y == grid.height - 1
                        ? 1
                        : 0 // whether this tile is on the edge
                };
            }

            for (float input : inputs) {
                network.inputLayer.get(inputNodeIndex).output =
                    input; // set the values to the output of the input nodes
                inputNodeIndex++;
            }
        }
        network.inputLayer.get(inputNodeIndex).output =
            foodLevel; // amount of food the ant is carrying
        inputNodeIndex++;

        network.think();
        move();
    }

    void move() {
        int moveX = 0;
        int moveY = 0;

        if (network.outputLayer.get(0).output < 0.33)
            moveY++; // move up
        else if (network.outputLayer.get(0).output > 0.66)
            moveY--; // move down

        if (network.outputLayer.get(1).output < 0.33)
            moveX++; // move left
        else if (network.outputLayer.get(1).output > 0.66)
            moveX--; // move right

        if (network.outputLayer.get(2).output >= 0.5)
            dropPheromone(0);
        if (network.outputLayer.get(3).output >= 0.5)
            dropPheromone(1);

        if (selectedAgent == this) {
            selectedNetwork = network.copy(); // For displaying purposes
        }

        TileAgent moveAgent =
            move(moveX, moveY); // Try to move here. If it fails, set what is
                                // currently on the tile to moveAgent
        Tile movedTile = grid.get(x, y);

        // take food if we have capacity and the tile has food
        float foodTaken = min(1 - foodLevel, movedTile.foodLevel);
        if (foodTaken > 0) {
            movedTile.popColor();
            movedTile.popColor();
            movedTile.pushFood(movedTile.foodLevel - foodTaken);
            movedTile.pushColor(col);
            foodLevel += foodTaken;
        }

        if (moveAgent == colony) {
            enterColony(movedTile);
        } else if (moveAgent instanceof
                   Ant && ((Ant) moveAgent).colony !=
                              this.colony) { // the tile we tried to move to had
                                             // an ant
            // 50/50 chance for this ant to die, or the other ant to die
            if (random(1) < 0) {
                die();
            } else {
                ((Ant) moveAgent).die();
            }
        } else if (moveAgent instanceof Colony) {
            ((Colony) moveAgent).die(); // "kill" the opposing colony's queen
            foodTaken =
                min(1 - foodLevel, ((Colony) moveAgent).foodLevel
                ); // take food from that colony
            foodLevel += foodTaken;
            ((Colony) moveAgent).foodLevel -= foodTaken;
        }
    }

    void enterColony(Tile tile) {
        // go into our colony
        cooldown = 150;
        tile.agent = null;
        tile.popColor();
        inHole = true;
        colony.antQueue.add(this);

        colony.fitness += foodLevel;
        colony.foodLevel += foodLevel;
        foodLevel = 0;
    }

    void die() {
        // set the tile we are on to have 1 food (ant cannibalism)
        Tile tile = grid.get(x, y);
        tile.agent = null;
        tile.popColor();

        if (tile.foodLevel > 0) {
            tile.popColor();
        }

        tile.pushFood(1);
        population.population--;
        dead = true;
    }

    void drawUI(float x, float y) {
        if (selectedNetwork != null) {
            selectedNetwork.draw(x, y, width / 4, height / 2);
        }

        String output = "food: " + foodLevel + "\n" +
                        "species ID: " + colony.species.id + "\n";
        fill(0);
        textAlign(LEFT, TOP);
        textSize(24);
        text(output, x + 5, y + (height / 2) + 15);
    }

    void dropPheromone(int type) {
        new Pheromone(colony, type, pheromoneLength, x, y);
    }
}