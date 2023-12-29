class Tile {
    int x, y;
    Stack<Integer> colorStack = new Stack<Integer>();
    ArrayList<Pheromone> pheromones = new ArrayList<Pheromone>();
    float foodLevel = 0;
    TileAgent agent;

    Tile(int x, int y) {
        this.x = x;
        this.y = y;
        colorStack.push(#FFFFFF);
    }

    void reset() {
        colorStack.clear();
        colorStack.push(#FFFFFF);
        pheromones.clear();
        foodLevel = 0;
        agent = null;
    }

    void draw() {
        if (selectedAgent != null && agent == selectedAgent)
            selectedTile = this;
        stroke(0);
        fill(colorStack.peek());
        square(x * tileSize, y * tileSize, tileSize);

        if (pheromones.size() > 0) {
            Pheromone pheromone = pheromones.get(pheromones.size() - 1);
            color c = pheromone.colony.antColor;
            fill(color(
                red(c),
                green(c),
                blue(c),
                float(pheromone.strength) / pheromoneLength * 255
            ));
            noStroke();
            square(
                x * tileSize + tileSize / 4,
                y * tileSize + tileSize / 4,
                tileSize / 2
            );
        }
    }

    void frame() {
        for (Pheromone pheromone : pheromones) {
            pheromone.frame();
        }

        pheromones.removeIf(p->p.strength <= 0);
    }

    void drawOutline(color stroke) {
        stroke(stroke);
        noFill();
        square(x * tileSize, y * tileSize, tileSize);
    }

    void pushColor(color col) { colorStack.push(col); }

    color popColor() {
        if (colorStack.size() == 1) {
            // new Exception().printStackTrace();
        }
        return colorStack.pop();
    }

    void pushFood(float level) {
        foodLevel = level;
        if (level > 0) {
            colorMode(HSB, 360, 100, 100);
            pushColor(color(101, 100, foodLevel * 50 + 50));
            colorMode(RGB, 255, 255, 255);
        }
    }

    ArrayList<Tile> neighbors() {
        ArrayList<Tile> tiles = new ArrayList<Tile>();

        for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
                if (!(i == 0 && j == 0)) {
                    Tile relTile = getRelativeTile(i, j);
                    if (relTile != this) {
                        tiles.add(relTile);
                    }
                }
            }
        }
        return tiles;
    }

    Tile getRelativeTile(int x, int y) {
        if (wrapAround) {
            return grid.get(
                (this.x + x + grid.width) % grid.width,
                (this.y + y + grid.height) % grid.height
            ); // Wrap around
        } else {
            return grid.get(
                clamp(this.x + x, 0, grid.width - 1),
                clamp(this.y + y, 0, grid.height - 1)
            ); // stop at the edges
        }
    }

    boolean containsPheromone(Colony colony, int type) {
        for (Pheromone pheromone : pheromones) {
            if (pheromone.colony == colony && pheromone.type == type)
                return true;
        }
        return false;
    }
}