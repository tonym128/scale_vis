
/**
 * Finds nodes with IDs id0 and id1 in the list of nodes, making
 * Node(id1) the child of Node(id0)
 **/
void linkNodes(String id0, String id1, float rl, ArrayList<Node> nodes) {

  int i0 = nodes.indexOf(new Node(id0));
  int i1 = nodes.indexOf(new Node(id1));
  if (i0 < 0) {
    nodes.add(new Node(id0));
    i0 = nodes.indexOf(new Node(id0));
  }
  if (i1 < 0) {
    nodes.add(new Node(id1));
    i1 = nodes.indexOf(new Node(id1));
  }

  //println(i0,i1);
  /* Find n0 and n1, adding n1 to n0's list of neighbors: */
  Node n0 = nodes.get(i0);
  Node n1 = nodes.get(i1);
  Spring s = new Spring(n0, n1, rl);
  n0.neighbors.add(s);
  n1.neighbors.add(s);

  springs.add(s);
}

String[] makeNodes(int nodes, int levels) {
  println(nodes);
  println(levels);
  
  int nodelayers = nodes/(levels+1);
  int relationships = (nodelayers*(nodelayers - 1) / 2) * (levels+1);
  String data[] = new String[nodes + relationships + 2];
  data[0] = Integer.toString(nodes);
  for (int i = 1; i <= nodes; i = i+1) {
    data[i] = Integer.toString(i) + ",2";
  }

  data[nodes+1] = Integer.toString(relationships);
  int currentRelRow = nodes+2;
  for (int i = 1; i < nodes; i = i+1) {
    for (int j = i+1; j <= nodes; j = j+1) {
      data[currentRelRow] = Integer.toString(i) + "," + Integer.toString(j) + "," + Integer.toString(1+nodes);
      currentRelRow += 1;
    }
  }
  
  //for (int row = 0; row < nodes + rows + 2; row = row + 1) {
  //println(data[row]); 
  //}
  
  return data;
}

/**
 * Parses the given SHF file, populating a new Tree object
 **/
void parseSHF(String fn) {
  /* Loop variables */
  String tmp[];
  int mass; // mass of the current node
  float rl;   // rest length of the current spring
  String id0,id1;
  String id;

  String data[] = makeNodes(Nodes, Levels);
  //String data[] = loadStrings(fn);
  int num_nodes = Integer.parseInt(trim(data[0]));
  int num_rltns = Integer.parseInt(trim(data[num_nodes+1]));
  Relationships = num_rltns;  
  nodes = new ArrayList<Node>();
  springs = new ArrayList<Spring>();

  /* Create leaf nodes from SHF */
  for (int i = 1; i <= num_nodes; i++) {
    tmp = splitTokens(data[i],",");
    //println(tmp);
    id = trim(tmp[0]);
    //println(tmp); println(tmp.length);
    mass = Integer.parseInt(trim(tmp[1]));
    nodes.add(new Node(id,mass));
  }

  /* Add parent-child relationships to nodes */
  for (int i = num_nodes + 2; i < num_nodes + 2 + num_rltns; i++) {
    tmp = splitTokens(data[i],",");
    id0 = trim(tmp[0]);
    id1 = trim(tmp[1]);
    rl = Float.parseFloat(trim(tmp[2]));
    linkNodes(id0, id1, rl, nodes);
    //println(id0,",",id1);
  }

}
