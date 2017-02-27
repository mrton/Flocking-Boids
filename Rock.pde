import java.util.Random;
class Rock {
  PVector location;
  float radius;
  color red = color(201,91,113);
  color blue = color(125,215,205);
  color white = color(248,248,248);
  color orange = color(237,179,141);
  color green = color(198,222,159);
  
  
  // Constructor
  
  Rock(float x, float y, float r) {
    location = new PVector(x,y);
    radius = r; 
  }
  
  void drawRock(float x, float y) {
    
    if (radius >= 100) {
      fill(red);
      noStroke();
      ellipse(x,y,radius*2,radius*2);
    } else if (radius > 50 && radius < 100) {
      fill(green);
      noStroke();
      ellipse(x,y,radius*2,radius*2);
    } else {
      fill(blue);
      noStroke();
      ellipse(x,y,radius*2,radius*2);
    }
    
  }
  
}