import java.util.List; //<>//

int n_seeds = 100;
List<Point> seeds = new ArrayList<Point>();

int startX, startY, endX, endY;

void setup() {
  size(500, 700);
  pixelDensity(2);
  noLoop();
  smooth(8);
  startX = (int)((width-width/1.4)/2);
  startY = (int)((height-width/1.4)/2);
  endX = (int)(((width-width/1.4)/2)+width/1.4);
  endY = (int)(((height-width/1.4)/2)+width/1.4);
 
  // adds n_seeds number of random seeds the the seeds list
  for (int i = 0; i<n_seeds; i++) {
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


void draw() {
  // addedseed is true if the seed at the mouse cursor is getting shown
  // seedAdded variable represent the seed added by the cursor
  boolean addedseed = false;
  Point mouseseed = new Point(-1, -1);
  // adds a seed at the cursor to the seeds list if the mouse is pressed
  if (mousePressed) {
    mouseseed = new Point(mouseX, mouseY);
    seeds.add(mouseseed);
    addedseed = true;
  }
  
  background(200);
  fill(0);
  noStroke();
  
  color[] seedColors = new color[seeds.size()];
  for (int i = 0; i<seeds.size(); i++) {
    seedColors[i] = color(random(255), random(255), random(255));
  }
  for (int x = startX; x<endX; x++) {
    for (int y = startY; y<endY; y++) {
      float minDist = width;
      Point closestSeed = null;
      for (Point seed:seeds) {
        if (dist(x, y, seed.x, seed.y) < minDist) {
          minDist = dist(x, y, seed.x, seed.y);
          closestSeed = seed;
        }
      }
      stroke(seedColors[seeds.indexOf(closestSeed)]);
      point(x,y);
    }
  }
  
  
  List<Point> seedsCopy = new ArrayList<Point>(seeds);
  noFill();
  //strokeWeight(0.001);
  strokeWeight(3);
  int nTimes = 1;
  float color_step = 255/nTimes;
  for (int i = 0; i<nTimes; i++) {
    stroke(0,0,0,255-color_step*i);
    List<Edge> voronoi = new ArrayList<Edge>(new voronoiDiagramm(seedsCopy, startX, endX, startY, endY).lines);
    for (Edge edge:voronoi) {
      line(edge.A.x, edge.A.y, edge.B.x, edge.B.y);
    }
    for (Point seed:seedsCopy) {
      seedsCopy.set(seedsCopy.indexOf(seed) , new Point(seed.x+random(-1.5,1.5), seed.y+random(-1.5,1.5)));;
    }
  }
  
  // removes the old seed created by the cursor if it was created
  if (addedseed == true) {
    seeds.remove(mouseseed);
  }
  
}

void mousePressed() {
  loop();
}
void mouseReleased() {
  seeds.add(new Point(mouseX, mouseY));
  redraw();
  noLoop();
}
void keyPressed() {
  save("save.png");
}
