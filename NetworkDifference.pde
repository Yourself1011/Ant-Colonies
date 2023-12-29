// A helper class to store the results of a difference in two networks
class NetworkDifference {
    ArrayList<Connection> disjoint, excess, matching1, matching2;
    float avgWeightDiff;

    NetworkDifference(
        ArrayList<Connection> disjoint,
        ArrayList<Connection> excess,
        ArrayList<Connection> matching1,
        ArrayList<Connection> matching2,
        float avgWeightDiff
    ) {
        this.disjoint = disjoint;
        this.excess = excess;
        this.matching1 = matching1;
        this.matching2 = matching2;
        this.avgWeightDiff = avgWeightDiff;
    }
}