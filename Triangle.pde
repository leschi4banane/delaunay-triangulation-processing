// triangle class
public class Triangle {
  public Point A, B, C;
  private Circle circum;
  public Triangle(Point p1, Point p2, Point p3) {
    A = p1;
    B = p2;
    C = p3;
  }
  // calculates the x,y and radius of the triangle
  private Circle circumcircle() {
    if (circum == null) {
      Point mid_a = new Point((B.x+C.x)/2, (B.y+C.y)/2);
      Point mid_b = new Point((A.x+C.x)/2, (A.y+C.y)/2);

      Point n_a = new Point(-(B.y-C.y), (B.x-C.x));
      Point n_b = new Point((A.y-C.y), -(A.x-C.x));

      float t = (mid_b.y*n_a.x - mid_a.y*n_a.x - mid_b.x*n_a.y + mid_a.x*n_a.y)/(n_b.x*n_a.y- n_b.y*n_a.x);

      Point C = new Point(mid_b.x + t*n_b.x, mid_b.y + t*n_b.y);
      return new Circle(C, dist(C.x, C.y, A.x, A.y));
    }
    else {
      return circum;
    }
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
  public List<Line> edges() {
    List<Line> Edges = new ArrayList<Line>();
    Edges.add(new Line(A, B));
    Edges.add(new Line(B, C));
    Edges.add(new Line(C, A));
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

  private Line commonEdge(Triangle T) {
    for (Line edge1 : this.edges()) {
      for (Line edge2 : T.edges()) {
        if (edge1.same(edge2)) {
          return edge1;
        }
      }
    }
    return new Line(new Point(0, 0), new Point(0, 0));
  }
  public Point oppositeVertex(Line edge) {
    if (new Line(A, B).same(edge)) {
      return C;
    } else if (new Line(B, C).same(edge)) {
      return A;
    } else if (new Line(C, A).same(edge)) {
      return B;
    } else {
      return null;
    }
  }

  public boolean flippingBeneficial(Triangle T) {
    Line common = this.commonEdge(T);
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
    Line common = this.commonEdge(T);
    Point opposite1 = this.oppositeVertex(common);
    Point opposite2 = T.oppositeVertex(common);

    triangles.add(new Triangle(opposite1, opposite2, common.A));
    triangles.add(new Triangle(opposite1, opposite2, common.B));

    return triangles;
  }
  public boolean adjacent(Triangle T) {
    for (Line edge : this.edges()) {
      if (edge.sharesEdge(T)) {
        return true;
      }
    }
    return false;
  }
}
