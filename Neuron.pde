class Neuron {
    int layer, index;
    Network network;
    ArrayList<Connection> connections = new ArrayList<Connection>();
    float output = 0;
    PVector displayPos;

    Neuron(Network network, int layer, int index) {
        this.network = network;
        this.layer = layer;
        this.index = index;
    }

    void mutateWeights() {
        for (Connection connection : connections) {
            if (random(1) < 0.9) connection.weight = connection.weight + truncatedRandomGaussian(-weightLimit, weightLimit);
            else connection.weight = truncatedRandomGaussian(-weightLimit, weightLimit);
            // if (random(1) < 0.9) connection.weight = connection.weight + clamp(randomGaussian(), -weightLimit, weightLimit);
            // else connection.weight = clamp(randomGaussian(), -weightLimit, weightLimit);
        }
    }

    float sigmoid(float x) {
        return 1/(1+exp(-4.9 * x));
    }

    void think() {
        float output = 0;
        int numInputs = connections.size();
        for (int i = 0; i < numInputs; i++) {
            Connection connection = connections.get(i);
            if (connection.enabled) {
                output += connection.neuronIn.output * connection.weight;
            }
        }
        output = sigmoid(output);
        this.output = output;
    }

    void connect(Neuron target, float weight) {
        Connection connection = new Connection(network, target, this, weight);
        connections.add(connection);
        network.connections.add(connection);
    }
    void connect(Neuron target, float weight, int innovationNumber) {
        Connection connection = new Connection(network, target, this, weight, innovationNumber);
        connections.add(connection);
        network.connections.add(connection);
    }
    void connect(Neuron target, float weight, int innovationNumber, boolean enabled) {
        Connection connection = new Connection(network, target, this, weight, innovationNumber, enabled);
        connections.add(connection);
        network.connections.add(connection);
    }

    boolean connectedTo(Neuron target) {
        for (Connection connection : connections) {
            if (connection.neuronIn == target) return true;
        }
        return false;
    }

    void shiftLayer() {
        layer++;
    }

    Neuron copy(Network network) {
        Neuron copy = new Neuron(network, layer, index);
        // for (Connection connection : connections) {
        //     copy.connections.add(connection.copy());
        // }
        copy.output = output;
        if (displayPos != null) copy.displayPos = displayPos.copy();
        return copy;
    }
}
