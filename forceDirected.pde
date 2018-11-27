
//String csvFile = "data/_1000_crazy.csv";
String csvFile = "data/_alien.csv";
int Nodes = 2;
int Levels = 0;
int Relationships = 0;

float beta = 500.0; // Coulomb's constant
float dt  = 0.1;    // delta time constant
float k   = 1.0;    // Hook's constant
float c   = 1.0;    // Damping constant
float G   = 0.1; // Gravitational constant
float rho = 1.0;    // Density of invisible mass on screen
float PLATEAU = 50; // Gravitational plateau at center of window
float steady_state_E = 0.005; //2.10;
float steady_state_tmp = steady_state_E;
long time0 = System.nanoTime();
PVector curr_gravity = new PVector(0,0);
long time = 0;

// x,y location of the energy label
float Ex = 0.01;
float Ey = 0.01;

ArrayList<Node> nodes = null;
ArrayList<Spring> springs = null;

void setup() {
  size(1200,800);
  frame.setResizable(true);
  background(255);
  parseSHF(csvFile);
  
  // Fix radius based on screen resolution:
  /*
  float Area = 0.0;
  for (int i = 0; i < nodes.size(); i++) {
    Area += PI * sq(nodes.get(i).r);
  }
  float Win_Area = width * height;
  float scale_factor = sqrt( ((0.7 * Win_Area) / Area) / PI);
  for (int i = 0; i < nodes.size(); i++) {
    nodes.get(i).r *= scale_factor;
  }
  */
}

void draw() { 
  background(255);

  // Do Euler if in first 1 second of simulation, or total kinetic energy
  // is above the steady state energy
  boolean time = (System.nanoTime() - time0) < pow(10,9);
  if (time || (totalEnergy() >= steady_state_E))
    nextEuler();
  drawEnergy();
  
  // Draw springs first, then nodes:
  for (int i = 0; i < springs.size(); i++) { springs.get(i).draw(); }
  for (int i = 0; i < nodes.size();   i++) { nodes.get(i).draw(); }
}

// This is called every time a node bumps into the edge of the window
long curr_resize_time = 0;
void resizeWindow() {
  if (curr_resize_time != time) {
    curr_resize_time = time;
    for (int i = 0; i < nodes.size(); i++) {
      nodes.get(i).r /= 1.01;
    }
    for (int i = 0; i < springs.size(); i++) {
      springs.get(i).rl /= 2.0;
    }
    beta /= 1.1;
  }
}

void nextEuler() {
  time += 1;
  //curr_gravity = calcGravity();
  for (int i = 0; i < nodes.size(); i++)
    nodes.get(i).eulerStep();
}

void drawEnergy() {
  float E = totalEnergy();
  textAlign(LEFT, TOP);
  textSize(16);
  stroke(0.0);
  fill(0.0);
  text("Levels : " + Long.toString(Levels) + " People : " + Long.toString(Nodes) + " Relationships : " + Long.toString(Relationships), Ex*width, Ey*height);
}
  
Node curr_dragging = null;
void mouseDragged() {
  if (curr_dragging != null)
    curr_dragging.setPos(mouseX, mouseY);
}

void keyPressed() {
  steady_state_tmp = steady_state_E;
  steady_state_E = 0;

  if (key == 'a') Levels += 1;
  if (key == 's') Levels -= 1;
  if (key == 'q') Nodes += 1;
  if (key == 'w') Nodes -= 1;
  parseSHF(csvFile);

  curr_dragging = null;
  steady_state_E = steady_state_tmp;
}

void mousePressed() {
  steady_state_tmp = steady_state_E;
  steady_state_E = 0;
  for (int i = 0; i < nodes.size(); i++) {
    if (nodes.get(i).intersect(mouseX, mouseY)) {
      curr_dragging = nodes.get(i);
      break;
    }
  }
}

//void mouseClicked() {
//  Nodes += 1;
//  parseSHF(csvFile);
//}

void mouseReleased() {
  curr_dragging = null;
  steady_state_E = steady_state_tmp;
}

/* Calculates the total energy of the system */
float totalEnergy() {
  float sum = 0.0;
  for (int i = 0; i < nodes.size(); i++)
    sum += nodes.get(i).calcEnergy();
  return sum;
}

PVector calcGravity() {
  
  // Determine Center of Mass:
  PVector CoM = new PVector(0,0);
  float Mass = 0.0;
  PVector tmp;
  Node curr;
  for (int i = 0; i < nodes.size(); i++) {
    curr = nodes.get(i);
    tmp = curr.p.get();
    tmp.mult(curr.mass);
    CoM.add(tmp);
    Mass += curr.mass;
  }
  CoM.div(Mass);

  tmp = CoM.get();
  tmp.sub(width / 2.0, height / 2.0, 0);
  float r1 = tmp.mag();
  tmp.normalize();
  float m_rho = 2*PI*sq(r1)*rho;
  tmp.mult(r1 > PLATEAU ? -G * m_rho * Mass / (r1*r1) : 0);

  return tmp;
}

/*
float G = 10.0; // TODO: Determine a good gravitational constant
float M = 130.0; // TODO: Determine a good gravitational mass
 // Calculates the total gravitational force between a node and the
 // center of the window
PVector calcGravityForce(Node n) {
  
  PVector CoG = new PVector(width*0.5, height*0.5, 0); // Center of Gravity
  float num = G * M * n.mass;
  PVector tmp = CoG.get();
  tmp.sub(n.p);
  float denom = tmp.magSq() + 100;

  PVector unit = n.p.get();
  unit.sub(CoG);
  unit.mult((-1) * num / denom);

  // Turn off gravity if too close together:
  return Float.isNaN(unit.mag()) ? new PVector(0.0,0.0,0.0) : unit;
}*/

PVector unitVec(PVector p1, PVector p2) {
  PVector tmp = p1.get();
  tmp.sub(p2);
  tmp.normalize();
  return tmp;
}
