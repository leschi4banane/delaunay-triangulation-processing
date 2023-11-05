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
