class Layer implements Iterable<Neuron> {
    // layer in the neural network
    Network network;
    ArrayList<Neuron> neurons = new ArrayList<Neuron>();
    int layer;
    float neuronDisplaySize;

    Layer(Network network, int layer) {
        this.network = network;
        this.layer = layer;
    }

    Layer(Network network, int numNeurons, int layer) {
        this.network = network;
        for (int i = 0; i < numNeurons; i++) {
            neurons.add(new Neuron(network, layer, i));
        }
        this.layer = layer;
    }

    Neuron get(int i) {
        try {
            return neurons.get(i);
        } catch (IndexOutOfBoundsException e) {
            e.printStackTrace();
            return neurons.get(0);
        }
    }

    Neuron getRandom() { return neurons.get(floor(random(neurons.size()))); }

    Iterator<Neuron> iterator() { return neurons.iterator(); }

    Neuron add(Neuron neuron) {
        neurons.add(neuron);
        return neuron;
    }

    void shiftLayer() {
        layer++;
        neurons.forEach(n->n.shiftLayer());
    }

    Layer copy(Network network) {
        Layer copy = new Layer(network, layer);

        for (Neuron neuron : neurons) {
            copy.neurons.add(neuron.copy(network));
        }
        return copy;
    }
}