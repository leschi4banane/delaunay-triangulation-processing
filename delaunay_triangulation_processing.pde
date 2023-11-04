import processing.svg.*; //<>// //<>//
import java.util.List;

int n_seeds = 100;
int n_exports = 0;
List<Point> seeds = new ArrayList<Point>();

int startX, startY, endX, endY;


void setup() {
  //size(700, 700, SVG, "save.svg");
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
    Point P = new Point(int(random(startX, endX)), int(random(startY, endY)));
    while (seeds.contains(P) == true) {
      P = new Point(int(random(startX, endX)), int(random(startY, endY)));
    }
    seeds.add(P);
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
  List<Point> seedsCopy = new ArrayList<Point>(seeds);

  noFill();
  strokeWeight(0.001);
  int nTimes = 150;
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

  
  strokeWeight(4);
  stroke(0);
  noFill();
  noStroke();
  fill(200);
  rect(0, 0, startX+1, height);
  rect(endX-1, 0, startX, height);
  rect(0,0,width, startY+1);
  rect(0,endY-1, width, startY);
  //rect(startX, startY, endX-startX, endY-startY, 5);



  


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
public class voronoiDiagramm {
  List<Edge> lines;
  List<Point> seeds;
  int minX, maxX, minY, maxY;

  public voronoiDiagramm(List<Point> _seeds, int _minX, int _maxX, int _minY, int _maxY) {
    seeds = _seeds;
    minX = _minX;
    maxX = _maxX;
    minY = _minY;
    maxY = _maxY;
    lines = calculate();
  }

  public List<Edge> calculate() {
    List<Edge> voronoi = new ArrayList<Edge>();
    List<Point> convexHull = new ArrayList<Point>();
    List<Triangle> triangulation = new ArrayList<Triangle>(new delaunayTriangulation(seeds).triangles);
    for (Triangle triangle:triangulation) {
      for (Edge edge:triangle.edges()) {
        List<Triangle> withouCurrent = new ArrayList<Triangle>(triangulation);
        withouCurrent.remove(triangle);
        if (edge.sharesEdges(withouCurrent) == false) {
          convexHull.add(edge.A);
          convexHull.add(edge.B);
        }
      }
    }
    
    
    List<Point> mirroredSeeds = new ArrayList<Point>();
    for (Point seed:convexHull) {
      mirroredSeeds.add(new Point(maxX*2-seed.x, seed.y));
      mirroredSeeds.add(new Point(minX*2-seed.x, seed.y));
      mirroredSeeds.add(new Point(seed.x, maxY*2-seed.y));
      mirroredSeeds.add(new Point(seed.x, minY*2-seed.y));
    }
    mirroredSeeds.addAll(seeds);
    
   
    List<Triangle> newTriangulation = new ArrayList<Triangle>(new delaunayTriangulation(mirroredSeeds).triangles);
   
    // conects all circumcenters with the ones of ajacent triangles
    for (Triangle triangle1 : newTriangulation) {
      for (Edge edge : triangle1.edges()) {
        for (Triangle triangle2 : newTriangulation) {
          if (edge.sharesEdge(triangle2) && triangle1 != triangle2) {
            Point circum_center1 = triangle1.circumcircle().C;
            Point circum_center2 = triangle2.circumcircle().C;
            voronoi.add(new Edge(circum_center1, circum_center2));
          }
        }
      }
    }
    // loop trough all edges and cut them so they dont stand out of the border
    List<Edge> voronoiCut = new ArrayList<Edge>();
    for (Edge edge : voronoi) {
      if (edge.A.x>=minX && edge.A.x<=maxX && edge.A.y>=minY && edge.A.y<=maxY && edge.B.x>=minX && edge.B.x<=maxX && edge.B.y>=minY && edge.B.y<=maxY) {
        voronoiCut.add(edge);
      } else {
        Point oP;
        Point iP;
        Point onBorder;
        if (edge.A.x >= minX && edge.A.x <= maxX && edge.A.y >= minY && edge.A.y <= maxY) {
          iP = edge.A;
          oP = edge.B;
        } else if (edge.B.x >= minX && edge.B.x <= maxX && edge.B.y >= minY && edge.B.y <= maxY) {
          iP = edge.B;
          oP = edge.A;
        } else {
          continue;
        }

        float t = (maxX-oP.x)/(oP.x-iP.x);
        float y = oP.y+t*(oP.y-iP.y);
        if (y >= minY && y<=maxY && oP.x>maxX) {
          onBorder = new Point(maxX, y);
          voronoiCut.add(new Edge(iP, onBorder));
          continue;
        }
        t = (minX-oP.x)/(oP.x-iP.x);
        y = oP.y+t*(oP.y-iP.y);
        if (y >= minY && y<=maxY && oP.x<minX) {
          onBorder = new Point(minX, y);
          voronoiCut.add(new Edge(iP, onBorder));
          continue;
        }
        float s = (maxY-oP.y)/(oP.y-iP.y);
        float x = oP.x+s*(oP.x-iP.x);
        if (x >= minX && x<=maxX && oP.y>maxY) {
          onBorder = new Point(x, maxY);
          voronoiCut.add(new Edge(iP, onBorder));
          continue;
        }
        s = (minY-oP.y)/(oP.y-iP.y);
        x = oP.x+s*(oP.x-iP.x);
        if (x >= minX && x<=maxX && oP.y<minY) {
          onBorder = new Point(x, minY);
          voronoiCut.add(new Edge(iP, onBorder));
          continue;
        }
      }
    }

    return voronoiCut;
  }
}

public class delaunayTriangulation {
  public List<Point> seeds;
  public List<Triangle> triangles;

  public delaunayTriangulation(List<Point> _seeds) {
    seeds = _seeds;
    triangles = calculate();
  }

  private List<Triangle> calculate() {
    Triangle superTriangle;
    List<Triangle> triangulation = new ArrayList<Triangle>();
    // adds the super triangle to the list of triangles (points: (-100,-100), (100,-100), (0,100))
    superTriangle = new Triangle(new Point(-100, -100), new Point(100, -100), new Point(0, 100));
    triangulation.add(superTriangle);

    // removes duplicate seeds that may have been created by the user
    seeds = removeDuplicateseeds(seeds);
  

    // scales all the seeds so they are between 0 and 1

    float biggestX = 1000;
    float biggestY = 1000;
    float smallestY = -1;
    float smallestX = -1;
    for (Point seed:seeds) {
     if (seed.x > biggestX) {
        biggestX = seed.x;
      }
     if (seed.x < smallestX) {
        smallestX = seed.x;
      }
     if (seed.y > biggestY) {
        biggestY = seed.y;
      }
     if (seed.y < smallestY) {
        smallestY = seed.y;
      }
      
    }
    float scale;
    if ((biggestX-smallestX) > (biggestY-smallestX)) {
      scale = biggestX;
    } else {
      scale = biggestY;
    }
        List<Point> scaledseeds = new ArrayList<Point>();
    for (Point seed : seeds) {
      scaledseeds.add(new Point((seed.x-smallestX)/scale, (seed.y-smallestY)/scale));
    }

    // loops through all the seeds
    for (Point seed : scaledseeds) {
      // adds all triangles where the seed is inside of the circumcenter to a list of bad triangles
      List<Triangle> badTriangles = new ArrayList<Triangle>();
      for (Triangle triangle : triangulation) {
        if (triangle.inCircumcircle(seed)) {
          badTriangles.add(triangle);
        }
      }
      // finds the outside edges of the bad triangles and adds them to a list of edges
      List<Edge> outsideEdges = new ArrayList<Edge>();
      for (Triangle triangle : badTriangles) {
        for (Edge edge : triangle.edges()) {
          List<Triangle> badTrianglesWithouCurrent = new ArrayList<Triangle>(badTriangles);
          badTrianglesWithouCurrent.remove(triangle);
          if (edge.sharesEdges(badTrianglesWithouCurrent) == false) {
            outsideEdges.add(edge);
          }
        }
      }
      // remove all bad triangles from the triangulation
      for (Triangle triangle : badTriangles) {
        triangulation.remove(triangle);
      }
      // adds triangles from outside edges of the bad triangles with the current seed toa list of new triangles
      List<Triangle> newTriangles = new ArrayList<Triangle>();
      for (Edge edge : outsideEdges) {
        newTriangles.add(edge.toTriangle(seed));
      }
      // loops through all the newly created triangles and checks if all ajacent triangles meet the criteria of the delaunay triangulation.
      // If not it will add the wrong ones to the oldTriangles list and flipp the common edge of the wrong triangles
      // The new flipped triangles will be added to a list
      List<Triangle> flippedTriangles = new ArrayList<Triangle>();
      List<Triangle> oldTriangles = new ArrayList<Triangle>();
      for (Triangle triangle1 : newTriangles) {
        for (Triangle triangle2 : newTriangles) {
          if (triangle1 != triangle2 && triangle1.adjacent(triangle2) && triangle1.flippingBeneficial(triangle2)) {
            oldTriangles.add(triangle1);
            oldTriangles.add(triangle2);
            flippedTriangles.addAll(triangle1.flipTriangles(triangle2));
          }
        }
      }
      // removes the old triangles that got flipped from the new triangles
      for (Triangle triangle : oldTriangles) {
        newTriangles.remove(triangle);
      }
      // adds the flipped triangles to the new triangles
      for (Triangle triangle : flippedTriangles) {
        newTriangles.add(triangle);
      }
      // add all the new triangles to the triangulation
      for (Triangle triangle : newTriangles) {
        triangulation.add(triangle);
      }
    }

    // removes all triangles that share a vertex with the super Triangle from the triangulation
    List<Triangle> shareVertexWithSuper = new ArrayList<Triangle>();
    for (Triangle triangle : triangulation) {
      if (triangle.sharesVertex(superTriangle) == false) {
        shareVertexWithSuper.add(new Triangle(new Point(triangle.A.x*scale+smallestX, triangle.A.y*scale + smallestY), new Point(triangle.B.x*scale + smallestX, triangle.B.y*scale + smallestY), new Point(triangle.C.x*scale + smallestX, triangle.C.y*scale + smallestY)));
      }
    }
    for (Triangle triangle : shareVertexWithSuper) {
      triangulation.remove(triangle);
    }
    return shareVertexWithSuper;
  }
}

// Point class
public class Point {
  float x, y;
  public Point(float X, float Y) {
    x = X;
    y = Y;
  }
  public boolean same(Point compare) {
    if (compare.x == this.x && compare.y == this.y) {
      return true;
    }
    return false;
  }
}


// Circle class
public class Circle {
  Point C;
  float r;
  public Circle(Point _C, float _r) {
    C = _C;
    r = _r;
  }
}


// Edge class
public class Edge {
  Point A, B;
  public Edge(Point a, Point b) {
    A = a;
    B = b;
  }
  // returns true if the edge shares a edge with the Triangle passed in
  private boolean sharesEdge(Triangle T) {
    for (Edge edge : T.edges()) {
      if (this.same(edge)) {
        return true;
      }
    }
    return false;
  }
  // returns true if the edge shares a edge with one or more Triangles in the list
  public boolean sharesEdges(List<Triangle> triangles) {
    for (Triangle triangle : triangles) {
      if (sharesEdge(triangle) == true)
        return true;
    }
    return false;
  }
  // creates a triangle with the edge and a passed in seed
  public Triangle toTriangle(Point P) {
    return new Triangle(A, B, P);
  }
  public boolean same(Edge compare) {
    if ((this.A.same(compare.A) && this.B.same(compare.B)) || (this.A.same(compare.B) && this.B.same(compare.A))) {
      return true;
    }
    return false;
  }

  public Edge perpendicularBisector() {
    Point mid = new Point((A.x+B.x)/2, (A.y+B.y)/2);
    Point normal = new Point(-(A.y-B.y), (A.x-B.x));

    return new Edge(mid, new Point(mid.x+normal.x, mid.y+normal.y));
  }
  public Point midseed() {
    return new Point((this.A.x+this.B.x)/2, (this.A.y+this.B.y)/2);
  }

  public float distance() {
    return dist(A.x, A.y, B.x, B.y);
  }
}

// triangle class
public class Triangle {
  Point A, B, C;
  public Triangle(Point p1, Point p2, Point p3) {
    A = p1;
    B = p2;
    C = p3;
  }
  // calculates the x,y and radius of the triangle
  private Circle circumcircle() {
    Point mid_a = new Point((B.x+C.x)/2, (B.y+C.y)/2);
    Point mid_b = new Point((A.x+C.x)/2, (A.y+C.y)/2);

    Point n_a = new Point(-(B.y-C.y), (B.x-C.x));
    Point n_b = new Point((A.y-C.y), -(A.x-C.x));

    float t = (mid_b.y*n_a.x - mid_a.y*n_a.x - mid_b.x*n_a.y + mid_a.x*n_a.y)/(n_b.x*n_a.y- n_b.y*n_a.x);

    Point C = new Point(mid_b.x + t*n_b.x, mid_b.y + t*n_b.y);
    return new Circle(C, dist(C.x, C.y, A.x, A.y));
  }
  // returnss if a seed is in the circumcircle
  public boolean inCircumcircle(Point P) {

    Circle circum = circumcircle();
    if (dist(P.x, P.y, circum.C.x, circum.C.y) <= circum.r) {
      return true;
    }
    return false;
  }
  // returns a the list of edges of the triangle
  public List<Edge> edges() {
    List<Edge> Edges = new ArrayList<Edge>();
    Edges.add(new Edge(A, B));
    Edges.add(new Edge(B, C));
    Edges.add(new Edge(C, A));
    return Edges;
  }
  // returns true if the triangle shares one or more vertex with the triangle passed in
  public boolean sharesVertex(Triangle other) {
    for (Point seed1 : this.vertices()) {
      for (Point seed2 : other.vertices()) {
        if (seed1.same(seed2)) {
          return true;
        }
      }
    }
    return false;
  }
  // returns a list of all vertices
  private List<Point> vertices() {
    List<Point> seeds = new ArrayList<Point>();
    seeds.add(A);
    seeds.add(B);
    seeds.add(C);
    return seeds;
  }

  private Edge commonEdge(Triangle T) {
    for (Edge edge1 : this.edges()) {
      for (Edge edge2 : T.edges()) {
        if (edge1.same(edge2)) {
          return edge1;
        }
      }
    }
    return new Edge(new Point(0, 0), new Point(0, 0));
  }
  public Point oppositeVertex(Edge edge) {
    if (new Edge(A, B).same(edge)) {
      return C;
    } else if (new Edge(B, C).same(edge)) {
      return A;
    } else if (new Edge(C, A).same(edge)) {
      return B;
    } else {
      return new Point(0, 0);
    }
  }


  public boolean flippingBeneficial(Triangle T) {
    Edge common = this.commonEdge(T);
    if (this.inCircumcircle(T.oppositeVertex(common))) {
      return true;
    }
    if (T.inCircumcircle(this.oppositeVertex(common))) {
      return true;
    }
    return false;
  }

  public List<Triangle> flipTriangles(Triangle T) {
    List<Triangle> triangles = new ArrayList<Triangle>();
    Edge common = this.commonEdge(T);
    Point opposite1 = this.oppositeVertex(common);
    Point opposite2 = T.oppositeVertex(common);

    triangles.add(new Triangle(opposite1, opposite2, common.A));
    triangles.add(new Triangle(opposite1, opposite2, common.B));

    return triangles;
  }
  public boolean adjacent(Triangle T) {
    for (Edge edge : this.edges()) {
      if (edge.sharesEdge(T)) {
        return true;
      }
    }
    return false;
  }

  public boolean inside(Point P) {
    float detT = (B.y - C.y) * (A.x - C.x) + (C.x - B.x) * (A.y - C.y);
    float alpha = ((B.y - C.y) * (P.x - C.x) + (C.x - B.x) * (P.y - C.y)) / detT;
    float beta = ((C.y - A.y) * (P.x - C.x) + (A.x - C.x) * (P.y - C.y)) / detT;
    float gamma = 1.0 - alpha - beta;

    return alpha >= 0 && beta >= 0 && gamma >= 0;
  }
}


List<Point> removeDuplicateseeds(List<Point> duplicates) {
  List<Point> no_duplicates = new ArrayList<Point>();

  for (Point seed1 : duplicates) {
    boolean exists = false;
    for (Point seed2 : no_duplicates) {
      if (seed1.same(seed2)) {
        exists = true;
      }
    }
    if (exists == false) {
      no_duplicates.add(seed1);
    }
  }
  return no_duplicates;
}
