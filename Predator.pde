class Predator {
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector ahead, aheadClose, aheadLeft, aheadRight;
  float r;
  float maxforce; // Maximum steering force
  float maxspeed; // Maximum speed
  float minspeed; // Minimum speed
  float velocityScalingFactor = 1.2;
  float seekDist = 200;
  boolean visuals = false;
  
  // Constructor
  Predator(float x, float y) {
    acceleration = new PVector(0,0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    location = new PVector(x,y);
    r = 3.0;
    maxspeed = 2.0;
    maxforce = 0.05;
    minspeed = 1.5;   
  }
  
  void run(ArrayList<Predator> predators, ArrayList<Boid> boids, ArrayList<Rock> rocks, boolean v) {
    visuals = v;
    flock(predators, boids, rocks);
    update();
    borders();
    render();
  }
  
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  
  void flock(ArrayList<Predator> predators, ArrayList<Boid> boids, ArrayList<Rock> rocks) {
    PVector seek = seek(boids);
    PVector sep = separate(predators, rocks);
    PVector avoid = avoid(rocks);
    seek.mult(2);
    sep.mult(2.5);
    avoid.mult(4.0);
    
    applyForce(seek);
    applyForce(sep);
    applyForce(avoid);
    
    if (velocity.mag() < minspeed) { velocity.mult(velocityScalingFactor); }
  }
  
  // Method to update location
  
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit to maxspeed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset acceleration to 0 each cycle
    acceleration.mult(0);
  }
  
  
  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(ArrayList<Boid> boids) {
    
    Boid target = findBoidInRange(boids);
    if (target!=null) {
      PVector desired = PVector.sub(target.location, location);                     // A pointing from location to target, going all the way.
      desired.normalize();                                                 // Normalizing the vector
      desired.mult(maxspeed);                                              // Scale to maximum speed
      PVector steer = PVector.sub(desired, velocity);                      // STEER = DESIRED - VELOCITY
      steer.limit(maxforce);                                               // Limit to maximum steering force;
      return steer;
    }
    return new PVector(0,0);
  }
    
  
  Boid findBoidInRange(ArrayList<Boid> boids){
    // seekDist = 200
    for (Boid b : boids) {
      if (PVector.dist(location, b.location) < seekDist){
        return b;   
      }
    }
    return null;
  }
  
  PVector separate (ArrayList<Predator> predators, ArrayList<Rock> rocks) {
    float desiredseparation = 100.0f;
    PVector steer = new PVector(0, 0);
    int count = 0;
    
    for (Predator other : predators) {                                                // Looping through to check if any of the boids is too close                                                    
      float d = PVector.dist(location, other.location);                        
                                            
      if((d > 0) && (d < desiredseparation)) {                                // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);                                                          // Weight by distance if the distance d large, 
        steer.add(diff);                                                      // then the separation force is smaller and opposite
        count++;                                                              // Keep track of how many
      }
    }
    if (count > 0) {                                                          // Average -- divide by how many
      steer.div((float)count);
    }
    if(steer.mag() > 0) {
      steer.normalize();                                                      // Implement Reynolds: Steering = Desired - Velocity
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }
  
  PVector avoid(ArrayList<Rock> rocks) {
    PVector vel_copy = velocity.get();
    PVector vel_copy2 = velocity.get();
    PVector vel_copy3 = velocity.get();
    PVector vel_copy4 = velocity.get();
    vel_copy.setMag(30);
    vel_copy2.setMag(15);
    vel_copy3.setMag(30);
    vel_copy4.setMag(30);
    
    ahead = PVector.add(location, vel_copy);
    aheadClose = PVector.add(location, vel_copy2);
    aheadLeft = vel_copy3.rotate(0.1);
    aheadLeft = PVector.add(location,aheadLeft);
    aheadRight = vel_copy4.rotate(- 0.1);
    aheadRight = PVector.add(location,aheadRight);
  
    Rock mostThreatening = findMostThreatening(rocks, ahead, aheadClose, aheadLeft, aheadRight);
    PVector avoidance = new PVector(0,0);
    
    if (mostThreatening != null) {
      // If too close
      if (PVector.dist(aheadClose,mostThreatening.location) <= mostThreatening.radius) {
        PVector desired = PVector.sub(location, mostThreatening.location);                     // A pointing from location to target, going all the way.
        desired.normalize();                                                                   // Normalizing the vector
        desired.mult(maxspeed);                                                                // Scale to maximum speed
        PVector steer = PVector.sub(desired, velocity);                                        // STEER = DESIRED - VELOCITY
        steer.limit(maxforce);                                                                 // Limit to maximum steering force;
        steer.mult(3);
        return steer;
      } else {
        avoidance = ahead.sub(mostThreatening.location);
        avoidance.normalize();
        avoidance.mult(maxspeed);
        avoidance.limit(maxforce);
      }
    } else {
      avoidance.mult(0);
    }
    return avoidance;
  }
  
  Rock findMostThreatening(ArrayList<Rock> rocks, PVector aheadFront, PVector aheadClose, PVector aheadLeft, PVector aheadRight) {
    Rock mostThreatening = null;
    if (rocks.isEmpty()) {
      return null;
    }
    for (Rock rock : rocks) {
      boolean collision = lineIntersectsCircle(aheadFront, aheadClose, aheadLeft, aheadRight, rock);
      if (collision && (mostThreatening == null || PVector.dist(location, rock.location) < PVector.dist(location, mostThreatening.location))) {
            mostThreatening = rock;
        }
    }
    return mostThreatening;
  }
  
  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    
    fill(237,179,141);
    //fill(229,129,56);
    //stroke(229,129,56);
    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*6);
    vertex(-r*3, r*6);
    vertex(r*3, r*6);
    endShape();
    popMatrix();
    
    if (visuals) {
      stroke(229,129,56);
      noFill();
      ellipse(location.x,location.y, seekDist*2, seekDist*2);
    }
    
  }
  
  // Wraparound
  
  void borders() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }
  
  boolean lineIntersectsCircle( PVector ahead, PVector aheadClose, PVector aheadLeft, PVector aheadRight, Rock r) {
    return ( PVector.dist(r.location, ahead) <= r.radius || PVector.dist(r.location, aheadClose) <= r.radius || 
    PVector.dist(r.location, aheadLeft) <= r.radius || PVector.dist(r.location, aheadRight) <= r.radius ) ;
  }
  
}