float clamp(float n, float min, float max) {
    return max(min(n, max), min);
}
int clamp(int n, int min, int max) {
    return max(min(n, max), min);
}

PVector screenCoordsToGlobal(PVector coords) {
    return new PVector((coords.x + (cameraPos.x * cameraZoom) - (width * 3/8)) / cameraZoom + (width * 3/8), (coords.y + (cameraPos.y * cameraZoom) - (height / 2)) / cameraZoom + (height / 2));
}

float truncatedRandomGaussian(float min, float max) {
    float number;
    do {
        number = randomGaussian();
    } while (number < min || number > max);
    return number;
}