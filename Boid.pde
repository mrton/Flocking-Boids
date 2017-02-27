class Boid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector ahead, aheadClose, aheadLeft, aheadRight;
  float r;
  float maxforce; // Maximum steering force
  float maxspeed; // Maximum speed
  float minspeed;
  float velocityScalingFactor = 1.2;
  boolean visuals = false;
  
  // Constructor
  Boid(float x, float y) {
    acceleration = new PVector(0,0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    location = new PVector(x,y);
    r = 3.0;
    maxspeed = 3.0;
    minspeed = 1.0;
    maxforce = 0.03;
  }
  
  void run(ArrayList<Boid> boids, ArrayList<Rock> rocks, ArrayList<Predator> predators, float sep, float ali, float coh, float avoid, float flee, boolean v) {
    flock(boids, rocks, predators, sep, ali, coh, avoid, flee);
    visuals = v;
    update();
    borders();
    render();
  }
  
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  
  // We accumulate a new acceleration each time based on three rules
  
  void flock(ArrayList<Boid> boids, ArrayList<Rock> rocks, ArrayList<Predator> predators, float s, float a, float c , float av, float f) {
    PVector sep = separate(boids, rocks);
    PVector ali = align(boids, rocks);
    PVector coh = cohesion(boids, rocks);
    PVector avoid = avoid(rocks);
    PVector flee = flee(predators);

    sep.mult(s);
    ali.mult(a);
    coh.mult(c);
    avoid.mult(av);
    flee.mult(f);
    
    // Add the force vectors to acceleration
    
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(avoid);
    applyForce(flee);
    
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
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);                     // A pointing from location to target, going all the way.
    desired.normalize();                                                 // Normalizing the vector
    desired.mult(maxspeed);                                              // Scale to maximum speed
    PVector steer = PVector.sub(desired, velocity);                      // STEER = DESIRED - VELOCITY
    steer.limit(maxforce);                                               // Limit to maximum steering force;
    return steer;
  }
  
  PVector flee(ArrayList<Predator> predators) {
    float fleeDist = 80 ;
    if (predators.isEmpty()) {
      return new PVector(0, 0);
    } else {
      Predator closestPredator = null;
      for (Predator p : predators) {
        if (closestPredator == null || PVector.dist(location, p.location) < PVector.dist(location, closestPredator.location)) {
          closestPredator = p;
        }
      }
      
      PVector target = closestPredator.location;
      if (PVector.dist(location, target) < fleeDist){
        PVector desired = PVector.sub(location, target);                     // A pointing from location to target, going all the way.
        desired.normalize();                                                 // Normalizing the vector
        desired.mult(maxspeed);                                              // Scale to maximum speed
        PVector steer = PVector.sub(desired, velocity);                      // STEER = DESIRED - VELOCITY
        steer.limit(maxforce);                                               // Limit to maximum steering force;
        return steer;
      } else {
        return new PVector(0, 0);
      }
    }
  }
  
  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    //fill(200,100);
    //fill(198,222,159);
    fill(250,233,159);
    //stroke(56,116,179);
    noStroke();
    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);
    beginShape(TRIANGLES);
    //line(0, -r*2, 0, -ahead.mag());
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }
  
  // Wraparound
  void borders() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }
  
  // Avoidance 
  PVector avoid(ArrayList<Rock> rocks) {
    PVector vel_copy = velocity.get();
    PVector vel_copy2 = velocity.get();
    PVector vel_copy3 = velocity.get();
    PVector vel_copy4 = velocity.get();
    vel_copy.setMag(100);
    vel_copy2.setMag(15);
    vel_copy3.setMag(100);
    vel_copy4.setMag(100);
    
    ahead = PVector.add(location, vel_copy);
    aheadClose = PVector.add(location, vel_copy2);
    aheadLeft = vel_copy3.rotate(0.1);
    aheadLeft = PVector.add(location,aheadLeft);
    aheadRight = vel_copy4.rotate(- 0.1);
    aheadRight = PVector.add(location,aheadRight);
    
    // FIX THIS, MOVE TO RENDER
    if(visuals) {
      pushMatrix();
      stroke(200);
      beginShape();
      vertex(aheadLeft.x, aheadLeft.y);
      vertex(ahead.x, ahead.y);
      vertex(aheadRight.x, aheadRight.y);
      endShape();
      
      fill(248,248,248);
      point(aheadClose.x, aheadClose.y);
      point(ahead.x, ahead.y);
      point(aheadLeft.x, aheadLeft.y);
      point(aheadRight.x, aheadRight.y);
      popMatrix();
    }
  
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
 
  // Separation
  // Method checks for nearby boids and steer away
  PVector separate (ArrayList<Boid> boids, ArrayList<Rock> rocks) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0);
    int count = 0;
    
    for (Boid other : boids) {                                                // Looping through to check if any of the boids is too close                                                    
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
  
  // Alignment
  // For every nearby boids in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids, ArrayList<Rock> rocks) {
      float neighbordist = 50;
      PVector sum = new PVector(0, 0);
      int count = 0;
      for (Boid other : boids) {
        float d = PVector.dist(location, other.location);
        if ((d > 0) && (d < neighbordist)) {
          sum.add(other.velocity);
          count++;
        }
      }
      if (count > 0) {
        sum.div((float)count);
        sum.normalize();                                            // Implement Reynolds: Steering = Desired - Velocity
        sum.mult(maxspeed);
        PVector steer = PVector.sub(sum, velocity);
        steer.limit(maxforce);
        return steer;
      } 
      else {
        return new PVector(0, 0);
      }
  }
      
  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList<Boid> boids, ArrayList<Rock> rocks) {
    float neighbordist = 50;                                        // Distance the boid strives to be away from its neighbour
    PVector sum = new PVector(0, 0);                                // Start with empty vector to accumulate all locations
    int count = 0;                                                  // Keeping track of neighbors within the distance
    for (Boid other : boids) {                                      // Finding all neighbors within the distance
      float d = PVector.dist(location, other.location);             
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location);                                    // Add location
        count++;
      }
    }
    //noFill();
    //stroke(21);
    //ellipse(location.x,location.y,25,25);
    if (count > 0) {
      sum.div(count);                                                // Calculating the center of mass
      return seek(sum);  // Steer towards the location               // Returning the force towards center of mass
    } 
    else {
      return new PVector(0, 0);                                      // Don't apply force if there is no boids in range.
    }
  }
  
  // Helper methods
  
  boolean lineIntersectsCircle( PVector ahead, PVector aheadClose, PVector aheadLeft, PVector aheadRight, Rock r) {
    return ( PVector.dist(r.location, ahead) <= r.radius || PVector.dist(r.location, aheadClose) <= r.radius || 
    PVector.dist(r.location, aheadLeft) <= r.radius || PVector.dist(r.location, aheadRight) <= r.radius ) ;
  }
  
}