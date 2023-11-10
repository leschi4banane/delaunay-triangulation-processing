import java.util.List; //<>//
import controlP5.*;


ControlP5 c1;
PGraphics last_calc;

int nSeeds = 100;
List<Point> seeds = new ArrayList<Point>();
int nDraws;
boolean recalculate = true;

int startX, startY, endX, endY;

void setup() {
  size(750, 1050);
  last_calc = createGraphics(750, 1050);
  pixelDensity(2);
  smooth();
  startX = (int)((width-width/1.4)/2);
  startY = (int)((height-width/1.4)/2);
  endX = (int)(((width-width/1.4)/2)+width/1.4);
  endY = (int)(((height-width/1.4)/2)+width/1.4);
 
  // adds n_seeds number of random seeds the the seeds list
  for (int i = 0; i<nSeeds; i++) {
    Point P;
    while (true) {
      P = new Point(int(random(startX, endX)), int(random(startY, endY)));
      if (!seeds.contains(P)) {
        seeds.add(P);
        break;
      }
    }
  }
  c1 = new ControlP5(this);
  c1.addSlider("number of draws")
    .setPosition(20,20)
    .setSize(400, 40)
    .setRange(1, 300)
    .setValue(1)
    .getCaptionLabel().setSize(15).alignX(ControlP5.RIGHT);
  c1.addToggle("thick")
    .setPosition(20,75)
    .setSize(40, 40)
    .setValue(1)
    .getCaptionLabel().setColor(color(0)).setSize(15).align(ControlP5.CENTER, ControlP5.CENTER);
  c1.addButton("saveButton")
    .setPosition(20,130)
    .setSize(400, 40)
    .activateBy(ControlP5.PRESSED)
    .getCaptionLabel().setSize(15);
  c1.addSlider("randomPoints")
    .setPosition(75,75)
    .setSize(200, 40)
    .setRange(1, 500)
    .setValue(200)
    .getCaptionLabel().setSize(15).alignX(ControlP5.RIGHT);
   c1.addButton("regenerate")
    .activateBy(ControlP5.PRESSED)
    .setPosition(290,75)
    .setSize(130, 40)
    .getCaptionLabel().setSize(15);
}


void draw() {
  if (recalculate || (mousePressed && new Point(mouseX, mouseY).insideBorder(startX, startY, endX, endY))) {
    // addedseed is true if the seed at the mouse cursor is getting shown
    // seedAdded variable represent the seed added by the cursor
        List<Point> seedsCopy = new ArrayList<Point>(seeds);
    Point mouseseed = new Point(-1, -1);
    // adds a seed at the cursor to the seeds list if the mouse is pressed
    if (mousePressed) {
      mouseseed = new Point(mouseX, mouseY);
      if (mouseseed.insideBorder(startX, startY, endX, endY)) { 
        seedsCopy.add(mouseseed);
      }
    }
    
    last_calc.beginDraw();
    last_calc.background(200);
    last_calc.noFill();
    
    background(200);
    noFill();
    if (c1.getController("thick").getValue() == 1) { last_calc.strokeWeight(3); }
    else { last_calc.strokeWeight(0.001); }
    
    nDraws = (int)c1.getController("number of draws").getValue();
    float color_step = 255/nDraws;
    for (int i = 0; i<nDraws; i++) {
      last_calc.stroke(0,0,0,255-color_step*i);
      List<Line> voronoi = new ArrayList<Line>(new voronoiDiagramm(seedsCopy, startX, endX, startY, endY).lines);       for (Line edge:voronoi) {
      last_calc.line(edge.A.x, edge.A.y, edge.B.x, edge.B.y);       }       for (Point seed:seedsCopy) {         seedsCopy.set(seedsCopy.indexOf(seed) , new Point(seed.x+random(-1.5,1.5), seed.y+random(-1.5,1.5)));;       }     }
    last_calc.endDraw();
     recalculate = false;
  }
    image(last_calc, 0, 0); 

  
}
void mousePressed() {
  recalculate = true;
}

void mouseReleased() {
  
  if (new Point(mouseX, mouseY).insideBorder(startX, startY, endX, endY)) { 
    seeds.add(new Point(mouseX, mouseY));
    recalculate = true;
  }
}
void keyPressed() {
  last_calc.save("save.png");
}

public void saveButton(){
    last_calc.save("save.png");
    println("saved");
}

public void regenerate(){
  regenerateRandomPoints();
}
public void randomPoints(){
  nSeeds = (int)c1.getController("randomPoints").getValue();
  regenerateRandomPoints();
}

public void regenerateRandomPoints(){
    seeds.clear();
    for (int i = 0; i<nSeeds; i++) {
    Point P;
    while (true) {
      P = new Point(int(random(startX, endX)), int(random(startY, endY)));
      if (!seeds.contains(P)) {
        seeds.add(P);
        break;
      }
    }
  }
}
