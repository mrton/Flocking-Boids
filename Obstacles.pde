
class Obstacles {
  
  ArrayList<Rock> rocks;
  float sep;
  float ali;
  float coh;
  Obstacles() {
    rocks = new ArrayList<Rock>(); // An arraylist for all the boids
  }
  
  void run() {
    for (Rock r : rocks){
      r.drawRock(r.location.x, r.location.y);
    }
  }
  
  void addRock(Rock r) {
    rocks.add(r);
    r.drawRock(r.location.x, r.location.y);
  }
 
  void setSeparation(float sep){
    this.sep = sep;
  }
  void setAlignment(float ali){
    this.ali = ali;
  }
  void setCohesion(float coh){
    this.coh = coh;
  }
  
  float getSeparation(){
    return sep;
  }
  float getAlignment(){
    return ali;
  }
  float getCohesion(){
    return coh;
  }
  
  
}