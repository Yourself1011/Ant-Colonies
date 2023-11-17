class Colony extends TileAgent {
    Species species;
    Network network;
    ArrayList<Ant> ants = new ArrayList<Ant>();
    Queue<Ant> antQueue = new LinkedList<Ant>();
    color antColor;
    float foodLevel = 0, fitness = 0;
    boolean alive = true;

    Colony() {
        col = color(0);

        spawn();

        if (wrapAround) {
            network = new Network(42, 4); // wrap around
        } else {
            network = new Network(50, 4); // stop at edges
        }
    }

    Colony(Network network) {
        // spawn in later, after surviving colonies have been spawned, so as not to take the same spot

        col = color(0);

        this.network = network;
    }

    void spawn() {
        // Keep trying to spawn in a random location if it is not valid
        while(!spawn((int) random(0, grid.width), (int) random(0, grid.height)));
    }

    void chooseColor() {
        // pick a color similar to the species base color
        color specCol = species.baseCol;

        antColor = color(red(specCol) + (int) random(-20, 20), green(specCol) + (int) random(-20, 20), blue(specCol) + (int) random(-20, 20));
    }

    void reset() {
        ants.clear();
        antQueue.clear();
        fitness = 0;
        foodLevel = 0;
        alive = true;
        spawn(x, y);
    }

    void initialPopulation() {
        for (int i = 0; i < startingAnts; ++i) {
            spawnAnt(new Ant(antColor, network, this));
        }
    }

    void frame() {
        for (Ant ant : ants) {
            if (!ant.inHole && !ant.dead) {
                ant.think();
            }
        }

        ants.removeIf(a -> a.dead);

        if (foodLevel >= foodForBaby && alive) {
            spawnAnt(new Ant(antColor, network, this));
            foodLevel -= foodForBaby;
        }
        spawnQueuedAnts();
        if (alive) fitness += 0.0005; // give the network a cookie just for being alive
    }

    void spawnAnt(Ant ant) {
        antQueue.add(ant);
        ants.add(ant);
    }

    void spawnQueuedAnts() {
        ArrayList<Tile> neighbors = new ArrayList<Tile>(grid.get(x, y).neighbors());
        ArrayList<Ant> stillOnCooldown = new ArrayList<Ant>();

        while (neighbors.size() > 0 && antQueue.size() > 0) {
            Ant nextAnt = antQueue.peek();
            if (nextAnt.cooldown > 0) {
                nextAnt.cooldown--;
                stillOnCooldown.add(antQueue.remove());
                continue;
            }
            Tile tile = neighbors.get((int) random(neighbors.size()));

            if (nextAnt.spawn(tile.x, tile.y)) {
                antQueue.remove().inHole = false;
            }

            neighbors.remove(tile);
        }

        antQueue.addAll(stillOnCooldown);
    }

    void die() {
        alive = false;
        Tile tile = grid.get(x, y);
        tile.popColor();
        tile.pushColor(96);
    }

    void drawUI(float x, float y) {
        String output = "food: " + foodLevel + "\n" +
            "fitness: " + fitness + "\n" +
            "population: " + ants.size() + "\n" + 
            "queen alive: " + alive + "\n" +
            "species ID: " + species.id + "\n";
        fill(0);
        textAlign(LEFT, TOP);
        textSize(24);
        text(output, x + 5, y + 5);
    }
}