class Network {
    ArrayList<Layer> layers = new ArrayList<Layer>();
    ArrayList<Connection> connections = new ArrayList<Connection>();
    Layer inputLayer, outputLayer;

    Network(int inputs, int outputs) {
        inputLayer = new Layer(this, inputs, 0);
        outputLayer = new Layer(this, outputs, 1);

        layers.add(inputLayer);
        layers.add(outputLayer);

        // Connect all/some starting nodes (NEAT)
        for (Neuron outputNode : outputLayer) {
            for (Neuron inputNode : inputLayer) {
                if (random(1) < initConnectionsChance || inputNode.layer == 0 && inputNode.index == 0) { // connect the bias node to every output node, otherwise random chance of connection being made
                    outputNode.connect(inputNode, random(-weightLimit, weightLimit));
                }
            }
        }
        connectRandom(); // ensure at least one connection
    }

    Network() {}

    void draw(float x, float y, float width, float height) {
        // displays neural network
        float baseNeuronSize = clamp(width / layers.size() / 2, 2, 25);
        float horizontalInterval = (width - baseNeuronSize) / (layers.size() - 1);

        for (int iLayer = 0; iLayer < layers.size(); iLayer++) {
            
            Layer layer = layers.get(iLayer);
            int numNeurons = layer.neurons.size();
            float verticalInterval = height / numNeurons;

            float neuronSize = min(baseNeuronSize, clamp(height / layer.neurons.size(), 2, 25)); // the size of the neuron, so it can fit right on the screen
            layer.neuronDisplaySize = neuronSize;
            for (int iNeuron = 0; iNeuron < numNeurons; iNeuron++) {
            
                Neuron neuron = layer.get(iNeuron);
                stroke(neuron.output < 0 ? 0 : 255);
                fill(abs(neuron.output) * 255);

                float neuronX = x + horizontalInterval * iLayer + baseNeuronSize/2;
                float neuronY = y + verticalInterval * (iNeuron + 0.5) + baseNeuronSize/2;

                circle(neuronX, neuronY, neuronSize);
                neuron.displayPos = new PVector(neuronX, neuronY);

                for (Connection connection : neuron.connections) {
                    if (connection.enabled) {
                        float inNeuronSize = layers.get(connection.neuronIn.layer).neuronDisplaySize;

                        PVector targetPos = connection.neuronIn.displayPos;
                        stroke(connection.weight < 0 ? 0 : 255);
                        strokeWeight(abs(connection.weight) * 5);
                        line(neuronX - baseNeuronSize / 2, neuronY, targetPos.x + inNeuronSize / 2, targetPos.y);
                        strokeWeight(1);
                    }
                }

            }
        }
    }

    void think() {
        for (int i = 1; i < layers.size(); i++) {
            for (Neuron neuron : layers.get(i)) {
                neuron.think();
            }
        }
    }

    void connectRandom() {
        // create random connection
        if (!fullyConnected()) {
            int layer1;
            int neuron1;
            int layer2;
            int neuron2;

            do {
                layer1 = floor(random(1, layers.size()));
                neuron1 = floor(random(layers.get(layer1).neurons.size()));
                layer2 = floor(random(0, layer1));
                neuron2 = floor(random(layers.get(layer2).neurons.size()));
            } while (layers.get(layer1).get(neuron1).connectedTo(layers.get(layer2).get(neuron2))); // while the connection doesn't already exist
            layers.get(layer1).get(neuron1).connect(layers.get(layer2).get(neuron2), random(-weightLimit, weightLimit));
        }
    }

    boolean fullyConnected() {
        // returns whether every node is connected to every other node (no new connections can be added)
        int runningNeuronCount = 0;

        for (Layer layer : layers) {
            for (Neuron neuron : layer) {
                if (neuron.connections.size() < runningNeuronCount) {
                    return false;
                }
            }
            
            runningNeuronCount += layer.neurons.size();
        }

        return true;
    }

    void connect(int layer1, int neuron1, int layer2, int neuron2) {
        layers.get(layer1).get(neuron1).connect(layers.get(layer2).get(neuron2), random(-weightLimit, weightLimit));
    }

    void addRandom() {
        // Insert a node randomly between two connected nodes
        Neuron neuron, neuronIn;
        do {
            neuron = layers.get(floor(random(1, layers.size()))).getRandom();

            if (neuron.connections.size() == 1) {
                neuronIn = neuron.connections.get(0).neuronIn;
            } else {
                neuronIn = neuron; // just to make the compiler happy
            }
        } while (neuron.connections.size() == 0 || (neuron.connections.size() == 1 && neuronIn.layer == 0 && neuronIn.index == 0)); // while the node has a connection, and if it only has one, it cannot be the bias node

        Connection connection;

        do {   
            connection = neuron.connections.get(floor(random(neuron.connections.size())));
            neuronIn = connection.neuronIn;
        } while (neuronIn.layer == 0 && neuronIn.index == 0); // do not select the bias node

        int layerNum = connection.neuronIn.layer + 1;
        if (connection.neuronOut.layer - connection.neuronIn.layer == 1) {
            addLayer(layerNum);
        }

        Layer layer = layers.get(layerNum);
        Neuron newNeuron = layer.add(new Neuron(this, layerNum, layer.neurons.size()));

        newNeuron.connect(connection.neuronIn, connection.weight);
        newNeuron.connect(layers.get(0).get(0), 0); // connect to bias
        connection.neuronOut.connect(newNeuron, connection.weight);

        connection.enabled = false;
    }

    void mutateWeights() {
        for (Layer layer : layers) {
            for (Neuron neuron : layer) {
                neuron.mutateWeights();
            }
        }
    }

    Layer addLayer(int i) {
        for (int j = i; j < layers.size(); j++) {
            layers.get(j).shiftLayer();
        }
        Layer newLayer = new Layer(this, i);
        layers.add(i, newLayer);
        return newLayer;
    }

    NetworkDifference compare(Network target) {
        ArrayList<Connection> disjoint = new ArrayList<Connection>(), excess = new ArrayList<Connection>(), matchingThis = new ArrayList<Connection>(), matchingTarget = new ArrayList<Connection>();
        float totalWeightDiff = 0;
        float numSame = 0;
        boolean connectionFound = false;

        Comparator comparator = Comparator.comparing(Connection::getInnovationNumber);
        int minThis = ((Connection) Collections.min(this.connections, comparator)).innovationNumber;
        int maxThis = ((Connection) Collections.max(this.connections, comparator)).innovationNumber;
        int minTarget = ((Connection) Collections.min(target.connections, comparator)).innovationNumber;
        int maxTarget = ((Connection) Collections.max(target.connections, comparator)).innovationNumber;

        ArrayList<Connection> unmatchedConnections = (ArrayList) this.connections.clone();

        for (Connection targetConnection : target.connections) {
            for (int i = 0; i < unmatchedConnections.size(); i++) {
                Connection connection = unmatchedConnections.get(i);
                if (connection.innovationNumber == targetConnection.innovationNumber) {
                    matchingThis.add(connection);
                    matchingTarget.add(targetConnection);

                    connectionFound = true;
                    numSame++;
                    totalWeightDiff += abs(connection.weight - targetConnection.weight);

                    unmatchedConnections.remove(connection);
                    i--;
                }
            }

            if (!connectionFound) {
                if (minThis < targetConnection.innovationNumber && maxThis > targetConnection.innovationNumber) {
                    disjoint.add(targetConnection);
                } else {
                    excess.add(targetConnection);
                }
            }

            connectionFound = false;
        }

        for (Connection connection : unmatchedConnections) {
            if (minTarget < connection.innovationNumber && maxTarget > connection.innovationNumber) {
                disjoint.add(connection);
            } else {
                excess.add(connection);
            }
        }

        return new NetworkDifference(disjoint, excess, matchingThis, matchingTarget, numSame != 0 ? totalWeightDiff / numSame : 0);
    }

    Network mutate() {
        if (random(1) < weightChance) {
            mutateWeights();
        }

        if (random(1) < connectionChance) {
            connectRandom();
        }

        if (random(1) < neuronChance) {
            addRandom();
        }

        return this;
    }

    Network createOffspring(Network parent2, float fitnessThis, float fitnessTarget) {
        Network moreFit, lessFit, offSpring = new Network();
        
        if (fitnessThis > fitnessTarget) {
            moreFit = this;
            lessFit = parent2;
        } else {
            moreFit = parent2;
            lessFit = this;
        }

        NetworkDifference diff = moreFit.compare(lessFit);

        for (Layer layer : moreFit.layers) {
            Layer layerCopy = layer.copy(offSpring);
            offSpring.layers.add(layerCopy);
            for (Neuron neuron : layer.neurons) {
                for (Connection connection : neuron.connections) {

                    int matchingIndex = diff.matching1.indexOf(connection);
                    float weight;
                    boolean enabled = true;

                    if (matchingIndex == -1) {
                        weight = connection.weight;
                    } else {
                        Connection connection2 = diff.matching2.get(matchingIndex);
                        weight = random(1) < 0.5 ? connection.weight : connection2.weight;
                        enabled = !connection.enabled || !connection2.enabled ? random(1) < 0.25 : true;
                    }

                    layerCopy.get(neuron.index).connect(offSpring.layers.get(connection.neuronIn.layer).get(connection.neuronIn.index), weight, connection.innovationNumber, enabled);
                }
            }
        }
        offSpring.inputLayer = offSpring.layers.get(0);
        offSpring.outputLayer = offSpring.layers.get(offSpring.layers.size() - 1);

        return offSpring;
    }

    Network copy() {
        Network copy = new Network();

        for (Layer layer : layers) {
            Layer layerCopy = layer.copy(copy);
            copy.layers.add(layerCopy);
            for (Neuron neuron : layer.neurons) {
                for (Connection connection : neuron.connections) {
                    layerCopy.get(neuron.index).connect(copy.layers.get(connection.neuronIn.layer).get(connection.neuronIn.index), connection.weight, connection.innovationNumber);
                }
            }
        }
        copy.inputLayer = copy.layers.get(0);
        copy.outputLayer = copy.layers.get(copy.layers.size() - 1);

        return copy;
    }
}
