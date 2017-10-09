import processing.serial.*;

// *******************************************
// Global Variables
// *******************************************
Serial myPort;  // The serial port

Slider[] sliders =  new Slider[3]; // slider array
float LOWERX; // globally accessible lowerx variable
Button[] buttons = new Button[3];  //array to store buttons

int WIDTH = 800;
int HEIGHT = 640;

// L-system related global variables
String AXIOM = "F";
char RULE_PRE = 'F';
String RULE_SUC = "FF+[+F-F-F]-[-F+F+F]";
int ITER_TEMP, ITER;
float ANGLE = radians(25);

LSystem lsys;
Rule[] ruleset;
Turtle turtle;

// Animation Control Variables
// 0 = don't animate, 1 = animate, 2 = pause animation at current state
int ANIMATE = 0;  
int ANIM_SPEED = 1;

// *******************************************
// Processing Functions
// *******************************************
void setup() {
  
  size(800,640);
  stroke(0);
  noFill();
  background(255);
  
  myPort = new Serial(this, Serial.list()[0], 9600); // enables delay()
  
  // init them: (xPos, yPos, width, height)
  sliders[0] = new Slider(20, 20, 40, 20, "iterations");
  sliders[1] = new Slider(20, 60, 40, 20, "rotation");
  sliders[1].x = 140;  // set initial position of lsystem rotation angle slider
  sliders[2] = new Slider(20, 100, 40, 20, "animation");
  
  // Initialize buttons
  buttons[0] = new Button(100, 130, 55, 20, "Play", color(200, 200, 200), color(50, 50, 50));
  buttons[1] = new Button(180, 130, 55, 20, "Pause", color(200, 200, 200),color(50, 50, 50));
  buttons[2] = new Button(260, 130, 55, 20, "Stop", color(200, 200, 200),color(50, 50, 50));
    
  // Create ruleset
  ruleset = new Rule[1];
  ruleset[0] = new Rule();
  // Processing won't allow me to use the constructor
  ruleset[0].predecessor = RULE_PRE;
  ruleset[0].successor = RULE_SUC;
  
  // Create lsystem object
  lsys = new LSystem();
  // Processing won't allow me to use the constructor
  lsys.axiom = AXIOM;
  lsys.ruleset = ruleset;
  lsys.iterations = 0;
  
  lsys.generate(8);
  
  turtle = new Turtle();
  turtle.rot_angle = ANGLE;
  turtle.iterations = lsys.iterations;
  turtle.sentence = lsys.getSentence(0);
  turtle.setLSysVars(ITER_TEMP, ANGLE); 
}

void draw() {
  
  background(255);
  
  turtle.displayGrammar();
  turtle.displayDetails();
  
  pushMatrix();
  translate(20,height-20);
      
  // If animation is stoped then simplt redner the whole L-System 
  if(ANIMATE == 0){
    turtle.render();    // Draw L-System
    turtle.resetAnimation();
    buttons[2].pressed = false;
  } 
  // If animation variable is 1 then animate L-system
  else if(ANIMATE == 1){
     turtle.animate("play");
  } 
  // If animation variable is set to 2, pause animation at current state
  else if(ANIMATE == 2){
     turtle.animate("pause");
  }
  
  popMatrix();
  
  // slider labels
  text("Iterations", 20, 15);
  text("Rotation Angle", 20, 55);
  text("Animation Speed", 20, 95);
  
  //call run method for sliders
  for (Slider t:sliders)
    t.run();
    
  //call run method for buttons
  for (Button t:buttons)
    t.run();
}

void mousePressed() {
  //lock if clicked (slider listener)
  for (Slider t:sliders)
  {
    if (t.isOver()){
      t.lock = true;
    }
  }  
  
  //lock if clicked (button listener)
  for (Button t:buttons){
    if (t.isOver()){
      t.pressed = !t.pressed;
      if(t.name == "Play"){
        ANIMATE = 1; // enable animation of lsystem
        buttons[1].pressed = false;
        buttons[2].pressed = false;
      }
      if(t.name == "Pause"){
        ANIMATE = 2; // pause animation at current state
        buttons[0].pressed = false;
        buttons[2].pressed = false;
      }
      if(t.name == "Stop"){
        ANIMATE = 0; // stop animation of lsystem
        buttons[0].pressed = false;
        buttons[1].pressed = false;
      }
    }
  }  
}
 
void mouseReleased() {
 
  //unlock sliders
  for (Slider t:sliders)
  {
    t.lock = false;
  }
   
  turtle.setLSysVars(ITER_TEMP, ANGLE); 
  redraw();
}
 
 
// *******************************************
// Button Class
// *******************************************

// https://processing.org/examples/button.html

class Button{
  int x, y, w, h;
  color bColor, hoverColor, currentColor;
  boolean isOver;
  String name;
  boolean pressed;
  
  // Constructor, initialize all variables
  Button(int _x, int _y, int _w, int _h, String _name, color _bColor, int _hoverColor){
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    bColor = _bColor;
    hoverColor = _hoverColor;
    isOver = false;
    name = _name;
    isOver = false;
    pressed = false;
  }
  
  void run(){
    
    // Fill button with default color
    if(pressed){
      fill(hoverColor);
    } else {
      fill(bColor);
    }
    
    // Draw button border
    rect(x, y, w, h);
    
    // Display text
    if(pressed){
      fill(255);
    } else {
      fill(0);
    }
    
    if(name == "Pause"){
      text(name, x+10, y+15);
    } else {
      text(name, x+15, y+15);
    }
    
    // Restore color
    fill(0);
  }
  
  boolean isOver(){
    if (mouseX >= x && mouseX <= x+w && 
        mouseY >= y && mouseY <= y+h) {
      return true;
    } else {
      return false;
    }
  }
  
  void bNormal(){
    
  }
}
 
// *******************************************
// Slider Class
// *******************************************
class Slider {
  //class vars
  String name;
  float x;
  float y;
  float w, h;
  float initialY, initialX;
  boolean lock = false;

  //default
  Slider () {
  }
 
  Slider (float _x, float _y, float _w, float _h, String _name) {
    x=_x;
    y=_y;
    initialY = y;
    initialX = x;
    w=_w;
    h=_h;
    name = _name;
  }
  
  void run() {
        
    LOWERX = width - initialX - w;
   
    // map value to change color..
    // map() scales the value from the first specified range into the second range
    float value = map(x, initialX, LOWERX, 120, 220);
    
    // map value to display
    // map() scales the value from the first specified range into the second range
    float value2 = 0;
    if(name == "animation"){
      value2 = map(value, 120, 220, 1, 10);
      ANIM_SPEED = (int)value2;
    } else if(name == "iterations"){
      value2 = map(value, 120, 220, 0, 6);
      ITER_TEMP = (int)value2;
    } else if(name == "rotation"){
      value2 = map(value, 120, 220, 1, 90);
      ANGLE = value2;
    }
    
 
    //set color as it changes
    color c = color(value);
    fill(c);
 
    // draw base line
    rect(initialX, initialY, WIDTH-w, 5);
 
    // draw knob
    fill(200);
    
    rect(x, y, w, h);
 
    // display text
    fill(0);
    if(name == "animation"){
      text("x" + int(value2), x+15, y+15);
    } else if(name == "iterations"){
      text(int(value2) +"", x+15, y+15);
    } else if(name == "rotation"){
      text(int(value2) +"", x+15, y+15);
    }
 
    //get mouseInput and map it
    float mx = constrain(mouseX, initialX, width - w - initialX );
    if (lock) x = mx;
  }
 
  // is mouse ove knob?
  boolean isOver()
  {
    return (x+w >= mouseX) && (mouseX >= x) && (y+h >= mouseY) && (mouseY >= y);
  }
}
 
 
// *******************************************
// Rule Class
// *******************************************
class Rule {
  char predecessor; 
  String successor;
   
  // Default constructor
  void Rule(){}
  
  // constructor
  void Rule(char _predecessor, String _successor){
    predecessor = _predecessor;
    successor = _successor;
  } 
}


// *******************************************
// LSystem Class
// *******************************************
class LSystem {
  Rule[] ruleset;
  String axiom;
  StringBuffer[] sentence;
  int iterations;
  
  // Default constructor
  void LSystem(){}
  
  // constructor
  void LSystem(String _axiom, Rule[] _ruleset){
    ruleset = _ruleset;
    axiom = _axiom;
    sentence = new StringBuffer[8];
    sentence[0] = new StringBuffer(axiom);
    iterations = 0;
  } 
  
  // Calculates and returns the next sentence of the lsystem
  String getSentence(){
    return sentence[sentence.length].toString();
  }
  
  // Generates a new sentence by applying the rules to the current sentence 
  void generate(int iter){
    if(iter > 8){
      println("Invalid iteration count. Try a value <=10.");
    }
    
    // clear lsystem variables 
    clearSystem();                     
    
    // for iter iterations generate sentences
    for(int j = 1; j < iter; j++){
      
      // temporary string buffer
      StringBuffer newSentence = new StringBuffer(); 

      // loop through characters in current sentence
      for (int i = 0; i < sentence[j-1].length(); i++) {
        char c = sentence[j-1].charAt(i);
       
        // Loop through rules
        for(Rule r : ruleset){
          
          // If character matches rule replace it with successor 
          if(c == r.predecessor){
            newSentence.append(r.successor);
          } else {
            newSentence.append(c);
          }
        }
      }
    
    ++iterations;                      // Increase iteration count
    sentence[j] = newSentence;         // Save new sentence
    }
  }
  
  // Calculates and returns the sentence after the specified number of iterations
  String getSentence(int iter){
    if(iter > 8){
      println("Invalid iteration count. Try a value <=10.");
    }
    
    // if a sentence for the specified iteration number doesn't exist 
    // generate new system sentences
    if(iterations < iter){
      generate(iter);
    } 
    return sentence[iter].toString();        // return specified iteration sentence
  }
  
  // Clears l-system sentence and iteration variables
  void clearSystem(){
    sentence = new StringBuffer[8];
    sentence[0] = new StringBuffer(axiom);
    iterations = 0;
  }
}


// *******************************************
// Turtle Class
// *******************************************
class Turtle {
  float line_width;
  float rot_angle;
  String sentence;
  int iterations;
  
  // Animation variables
  int currentIndex = 0;       // current position in sentence for animation
  int delayMultiplier = 4;    // animation block multiplier
  int attempt = 0;            // variable to count animation attempts blocked
  int iter = 0;               // local variable to track current lsys animation
  
  // Default constructor
  void Tutle(){}
  
  // Constructor
  void Tutle(float _rot_angle, String _sentence, int iter){
    rot_angle = _rot_angle;
    sentence = _sentence;
    iterations = iter;
  } 
  
  void setLSysVars(int ITER_TEMP, float ANGLE){
    // If iteration sldier has changed reset buttons
    if(ITER != ITER_TEMP){
      buttons[0].pressed = false;
      buttons[1].pressed = false;
      buttons[2].pressed = false;
    }
    ITER = ITER_TEMP;
    this.rot_angle = radians(ANGLE);
    this.sentence= lsys.getSentence(ITER);
  }
  
  // Renders the L-system
  void render(){
    if(sentence != null){
      displayString(sentence.length());
      
      rotate(-radians(90));    // rotate matrix
      noFill();                // disable fill for the rectangle and the following shapes 
      createBoundingBoxes();
      translate(0,180);        // translate matrix to center 
      line_width = calculateLineWidth();
      for (int i = 0; i < sentence.length(); i++) {
        char c = sentence.charAt(i);
        if (c == 'F') {
          line(0,0,line_width,0);
          translate(line_width,0);
        } else if (c == 'F') {
         translate(line_width,0);
        } else if (c == '+') {
          rotate(rot_angle);
        } else if (c == '-') {
          rotate(-rot_angle);
        } else if (c == '[') {
          pushMatrix();
        } else if (c == ']') {
          popMatrix();
        }
      }
    } else {
      println("\"sentence\" is undefined!");
    }
  }
  
  // Render until specified index
  void renderUntil(int indexLimit){
    if(sentence != null){
      // Display L-System string 
      displayString(indexLimit);
      
      rotate(-radians(90));    // rotate matrix
      noFill();                // disable fill for the rectangle and the following shapes 
      createBoundingBoxes();
      translate(0,180);        // translate matrix to center 
      line_width = calculateLineWidth();  // calculate line width according to the current iteration
      int diff = 0;   // variable to track push and pops
      
      // Loop through string until currentIndex
      for (int i = 0; i < indexLimit; i++) {
        char c = sentence.charAt(i);
        if (c == 'F') {
          line(0,0,line_width,0);
          translate(line_width,0);
        } else if (c == 'F') {
         translate(line_width,0);
        } else if (c == '+') {
          rotate(rot_angle);
        } else if (c == '-') {
          rotate(-rot_angle);
        } else if (c == '[') {
          pushMatrix(); ++diff;
        } else if (c == ']') {
          popMatrix(); --diff;
        }
      }
      
      // Pain turtle triangle
      displayTurtle();
      
      // Pop matrix to restore push-pop balance
      for(int i = 0; i < diff; i++){
        popMatrix();
      }
    } else {
      println("\"sentence\" is undefined!");
    }
  }
  
  
  // Animate L-System 
  void animate(String action){
    // Get animation speed
    delayMultiplier = (61 - ANIM_SPEED * 6);
    
    // Creat bounding boxes no mater what
    createEmptyBoundingBoxes(); 
    
    // If ITER (slider) has changed, reset local iter var and animation  
    if(iter != ITER){
      iter = ITER;
      resetAnimation();
    }
    
    // if iteration slider is set to 0 don't animate;
    if(iter == 0){ 
      createEmptyBoundingBoxes(); 
      return; 
    }  
    
    // pause animation if currentIndex has reached the sentence length
    if(currentIndex == sentence.length() - 1){ 
      ANIMATE = 0;
      buttons[0].pressed = false;
    }
    
    // Decide what to display 
    if(action.equals("play")){
      // Delay animation by "delayMultiplier" times
      if(attempt % delayMultiplier == 0){
        ++currentIndex;  // Increase index to draw up to
        println("yes");
      } else {
        println("no");
      }
      attempt++;
      
      renderUntil(currentIndex);
    } else if(action.equals("pause")){
      if(currentIndex == 0)
        resetAnimation();
      else 
        renderUntil(currentIndex);
    } 
    // Isn't actually used
    else if(action.equals("stop")){
      resetAnimation();
      
    }
  }
  
  // Calculates the appropriate line width for the rendering function
  float calculateLineWidth(){
    switch(ITER){
      case 0: return 400;
      case 1: return 83;
      case 2: return 32.5;
      case 3: return 14.8;
      case 4: return 7;
      case 5: return 3.5;
      case 6: return 1.7;
      default: return 10;     
    }
  }
  
  // Creating animation bounding boxes
  void createBoundingBoxes(){
    rect(0, 0, 450, 400);    // create bounding box
    rect(0, 420, 450, 340);    // create bounding box
  }
  
  // Create empty bounding boxes
  void createEmptyBoundingBoxes(){
    rotate(-radians(90));      // rotate matrix
    noFill();                  // disable fill for the rectangle and the following shapes 
    rect(0, 0, 450, 400);      // create bounding box
    rect(0, 420, 450, 340);    // create bounding box
    rotate(radians(90));      // reset rotation
  }
  
  // Reset animation 
  void resetAnimation(){
    currentIndex = 0;
    attempt = 0;
  }
  
  // Display grammar
  void displayGrammar(){
    text("L-System Grammar:", 540, 135);
    text("F = Paint Line             + = Turn Right            - = Turn Left", 440, 149);
    text("[  = Push Matrix           ] = Pop Matrix", 440, 163);
  }
  
  // Display the L-System details
  void displayDetails(){
    text("Axiom     : " + AXIOM, 450, 190);
    text("Rule        : " + RULE_PRE + " = " + RULE_SUC, 450, 204);
    text("Iteration  : " + ITER, 450, 218);
  }
  
  // Display the L-System details
  void displayString(int indexLimit){
    String newS = "String : ";
    
    // Calculate string to display
    for(int i = 0; i < indexLimit; i++){
      char c = sentence.charAt(i);
      newS += c;      
    }
    
    // Dsiplay string
    fill(0);
    stroke(0);
    text(newS, 430, -380, 370, 370);  // Text wraps within text box
  }
  
  // Display turtle
  void displayTurtle(){
    rotate(-radians(90));
    fill(0);
    triangle(-5, 0, 0, 5, 5, 0);
  }
}