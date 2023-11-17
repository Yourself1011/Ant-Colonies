static class Connection {
    Neuron neuronIn, neuronOut;
    Network network;
    float weight;
    int innovationNumber;
    boolean enabled;
    static int globalInnovationNumber = 0; // the next innovation number, globally

    Connection(Network network, Neuron neuronIn, Neuron neuronOut, float weight) {
        this(network, neuronIn, neuronOut, weight, globalInnovationNumber);
        network.connections.add(this);
        globalInnovationNumber++; // so that all innovation numbers are unique
    }

    Connection(Network network, Neuron neuronIn, Neuron neuronOut, float weight, int innovationNumber) {
        this(network, neuronIn, neuronOut, weight, innovationNumber, true);
    }

    Connection(Network network, Neuron neuronIn, Neuron neuronOut, float weight, int innovationNumber, boolean enabled) {
        this.network = network;
        this.neuronIn = neuronIn;
        this.neuronOut = neuronOut;
        this.weight = weight;
        this.innovationNumber = innovationNumber;
        this.enabled = enabled;
    }

    void newInnovationNumber() {
        this.innovationNumber = globalInnovationNumber;
        globalInnovationNumber++; // so that all innovation numbers are unique
    }

    Connection copy(Network network) {
        return new Connection(network, neuronIn, neuronOut, weight, innovationNumber, enabled);
    }

    float getInnovationNumber() { // for sorting and max and min
        return innovationNumber;
    }
}