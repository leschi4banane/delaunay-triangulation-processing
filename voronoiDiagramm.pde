public class voronoiDiagramm {
  List<Line> lines;
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
    List<Line> voronoi = new ArrayList<Line>();
    // calculates all seeds in the convex hull
    List<Point> convexHull = new ArrayList<Point>();
    List<Triangle> firstTriangulation = new ArrayList<Triangle>(new delaunayTriangulation(seeds).triangles);
    for (Triangle triangle:firstTriangulation) {
      for (Line edge:triangle.edges()) {
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
      stroke(0,0,0,50);
      // triangle(triangle1.A.x, triangle1.A.y, triangle1.B.x, triangle1.B.y, triangle1.C.x, triangle1.C.y);
      stroke(0);
      for (Line edge : triangle1.edges()) {
        for (Triangle triangle2 : triangulation) {
          if (edge.sharesEdge(triangle2) && triangle1 != triangle2) {
            voronoi.add(new Line(triangle1.circumcircle().C, triangle2.circumcircle().C));
          }
        }
      }
    }
    List<Line> voronoiCut = new ArrayList<Line>();
    for (Line edge:voronoi) {
      if (edge.A.onBorder(minX, minY, maxX, maxY, 0.00001) && edge.B.onBorder(minX, minY, maxX, maxY, 0.00001)) {
        continue;
      }
      if (!edge.A.insideBorder(minX, minY, maxX, maxY) && !edge.B.insideBorder(minX, minY, maxX, maxY)) {
        continue;
      }
      else if((edge.A.onBorder(minX, minY, maxX, maxY, 0.00001) && !edge.B.insideBorder(minX, minY, maxX, maxY)) || (edge.B.onBorder(minX, minY, maxX, maxY, 0.00001) && !edge.A.insideBorder(minX, minY, maxX, maxY))) {
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
        voronoiCut.add(new Line(iP, onBorder));
        
      }
      else {
        voronoiCut.add(edge);
      }
    }
    this.lines = voronoiCut;
  }
}
