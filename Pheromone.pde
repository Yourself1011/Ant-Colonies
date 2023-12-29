class Pheromone {
    Colony colony;
    int type, strength, x, y;

    Pheromone(Colony colony, int type, int strength, int x, int y) {
        this.colony = colony;
        this.type = type;
        this.strength = strength;
        this.x = x;
        this.y = y;
        grid.get(x, y).pheromones.add(this);
    }

    void frame() { strength--; }
}