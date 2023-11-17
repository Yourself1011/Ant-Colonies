// Parent class for anything that can go on a tile
abstract class TileAgent implements DisplaysUI {
    color col;
    int x, y;
    boolean spawned = false;

    // no constructor since this class should never be used, only its children

    TileAgent move(int x, int y) {
        // x = (this.x + x + grid.width) % grid.width;
        // y = (this.y + y + grid.height) % grid.height;
        Tile nextTile = grid.get(this.x, this.y).getRelativeTile(x, y);

        if (nextTile.agent != null) return nextTile.agent;
        
        Tile prevTile = grid.get(this.x, this.y);
        if (nextTile != prevTile) {
            prevTile.popColor();
            prevTile.agent = null;
            this.x = nextTile.x;
            this.y = nextTile.y;

            nextTile.pushColor(col);
            nextTile.agent = this;
            population.movement = true;
        }
        return null;
    }

    boolean spawn(int x, int y) {
        Tile tile = grid.get(x, y);

        if (tile.agent != null) return false;
        this.x = x;
        this.y = y;
        tile.pushColor(col);
        tile.agent = this;
        spawned = true;
        return true;
    }
}

interface DisplaysUI {
    void drawUI(float x, float y);
}