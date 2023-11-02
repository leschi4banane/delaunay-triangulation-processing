import java.util.List;

int n_seeds = 500;
List<Point> seeds = new ArrayList<Point>();  
List<Triangle> triangulation = new ArrayList<Triangle>();  

Triangle superTriangle;


void setup() {
  size(700,700);
  pixelDensity(2);
  noLoop();
  smooth();
  noFill();
  
  // adds the super triangle to the list of triangles (points: (-100,-100), (100,-100), (0,100))
  superTriangle = new Triangle(new Point(-100, -100), new Point(100,-100), new Point(0,100));
  triangulation.add(superTriangle);
  
  // adds n_seeds number of random seeds the the seeds list
  for (int i = 0; i<n_seeds; i++) {
    Point P = new Point(int(random(500)), int(random(500)));
    while (seeds.contains(P) == true) {
      P = new Point(int(random(500)), int(random(500)));
    }
    seeds.add(P);
  }
  
  

  
  String str = "{\"sites\":[";
  for (Point seed:seeds) {
    str = str + (int)seed.x + "," + (int)seed.y+ ",";
  }
  str = str.substring(0, str.length() - 1);
  str = str + "],\"queries\":[]}";
  println(str);
  
  redraw();
}


void draw() { //<>//
  // addedseed is true if the seed at the mouse cursor is getting shown
  // seedAdded variable represent the seed added by the cursor
  boolean addedseed = false;
  Point mouseseed = new Point(-1, -1);
  // adds a seed at the cursor to the seeds list if the mouse is pressed //<>//
  if (mousePressed) {
    mouseseed = new Point(mouseX, mouseY);
    seeds.add(mouseseed);
    addedseed = true;
  }
  // removes duplicate seeds that may have been created by the user
  seeds = removeDuplicateseeds(seeds);
  
  
  // scales all the seeds so they are between 0 and 1
  List<Point> scaledseeds = new ArrayList<Point>(); 
  int scale;
  if (width > height) {
    scale = width;
  } else {
    scale = height;
  }
  for (Point seed:seeds) {
    scaledseeds.add(new Point(seed.x/scale, seed.y/scale));
  }

  background(200);
  noFill();
  strokeWeight(3);
  stroke(0);
  rect(100,100,500,500);
  // clears the triangulation from previus calculations
  triangulation.clear();
  triangulation.add(superTriangle);
  // loops through all the seeds
  for (Point seed:scaledseeds)   {
    // adds all triangles where the seed is inside of the circumcenter to a list of bad triangles
    List<Triangle> badTriangles = new ArrayList<Triangle>(); 
    for (Triangle triangle:triangulation) { 
      if (triangle.inCircumcircle(seed)) {
        badTriangles.add(triangle);
      }
    }
    // finds the outside edges of the bad triangles and adds them to a list of edges
    List<Edge> outsideEdges = new ArrayList<Edge>(); 
    for (Triangle triangle:badTriangles) { 
      for (Edge edge:triangle.edges()) {
        List<Triangle> badTrianglesWithouCurrent = new ArrayList<Triangle>(badTriangles);
        badTrianglesWithouCurrent.remove(triangle);
        if (edge.sharesEdges(badTrianglesWithouCurrent) == false) { 
          outsideEdges.add(edge);
        }
      }
    }
    // remove all bad triangles from the triangulation
    for (Triangle triangle:badTriangles) { 
      triangulation.remove(triangle);
    }
   // adds triangles from outside edges of the bad triangles with the current seed toa list of new triangles
    List<Triangle> newTriangles = new ArrayList<Triangle>();
    for (Edge edge:outsideEdges) { 
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
  for (Triangle triangle:triangulation) {
    if (triangle.sharesVertex(superTriangle) == false) {
      shareVertexWithSuper.add(new Triangle(new Point(triangle.A.x*scale, triangle.A.y*scale), new Point(triangle.B.x*scale, triangle.B.y*scale), new Point(triangle.C.x*scale, triangle.C.y*scale)));
    }
   }
   for (Triangle triangle:shareVertexWithSuper) {
     triangulation.remove(triangle);
   }
   
   
   
   // draw the triangulation to the screen
   
   noStroke();
   for (Triangle triangle:shareVertexWithSuper) {
     strokeWeight(1);
     noFill();
     stroke(0,0,255);
     //triangle(triangle.A.x+100, triangle.A.y+100, triangle.B.x+100, triangle.B.y+100, triangle.C.x+100, triangle.C.y+100);
   }
   
   // draws the seeds to the screen
   for (Point seed:seeds) {
     fill(0,0,255);
     noStroke();
     // circle(seed.x+100, seed.y+100, 5);
   }
   
   //voronoi
    List<Edge> voronoi = new ArrayList<Edge>(); 
   
   for (Triangle triangle1: shareVertexWithSuper) {
     for (Edge edge: triangle1.edges()) {
       boolean sharesEdge = false;
       for (Triangle triangle2: shareVertexWithSuper) {
         if (edge.sharesEdge(triangle2) && triangle1 != triangle2) {
           sharesEdge = true;
           Point circum_center1 = triangle1.circumcircle().C;
           Point circum_center2 = triangle2.circumcircle().C;
           voronoi.add(new Edge(circum_center1, circum_center2));
         }
       }
       
       if (sharesEdge == false) {
        Point c = triangle1.circumcircle().C;
        Point mid = new Point((edge.A.x+edge.B.x)/2, (edge.A.y+edge.B.y)/2);
        Point opposite = triangle1.oppositeVertex(edge);
        Point m;
        if (edge.distance() > new Edge(opposite, edge.A).distance() && edge.distance() > new Edge(opposite, edge.B).distance() && (triangle1.inside(c) == false)) {
          m = new Point(c.x-(mid.x-c.x)*1, c.y-(mid.y-c.y)*1);
        } else {
          m = new Point(c.x+(mid.x-c.x)*1, c.y+(mid.y-c.y)*1);
        }
        if (c.x >= 0 && c.x<=500 && c.y >= 0 && c.y <= 500) {
          Point onBorder = new Point(0,0);
          float t = (500-m.x)/(m.x-c.x);
          if (t >= 0) {
            float y = m.y+t*(m.y-c.y);
              if (y >= 0 && y<=500) {
                onBorder = new Point(500, y);
            }
          }
          else {
            t = (0-m.x)/(m.x-c.x);
            float y = m.y+t*(m.y-c.y);
            if (y >= 0 && y<=500) {
                onBorder = new Point(0, y);
            }
          }
          float s = (500-m.y)/(m.y-c.y);
          if (s >= 0) {
            float x = m.x+s*(m.x-c.x);
              if (x >= 0 && x<=500) {
                onBorder = new Point(x, 500);
              }
          }
          else {
            s = (0-m.y)/(m.y-c.y);
            float x = m.x+s*(m.x-c.x);
            if (x >= 0 && x<=500) {
                onBorder = new Point(x, 0);
            }
          }
          voronoi.add(new Edge(c, onBorder));
        }
       }
     }
    }
    List<Edge> voronoiCut = new ArrayList<Edge>(); 
    for (Edge edge:voronoi) {
      if (edge.A.x>=0 && edge.A.x<=500 && edge.A.y>=0 && edge.A.y<=500 && edge.B.x>=0 && edge.B.x<=500 && edge.B.y>=0 && edge.B.y<=500) {
      voronoiCut.add(edge);
      }
      else {
        Point oP;
        Point iP;
        Point onBorder;
        if (edge.A.x >= 0 && edge.A.x <= 500 && edge.A.y >= 0 && edge.A.y <= 500) {
          iP = edge.A;
          oP = edge.B;
        } 
        else if (edge.B.x >= 0 && edge.B.x <= 500 && edge.B.y >= 0 && edge.B.y <= 500) {
          iP = edge.B;
          oP = edge.A;
        }
        else {
          continue;
        }

        float t = (500-oP.x)/(oP.x-iP.x);
        float y = oP.y+t*(oP.y-iP.y);
        if (y >= 0 && y<=500 && oP.x>500) {
          onBorder = new Point(500, y);
          voronoiCut.add(new Edge(iP, onBorder));
          continue;
        }
        t = (0-oP.x)/(oP.x-iP.x);
        y = oP.y+t*(oP.y-iP.y);
        if (y >= 0 && y<=500 && oP.x<0) {
          onBorder = new Point(0, y);
          voronoiCut.add(new Edge(iP, onBorder));
          continue;
        }
        float s = (500-oP.y)/(oP.y-iP.y);
        float x = oP.x+s*(oP.x-iP.x);
        if (x >= 0 && x<=500 && oP.y>500) {
          onBorder = new Point(x, 500);
          voronoiCut.add(new Edge(iP, onBorder));
          continue;
        }
        s = (0-oP.y)/(oP.y-iP.y);
        x = oP.x+s*(oP.x-iP.x);
        if (x >= 0 && x<=500 && oP.y<0) {
          onBorder = new Point(x, 0);
          voronoiCut.add(new Edge(iP, onBorder));
          continue;
        }
      }
    }
    
    
    
    for (Edge edge:voronoiCut) {
      stroke(0);
      strokeWeight(3);
      line(edge.A.x+100, edge.A.y+100, edge.B.x+100, edge.B.y+100);
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



// seed class
public class Point {
  float x, y;
   public Point(float X,float Y) {
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
public class Circle  {
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
       for (Edge edge:T.edges()) {
         if (this.same(edge)) {
           return true;
         }
       }
       return false;
    }
  // returns true if the edge shares a edge with one or more Triangles in the list
  public boolean sharesEdges(List<Triangle> triangles) {
    for (Triangle triangle:triangles) {
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
    return new Circle(C , dist(C.x, C.y, A.x, A.y));

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
    for (Point seed1:this.vertices()) {
      for (Point seed2:other.vertices()) {
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
    for (Edge edge1:this.edges()) {
      for (Edge edge2:T.edges()) {
        if (edge1.same(edge2)) {
          return edge1;
        }
      }
    }
    return new Edge(new Point(0,0), new Point(0,0));
  }
public Point oppositeVertex(Edge edge) {
    if (new Edge(A,B).same(edge)) { return C; }
    else if (new Edge(B,C).same(edge)) { return A; }
    else if (new Edge(C,A).same(edge)) { return B; }
    else { return new Point(0, 0);}
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
    for (Edge edge:this.edges()) {
      if(edge.sharesEdge(T)) {
        return true;
      }
    }
    return false;
  }
  
  private float area() {
      return abs((A.x * (B.y - C.y) + B.x * (C.y - A.y) + 
      C.x * (A.y - B.y)) / 2.0);
    
  }
  
  public boolean inside(Point P) {
    float detT = (B.y - C.y) * (A.x - C.x) + (C.x - B.x) * (A.y - C.y);
    float alpha = ((B.y - C.y) * (P.x - C.x) + (C.x - B.x) * (P.y - C.y)) / detT;
    float beta = ((C.y - A.y) * (P.x - C.x) + (A.x - C.x) * (P.y - C.y)) / detT;
    float gamma = 1.0 - alpha - beta;

    return alpha >= 0 && beta >= 0 && gamma >= 0;
}
 
}


// returns the smallest triangle around a box (the screen)
Triangle smallestTriangleOutsideOfBox(float x,float y, float box_width, float box_height) {
  float s = (3*box_width+2*sqrt(3)*box_height)/3;
  Point A = new Point(-s/2 + x, box_height/2 + y);
  Point B = new Point(s/2 + x, box_height/2 + y);
  Point C = new Point(x, -(sqrt(3)/2)*s + box_height/2 + y);
  return new Triangle(A, B, C);
}

List<Point> removeDuplicateseeds(List<Point> duplicates) {
  List<Point> no_duplicates = new ArrayList<Point>();
  
  for (Point seed1:duplicates) {
    boolean exists = false;
    for (Point seed2:no_duplicates) {
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

void drawDashedLine(float x1, float y1, float x2, float y2, float dashLength) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float distance = dist(x1, y1, x2, y2);
  float dashCount = distance / dashLength;
  float xStep = dx / dashCount;
  float yStep = dy / dashCount;
  
  boolean drawLine = true;
  
  for (int i = 0; i < distance-dashLength; i += dashLength) {
    if (drawLine) {
      line(x1, y1, x1 + xStep, y1 + yStep);
    }
    x1 += xStep;
    y1 += yStep;
    drawLine = !drawLine;
  }
}
