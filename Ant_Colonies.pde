/**
An implementation of Kenneth Stanley's NeuroEvolution of Augmenting Topologies
(NEAT) Follows this paper:
https://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf
CONTROLS:
Click + drag - move around
Scroll - zoom
+/- - simulation speed
o/p - number of generations skipped between rendered ones
n - skip to next generation
 */

import java.util.*;

PVector cameraPos;
float cameraZoom = 1;
float tileSize = 10;
Grid grid = new Grid(200, 250);
Population population = new Population();
TileAgent selectedAgent;
Network selectedNetwork;
Tile selectedTile;
float speed = 5;
int iterationFrames = 0, generationIteration = 0, generationElapsed = 0,
    generationCount = 0, generationSpeed = 1000;
boolean skipGeneration = false;

void setup() {
    // fullScreen();
    size(512, 512);
    windowResizable(true);
    cameraPos = new PVector(0, 0);
    population.firstGeneration();
}

void draw() {
    background(255);

    pushMatrix();
    translate(-cameraPos.x * cameraZoom, -cameraPos.y * cameraZoom);

    translate(width * 3 / 8, height / 2); // center of screen without ui
    scale(cameraZoom);
    translate(-width * 3 / 8, -height / 2); // center of screen without ui

    for (int i = 0; i < floor(iterationFrames / speed) || skipGeneration; i++) {
        // Keep simulating iterations without drawing anything, and only
        // simulate a frame if, when the speed is above 1, some number of frames
        // have passed
        population.frame();
    }

    if (generationIteration == 0) {
        // draw something now
        grid.draw();

        // UI elements
        popMatrix();
        drawUI();

        if (iterationFrames < speed) {
            iterationFrames++;
        } else {
            iterationFrames = 0;
        }
    } else {
        // When skipping through generations
        popMatrix();
        skipGeneration = true;
        drawProgress();
    }
}

void drawUI() {
    noStroke();
    fill(128);
    rect(width * 3 / 4, 0, width / 4, height);
    if (selectedAgent != null) {
        // draw ui of thing that's selected (ant or colony)
        selectedAgent.drawUI(width * 3.0 / 4, 0.0);
    } else {
        // general simulation information
        String output = "top score: " + population.topScore + " (gen " +
                        population.topScoreGeneration + ")\n" +
                        "speed: " + (1 / speed) + "\n" +
                        "generation: " + (generationCount + 1) + "\n" +
                        "generation progress: " + generationElapsed + "/" +
                        generationLength + "\n" +
                        "generations at once: " + generationSpeed + "\n" +
                        "species: " + population.species.size() + "\n" +
                        "ants: " + population.population + "\n";
        fill(0);
        textAlign(LEFT, TOP);
        textSize(24);
        text(output, width * 3 / 4 + 5, 5);
    }
}

void drawProgress() {
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("Simulating...", width / 2, height / 2 - 64);
    text(
        generationIteration + "/" + generationSpeed,
        width / 2,
        height / 2 + 64
    );
}