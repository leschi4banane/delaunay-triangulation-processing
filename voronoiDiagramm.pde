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
    calculate();
  }

  private void calculate() {
    List<Edge> voronoi = new ArrayList<Edge>();
    // calculates all seeds in the convex hull
    List<Point> convexHull = new ArrayList<Point>();
    List<Triangle> firstTriangulation = new ArrayList<Triangle>(new delaunayTriangulation(seeds).triangles);
    for (Triangle triangle:firstTriangulation) {
      for (Edge edge:triangle.edges()) {
        List<Triangle> withouCurrent = new ArrayList<Triangle>(firstTriangulation);
        withouCurrent.remove(triangle);
        if (!edge.sharesEdges(withouCurrent)) {
          convexHull.add(edge.A);
          convexHull.add(edge.B);
        }
      }
    }
    
    // mirrors all seeds in the convex hull to the outside of the existing seeds
    List<Point> mirroredSeeds = new ArrayList<Point>();
    for (Point seed:convexHull) {
      mirroredSeeds.add(new Point(maxX*2-seed.x, seed.y));
      mirroredSeeds.add(new Point(minX*2-seed.x, seed.y));
      mirroredSeeds.add(new Point(seed.x, maxY*2-seed.y));
      mirroredSeeds.add(new Point(seed.x, minY*2-seed.y));
    }
    mirroredSeeds.addAll(seeds);
    
   
    List<Triangle> triangulation = new ArrayList<Triangle>(new delaunayTriangulation(mirroredSeeds).triangles);
   
    // conects all circumcenters with the ones of ajacent triangles
    for (Triangle triangle1 : triangulation) {
      for (Edge edge : triangle1.edges()) {
        for (Triangle triangle2 : triangulation) {
          if (edge.sharesEdge(triangle2) && triangle1 != triangle2) {
            voronoi.add(new Edge(triangle1.circumcircle().C, triangle2.circumcircle().C));
          }
        }
      }
    }
    List<Edge> voronoiCut = new ArrayList<Edge>();
    for (Edge edge:voronoi) {
      if ((edge.A.x == minX && edge.B.x == minX) || (edge.A.x == maxX && edge.B.x == maxX) || (edge.A.y == minY && edge.B.y == minY) || (edge.A.y == maxY && edge.B.y == maxY)) {
        continue;
      }
      else if (!edge.A.insideBorder(minX, minY, maxX, maxY) && !edge.B.insideBorder(minX, minY, maxX, maxY)) {
        continue;
      }
      else if((edge.A.onBorder(minX, minY, maxX, maxY) && !edge.B.insideBorder(minX, minY, maxX, maxY)) || (edge.B.onBorder(minX, minY, maxX, maxY) && !edge.A.insideBorder(minX, minY, maxX, maxY))) {
        continue;
      }
      else if (!edge.A.insideBorder(minX, minY, maxX, maxY) || !edge.B.insideBorder(minX, minY, maxX, maxY)) {
        // iP = inside Point , oP = outside Point, onBorder = new point that is on border
        Point oP, iP, onBorder;
        if (edge.A.insideBorder(minX, minY, maxX, maxY)) {
          iP = edge.A;
          oP = edge.B;
        }
        else {
          iP = edge.B;
          oP = edge.A;
        }
    
        float yMaxX = oP.y + (maxX - oP.x)/(oP.x - iP.x) * (oP.y - iP.y);
        float yMinX = oP.y + (minX - oP.x)/(oP.x - iP.x) * (oP.y - iP.y);
        float xMaxY = oP.x + (maxY - oP.y)/(oP.y - iP.y) * (oP.x - iP.x);
        float xMinY = oP.x + (minY - oP.y)/(oP.y - iP.y) * (oP.x - iP.x);
        
        if (yMaxX >= minY && yMaxX <= maxY && oP.x > maxX) {
          onBorder = new Point(maxX, yMaxX);
        }
        else if(yMinX >= minY && yMinX<=maxY && oP.x<minX) {
          onBorder = new Point(minX, yMinX);
        }
        else if (xMaxY>= minX && xMaxY<=maxX && oP.y>maxY) {
          onBorder = new Point(xMaxY, maxY);
        }
        else if (xMinY >= minX && xMinY<=maxX && oP.y<minY) {
          onBorder = new Point(xMinY, minY);
        }
        else {
          continue; 
        }
        voronoiCut.add(new Edge(iP, onBorder));
        
      }
      else {
        voronoiCut.add(edge);
      }
    }
    this.lines = voronoiCut;
  }
}
