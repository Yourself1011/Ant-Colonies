void mouseDragged() {
    cameraPos.sub((mouseX - pmouseX) / cameraZoom, (mouseY - pmouseY) / cameraZoom);
}

void mouseWheel(MouseEvent e) {
    // cameraZoom -= e.getCount() / 15.0;
    float count = e.getCount();

    if (count < 0) {
        cameraZoom *= 1.1;
    } else if (count > 0) {
        cameraZoom /= 1.1;
    }

    cameraZoom = clamp(cameraZoom, 0.1, 100);
}

float mouseStartX, mouseStartY;

void mousePressed() {
    mouseStartX = mouseX;
    mouseStartY = mouseY;
}

void mouseReleased() {
    if (dist(mouseStartX, mouseStartY, mouseX, mouseY) != 0) return;

    PVector coords = screenCoordsToGlobal(new PVector(mouseX, mouseY));
    // println(coords);

    int xGrid = floor(coords.x / 10);
    int yGrid = floor(coords.y / 10);

    if (xGrid >= 0 && xGrid < grid.width && yGrid >= 0 && yGrid < grid.height) {
        Tile tile = grid.get(xGrid, yGrid);
        selectedAgent = tile.agent;
        // println(tile.x, tile.y, tile.agent);
    }
}

void keyPressed() {
    switch (Character.toLowerCase(key)) {
        case '-':
            speed *= 1.5;
            break;
        case '=':
            speed /= 1.5;
            break;
        case 'n':
            skipGeneration = true;
            background(255);
            drawProgress();
            break;
        case 'o':
            generationSpeed = max(generationSpeed - 1, 1);
            break;
        case 'p':
            generationSpeed += 1;
            break;
    }    
}