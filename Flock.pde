class Flock {
  
  ArrayList<Boid> boids;
  ArrayList<Rock> rocks;
  ArrayList<Predator> predators;
  float sep;
  float ali;
  float coh;
  float avoid;
  float flee;
  
  Flock() {
    boids = new ArrayList<Boid>(); // An arraylist for all the boids
    predators = new ArrayList<Predator>();
  }
  
  void run(Obstacles ob, boolean bv, boolean pv){
    rocks = ob.rocks;
    for (Boid b : boids) {
      b.run(boids, rocks, predators, getSeparation(), getAlignment(), getCohesion(), getAvoid(), getFlee(), bv); // Passing the entire list of boids to each boid individually
    }
    for (Predator p : predators) {
      p.run(predators, boids, rocks, pv); // Passing the entire list of boids to each boid individually
    }
  }
  
  void addBoid(Boid b) {
    boids.add(b);
  }
  
  void addPredator(Predator p) {
    predators.add(p);
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
  void setAvoidance(float avoid){
    this.avoid = avoid;
  }
  void setFlee(float flee){
    this.flee = flee;
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
  float getAvoid(){
  return avoid;
  }
  float getFlee(){
    return flee;
  }
}