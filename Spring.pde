class Spring {
  
  float rl;     // Resting length of this spring
  float length; // The current length of this spring
  Node n0;      // Node attached to this spring
  Node n1;      // Node attached to this spring

  Spring(Node n0, Node n1, float rl) {
    this.n0 = n0; this.n1 = n1;
    this.rl = rl;
    this.length = rl;
    recomputeLength();
  }

  void draw() {
    recomputeLength();
    line(n0.p.x,n0.p.y,n1.p.x,n1.p.y); 
  }

  /* Recomputes the current length of this spring based on the
     positions of the nodes it is attached to */
  void recomputeLength() {
    float x = n0.p.x - n1.p.x;
    float y = n0.p.y - n1.p.y;
    length = sqrt(x*x + y*y);
  }

  PVector calcHook(Node n){ 
    /*float ds = PVector.dist(n0.p, n1.p);
    PVector diff = PVector.sub(n0.p, n1.p);
    float vmag = diff.mag(); 
    diff.div(vmag); // divided the difference by the magnitude to get the unit vec
    float temp = -k * (sq(vmag) - rl);
    diff.mult(temp);
    return diff;
    */

    float ds = PVector.dist(n1.p, n0.p);
    float dl = ds - rl;
    PVector diff = PVector.sub(n1.p, n0.p);
    float vmag = diff.mag(); 
    if (vmag != 0){
      diff.div(vmag);
    } else {
      diff.div(0.00001);
    }
    diff.mult(k*dl);
    if (n.equals(n1)) diff.mult(-1); // opposite direction
    //println("diff"+diff);
    return diff;
  }
}
