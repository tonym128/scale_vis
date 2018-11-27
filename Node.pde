import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

class Node implements Comparable {
  
  /* An arbitrary conversion factor from SHF mass units to pixels */
  int radiusFactor = 10; // [radial pixels / kg]

  // Parsed information:
  ArrayList<Spring> neighbors;
  String id; // Unique node ID [string]
  int mass;  // node mass      [kg]
  float r;   // radius         [meters]
  
  // Calculated information (for each time step):
  PVector f; // total force      [kg * m / s^2]
  PVector a; // total accel      [m / s^2]
  PVector v; // current velocity [m / s]
  PVector p; // current position [m]

  Node(String id, int mass) {
    this.neighbors = new ArrayList<Spring>();
    this.id = id;
    this.mass = mass;
    f = new PVector(0, 0);
    a = new PVector(0, 0);
    v = new PVector(0, 0);
    p = new PVector(random(0,width), random(0,height));
    r = radiusFactor * sqrt(mass / PI);
  }
  
  Node(String id) { this(id,0); }

  void setPos(int x, int y) { p.x = x; p.y = y; }
  
  /* Enforces the condition that nodes cannot go off the edge of the screen */
  void checkBounds() {
    if (p.x - r < 0) {
      resizeWindow();
      p.x = r; // place node back inside box
      v.x = abs(v.x); // perfectly elastic bounce against wall
    }
    if (p.y - r < 0) {
      resizeWindow();
      p.y = r;
      v.y = abs(v.y);
    }
    if (p.x + r > width) {
      resizeWindow();
      p.x = width - r;
      v.x = 0 - abs(v.x);
    }
    if (p.y + r > height) {
      resizeWindow();
      p.y = height - r;
      v.y = 0 - abs(v.y);
    }
  }

  void draw() {
    fill(0);
    ellipse(p.x, p.y, 2.0 * r, 2.0 * r);
    textSize(12);
    textAlign(CENTER, CENTER);
    fill(255);
    //text(id, p.x, p.y);
  }

  // Calculate the new velocity
  void calcVelocity() {
    
    // This is what I want to code:
    // v = v + a * dt;

    // This is what I have to code:
    PVector t2 = a.get();
    t2.mult(dt);
    v.add(t2);
  
  }

  // Updates the position vector of this Node
  void calcPosition() {

    // This is what I want to code:
    // p = p + v * dt + (0.5) * a * sq(dt);

    // This is what I have to code:
    PVector t1 = this.a.get();
    t1.mult(sq(dt));
    t1.mult(0.5);
    
    PVector t2 = this.v.get();
    t2.mult(dt);
    
    p.add(t1);
    p.add(t2);
  
  }

  // Updates the acceleration vector of this Node
  void calcAccel() {
    a = f.get();
    a.div(mass);
  }

  // Computes the total spring force on this node and adds
  // it to the total force vector
  void addHook() {
    for (int i = 0; i < neighbors.size(); i++)
      f.add(neighbors.get(i).calcHook(this));
  }

  PVector calcCoulomb(Node n) {
    // I want to code this:
    // return beta / pow(this.p.dist(n.p), 2);
    
    // But I have to code this :(
    PVector tmp = unitVec(p, n.p);
    float d = p.dist(n.p);
    tmp.div(d <= 0 ? 1 : d);
    tmp.mult(beta);
    return tmp;
  }

  // Computes the total Coulomb force on this node, adding it to f
  void addCoulomb() {
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i) != this)
        f.add(calcCoulomb(nodes.get(i)));
    }
  }

  // Computes the damping force based on the last known velocity
  void addDamp() {
    PVector tmp = v.get();
    tmp.mult(-c);
    f.add(tmp);
  }

  void addWall() {
    if (p.x != 0.0)
      f.add(500 / p.x, 0.0, 0.0);
    if (width - p.x != 0.0)
      f.add(-500 / (width - p.x), 0.0, 0.0);
    if (p.y != 0.0)
      f.add(0.0, 500 / (p.y + 1), 0.0);
    if (height - p.y != 0.0)
      f.add(0.0, -500 / (height - p.y), 0.0);
  }

  // Updates the force vector of this Node
  void calcForce() {
    f.set(0, 0);
    addDamp();
    addHook();
    addCoulomb();
    addWall();
    f.add(curr_gravity);
  }
 
  // Updates the fields of this Node to correspond to the next time step:
  void eulerStep() {
    calcForce();
    calcAccel();
    calcVelocity();
    calcPosition();
    checkBounds();
  }

  float calcKinetic() { return (0.5) * mass * v.magSq(); }
  float calcEnergy() { return calcKinetic(); }
  
  boolean intersect (int x, int y) {
    return (x <= p.x + r && x >= p.x-r) && (y <= p.y +r && y >= p.y - r);
  }
  
  /* Override equals() to allow for comparison with ID */
  @Override
  public boolean equals(Object obj) {
    return ((obj instanceof Node) && (((Node)obj).id.equals(this.id)));
  }

  /* compareTo allows for sorting by mass of the Node */
  public int compareTo(Object e2) {
    return ((Node)e2).mass - this.mass;
  }

}
