public class delaunayTriangulation {
  public List<Point> seeds;
  public List<Triangle> triangles;

  public delaunayTriangulation(List<Point> _seeds) {
    seeds = _seeds;
    calculate();
  }

  private void calculate() {
    Triangle superTriangle;
    List<Triangle> triangulation = new ArrayList<Triangle>();
    // adds the super triangle to the list of triangles (points: (-100,-100), (100,-100), (0,100))
    superTriangle = new Triangle(new Point(-100, -100), new Point(100, -100), new Point(0, 100));
    triangulation.add(superTriangle);

    // removes duplicate seeds that may have been created by the user
    seeds = removeDuplicateseeds(seeds);
  

    // scales all the seeds so they are between 0 and 1

    float biggestX = seeds.get(0).x;
    float biggestY = seeds.get(0).y;
    float smallestX = seeds.get(0).x;
    float smallestY = seeds.get(0).y;
    for (Point seed:seeds) {
     if (seed.x > biggestX) { biggestX = seed.x; }
     if (seed.x < smallestX) { smallestX = seed.x; }
     if (seed.y > biggestY) { biggestY = seed.y; }
     if (seed.y < smallestY) { smallestY = seed.y; }
      
    }
    float scale = max(biggestX, biggestY);

    List<Point> scaledseeds = new ArrayList<Point>();
    for (Point seed : seeds) {
      scaledseeds.add(new Point(seed.x/scale, seed.y/scale));
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
      List<Line> outsideEdges = new ArrayList<Line>();
      for (Triangle triangle : badTriangles) {
        for (Line edge : triangle.edges()) {
          List<Triangle> badTrianglesWithouCurrent = new ArrayList<Triangle>(badTriangles);
          badTrianglesWithouCurrent.remove(triangle);
          if (!edge.sharesEdges(badTrianglesWithouCurrent)) {
            outsideEdges.add(edge);
          }
        }
      }
      // remove all bad triangles from the triangulation
      triangulation.removeAll(badTriangles);
      // adds triangles from outside edges of the bad triangles with the current seed toa list of new triangles
      List<Triangle> newTriangles = new ArrayList<Triangle>();
      for (Line edge : outsideEdges) {
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
      newTriangles.removeAll(oldTriangles);
      // adds the flipped triangles to the new triangles
      newTriangles.addAll(flippedTriangles);
      // add all the new triangles to the triangulation
      triangulation.addAll(newTriangles);
    }

    // removes all triangles that share a vertex with the super Triangle from the triangulation
    List<Triangle> shareVertexWithSuper = new ArrayList<Triangle>();
    for (Triangle triangle : triangulation) {
      if (triangle.sharesVertex(superTriangle)) {
        shareVertexWithSuper.add(triangle);
      }
    }
    triangulation.removeAll(shareVertexWithSuper);
    
    for (Triangle triangle: triangulation) {
      triangulation.set(triangulation.indexOf(triangle), new Triangle(new Point(triangle.A.x*scale, triangle.A.y*scale), new Point(triangle.B.x*scale, triangle.B.y*scale), new Point(triangle.C.x*scale, triangle.C.y*scale)));
    }
    this.triangles = triangulation;
  }
}
