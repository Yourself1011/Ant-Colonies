class Grid implements Iterable<Tile[]> {
    Tile[][] tiles;
    int height, width;

    Grid(int height, int width) {
        this.height = height;
        this.width = width;
        this.tiles = new Tile[width][height];

        for (int x = 0; x < width; ++x) {
            for (int y = 0; y < height; ++y) {
                tiles[x][y] = new Tile(x, y);
            }
        }
    }

    Iterator<Tile[]> iterator() {
        return Arrays.stream(this.tiles).iterator();
    }

    Tile get(int x, int y) {
        return this.tiles[x][y];
    }

    void draw() {
        for (Tile[] column : this) {
            for (Tile tile : column) {
                tile.draw();
            }
        }
        if (selectedAgent != null) selectedTile.drawOutline(color(255, 255, 0));
    }

    void reset() {
        for (Tile[] column : this) {
            for (Tile tile : column) {
                tile.reset();
            }
        }
    }
}