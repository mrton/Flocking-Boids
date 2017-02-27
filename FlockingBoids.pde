import controlP5.*;

ControlP5 cp5;
PGraphics pg;

Flock flock;
Obstacles obstacles;

float separation, alignment, cohesion, flee, avoidance, obstacleSize;

int menuX, menuY, menuWidth, menuHeight;

PFont f;
color menuColor = color(120,124,158, 150);
color fontColor = color(248,248,248);
color backgroundColor = color(50);

// BUTTONS
controlP5.Button reset_boid;
controlP5.Button reset_pred;
controlP5.Button reset_obst;
boolean menuOver = false;
boolean boidVisualEffects = false;
boolean predatorVisualEffects = false;
RadioButton r;
int radioItem = 1;

// SETUP
void setup() {
  f = createFont("Papyrus", 16, true);            // HelveticaNeue-Light, 16 point, anti-aliasing on
  frameRate(60);
  
  //size(1280, 720);
  //size(1366, 768);
  size(1600, 900);
  flock = new Flock();
  obstacles = new Obstacles();
  
  menuX = width - width/6;
  menuY= 0;
  menuWidth = width/6;
  menuHeight = height;
  
  // SLIDER, BUTTONS AND CONTROLLERS
  cp5 = new ControlP5(this);
  
  // adding a horizontal sliders that will be linked to the variables separation, alignment and cohesion
  cp5.addSlider("separation").setPosition(width - width/7 , height/10).setRange(0,10).setColorCaptionLabel(fontColor);
  cp5.addSlider("alignment").setPosition(width - width/7 ,height/10 + 50).setRange(0,10).setColorCaptionLabel(fontColor);
  cp5.addSlider("cohesion").setPosition(width - width/7 ,height/10 + 100).setRange(0,10).setColorCaptionLabel(fontColor);
  cp5.addSlider("flee").setPosition(width - width/7 ,height/10 + 150).setRange(0,10).setColorCaptionLabel(fontColor);
  cp5.addSlider("avoidance").setPosition(width - width/7 ,height/10 + 200).setRange(0,10).setColorCaptionLabel(fontColor);
  cp5.addSlider("obstacleSize").setPosition(width - width/7 ,height/10 + 350).setRange(10, 150).setColorCaptionLabel(fontColor).setCaptionLabel("obstacle size");
  
  cp5.getController("separation").setValue(2.0);
  cp5.getController("alignment").setValue(1.0);
  cp5.getController("cohesion").setValue(1.0);
  cp5.getController("flee").setValue(4.0);
  cp5.getController("avoidance").setValue(6.0);
  cp5.getController("obstacleSize").setValue(100.0);
  
  // RADIO BUTTONS
  r = cp5.addRadioButton("radio",width - width/7 ,height/10 + 300).setColorLabel(fontColor);
  r.addItem("BOID", 0);
  r.addItem("PREDATOR", 1);
  r.addItem("OBSTACLE", 2);
  r.activate(0);
  
  
  // RESET BUTTONS
  reset_boid = cp5.addButton("reset boids").setValue(0).setPosition(width - width/11 ,height/10 + 300).setSize(9,9).setId(1).setColorCaptionLabel(fontColor);
  reset_pred = cp5.addButton("reset predators").setValue(0).setPosition(width - width/11 ,height/10 + 310).setSize(9,9).setId(2).setColorCaptionLabel(fontColor);
  reset_obst = cp5.addButton("reset obstacles").setValue(0).setPosition(width - width/11 ,height/10 + 320).setSize(9,9).setId(3).setColorCaptionLabel(fontColor);
  
  cp5.getController("reset boids").getCaptionLabel().getStyle().marginLeft = 32;
  cp5.getController("reset predators").getCaptionLabel().getStyle().marginLeft = 43;
  cp5.getController("reset obstacles").getCaptionLabel().getStyle().marginLeft = 43;
  
  // TOGGLE BUTTONS
  cp5.addToggle("boidVisualEffects").setPosition(width - width/7 ,height/10 + 450).setSize(30,10).setValue(false).setMode(ControlP5.SWITCH).setColorCaptionLabel(fontColor).setCaptionLabel("boid visuals");
  cp5.addToggle("predatorVisualEffects").setPosition(width - width/10 ,height/10 + 450).setSize(30,10).setValue(false).setMode(ControlP5.SWITCH).setColorCaptionLabel(fontColor).setCaptionLabel("predator visuals");
}

void draw() {
  background(backgroundColor);
  
  obstacles.run();
  flock.run(obstacles, boidVisualEffects, predatorVisualEffects);
  fill(255);
  textFont(f,24);
  text("#Boids: " + flock.boids.size(), 20, height - 20);
  text("#Predators: " + flock.predators.size(), 200, height - 20);
  text("#Obstacles: " + obstacles.rocks.size(), 420, height - 20);
  text("Frame Rate: " + int(frameRate) , 20, 30);
  
  fill(menuColor);
  noStroke();
  rect(menuX, menuY, menuWidth, menuHeight);
  
  //For burst of boids once clicked
  
  if (!menuOver && (mouseButton == LEFT) && radioItem == 0) {
    flock.addBoid(new Boid(mouseX, mouseY));
  }
  
  
  
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isGroup() && theEvent.name().equals("radio")) {
    radioItem = (int)theEvent.value();
  }
  if(theEvent.id() == 1) {
    flock.boids.clear();
  }
  if(theEvent.id() == 2) {
    flock.predators.clear();
  }
  if(theEvent.id() == 3) {
    obstacles.rocks.clear();
  }
}

void boidVisualEffects(boolean theFlag) {
  if(theFlag==true) {
    boidVisualEffects = true;
  } else {
    boidVisualEffects = false;
  }
}
void predatorVisualEffects(boolean theFlag) {
  if(theFlag==true) {
    predatorVisualEffects = true;
  } else {
    predatorVisualEffects = false;
  }
}

public void separation(float theValue) {flock.setSeparation(theValue);}

public void alignment(float theValue) {flock.setAlignment(theValue);}

public void cohesion(float theValue) {flock.setCohesion(theValue);}

public void avoidance(float theValue) {flock.setAvoidance(theValue);}

public void flee(float theValue) {flock.setFlee(theValue);}

public void obstacleSize(float theValue) {
  obstacleSize = theValue;
  r.activate(2);
}

void mousePressed() {
  update();
  /*
  if (!menuOver && (mouseButton == LEFT) && radioItem == 0) {
    flock.addBoid(new Boid(mouseX, mouseY));
  }
  */
  
  
  if (!menuOver && (mouseButton == LEFT) && radioItem == 1) {
    flock.addPredator(new Predator(mouseX, mouseY));
  }
  
  if (!menuOver && (mouseButton == LEFT) && radioItem == 2) {
    obstacles.addRock(new Rock(mouseX, mouseY, obstacleSize));
  }
}

void update() {
  if (overMenu(menuX, menuY, menuWidth, menuHeight)) {
    menuOver = true;
  } else {
    menuOver = false;
  }
}

boolean overMenu(int x, int y, int width, int height) {
  if ((mouseX >= x && mouseX <= x + width) && (mouseY >= y && mouseY <= y + height)) {
    return true;
  } else {
    return false;
  }
}