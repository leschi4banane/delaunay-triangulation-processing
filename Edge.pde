// Edge class
public class Line {
  Point A, B;
  public Line(Point a, Point b) {
    A = a;
    B = b;
  }
  // returns true if the edge shares a edge with the Triangle passed in
  private boolean sharesEdge(Triangle T) {
    for (Line edge : T.edges()) {
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
  public boolean same(Line compare) {
    if ((this.A.same(compare.A) && this.B.same(compare.B)) || (this.A.same(compare.B) && this.B.same(compare.A))) {
      return true;
    }
    return false;
  }

  public Line perpendicularBisector() {
    Point mid = new Point((A.x+B.x)/2, (A.y+B.y)/2);
    Point normal = new Point(-(A.y-B.y), (A.x-B.x));

    return new Line(mid, new Point(mid.x+normal.x, mid.y+normal.y));
  }
  public Point midseed() {
    return new Point((this.A.x+this.B.x)/2, (this.A.y+this.B.y)/2);
  }

  public float distance() {
    return dist(A.x, A.y, B.x, B.y);
  }
}
