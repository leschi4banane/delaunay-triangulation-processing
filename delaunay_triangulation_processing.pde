import java.util.List;  

int n_points = 4;
List<Point> points = new ArrayList<Point>();  
List<Triangle> triangles = new ArrayList<Triangle>();  

Triangle super_triangle;

void setup() {
  size(500,500);
  noLoop();
  smooth();
  noFill();
  
  super_triangle = smallestTriangleOutsideOfBox(width/2, height/2, width, height);
  triangles.add(super_triangle);
  
  for (int i = 0; i<n_points; i++) {
    Point P = new Point(int(random(width)), int(random(height)));
    points.add(P);
    fill(0,0,255);
    noStroke();
    circle(P.x, P.y, 10);
    stroke(color(0,0,0,0));
  }
}


void draw() {
  background(200);
  triangles.clear();
  triangles.add(super_triangle);
  
  for (Point point:points)   {
    fill(0,0,255);
    noStroke();
    circle(point.x, point.y, 10);
    stroke(0);
    noFill();
    List<Triangle> bad_triangles = new ArrayList<Triangle>(); 
    for (Triangle triangle:triangles) { 
      if (triangle.inCircumcircle(point)) {
        bad_triangles.add(triangle);
      }
    }
    
    List<Edge> poligons = new ArrayList<Edge>(); 
    for (Triangle triangle:bad_triangles) { 
      for (Edge edge:triangle.edges()) {
        List<Triangle> without_current = new ArrayList<Triangle>();
        without_current.addAll(bad_triangles);
        without_current.remove(triangle);
        if (edge.sharesEdges(without_current) == false) { 
          poligons.add(edge);
        }
      }
    }
    
    for (Triangle triangle:bad_triangles) { 
      triangles.remove(triangle);
    }
   
    List<Triangle> new_triangles = new ArrayList<Triangle>();
    for (Edge edge:poligons) { 
      new_triangles.add(edge.toTriangle(point));
    }
    List<Triangle> flipped_triangles = new ArrayList<Triangle>();
    List<Triangle> old_triangles = new ArrayList<Triangle>();
    
    for (Triangle triangle1 : new_triangles) {
      for (Triangle triangle2 : new_triangles) {
        if (triangle1 != triangle2) {
        if (triangle1.adjacent(triangle2)) {
          if (triangle1.flippingBeneficial(triangle2)) {
            old_triangles.add(triangle1);
            old_triangles.add(triangle2);
            flipped_triangles.addAll(triangle1.flipTriangles(triangle2));
          }

        }
        }
      }
    }
    for (Triangle triangle : old_triangles) {
      new_triangles.remove(triangle);
    }
    for (Triangle triangle : flipped_triangles) {
      new_triangles.add(triangle);
    }
    for (Triangle triangle : new_triangles) {
      triangles.add(triangle);
    }

  }


  List<Triangle> final_triangles = new ArrayList<Triangle>(); 
  for (Triangle triangle:triangles) {
    if (triangle.sharesVertex(super_triangle) == false) {
      final_triangles.add(triangle);
    }
   }
   

   for (Triangle triangle:final_triangles) {
     fill(0,0,0,0);
     triangle(triangle.A.x, triangle.A.y, triangle.B.x, triangle.B.y, triangle.C.x, triangle.C.y);
   }
}

void mousePressed() {
  points.add(new Point(mouseX, mouseY));
  redraw();
}



// Point class
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
  // creates a triangle with the edge and a passed in point
  public Triangle toTriangle(Point P) {
    return new Triangle(A, B, P);
    
  }
  public boolean same(Edge compare) {
    if ((this.A.same(compare.A) && this.B.same(compare.B)) || (this.A.same(compare.B) && this.B.same(compare.A))) {
    return true;
    }
    return false;
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
  // returnss if a Point is in the circumcircle
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
    for (Point point1:this.vertices()) {
      for (Point point2:other.vertices()) {
        if (point1.same(point2)) {
          return true;
        }
      }
    }
    return false;
  }
  // returns a list of all vertices
  private List<Point> vertices() {
    List<Point> points = new ArrayList<Point>(); 
    points.add(A);
    points.add(B);
    points.add(C);
    return points;
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
 
}


// returns the smallest triangle around a box (the screen)
Triangle smallestTriangleOutsideOfBox(float x,float y, float box_width, float box_height) {
  float s = (3*box_width+2*sqrt(3)*box_height)/3;
  Point A = new Point(-s/2 + x, box_height/2 + y);
  Point B = new Point(s/2 + x, box_height/2 + y);
  Point C = new Point(x, -(sqrt(3)/2)*s + box_height/2 + y);
  return new Triangle(A, B, C);
}
