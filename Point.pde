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
  public boolean insideBorder(int minX, int minY, int maxX, int maxY) {
    if(this.x >= minX && this.x <= maxX && this.y >= minY && this.y <= maxY) {
      return true;
    }
    return false;
  }
  public boolean onBorder(int minX, int minY, int maxX, int maxY, float tolerance) {
    if((this.x > minX*(1-tolerance) && this.x < minX*(1+tolerance)) || (this.x > maxX*(1-tolerance) && this.x < maxX*(1+tolerance)) ||  (this.y > minY*(1-tolerance) && this.y < minY*(1+tolerance)) || (this.y > maxY*(1-tolerance) && this.y < maxY*(1+tolerance))) {
      return true;
    }
    return false;
  }
}
