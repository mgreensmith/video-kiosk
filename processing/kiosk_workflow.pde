import processing.opengl.*;
import codeanticode.glgraphics.*;
import codeanticode.gsvideo.*;

GSCapture cam;
GLTexture tex;
GLGraphicsOffScreen offscreen;

PFont f1000, f100;
PImage rec;

int blinkSpeed = 500;
int nextSwitch = 500;
boolean textOn = false;
boolean recording = false;

boolean starting, stopping = false;
int starttime = 0;
int stoptime = 0;
int seqtime = 0;



void setup() {
  size(1280, 960, GLConstants.GLGRAPHICS);
  offscreen = new GLGraphicsOffScreen(this, width, height);
  
  cam = new GSCapture(this, 640, 480, "/dev/video1");
  
  // Use texture tex as the destination for the camera pixels.
  tex = new GLTexture(this);
  cam.setPixelDest(tex);     
  cam.start(); 

  f1000 = createFont("Arial",1000,true);
  
  rec = loadImage("recording-icon.png");
  

}

void captureEvent(GSCapture cam) {
  cam.read();
}

void drawOutlineString(String theText, int x, int y) {
  fill(#000000);


  text(theText, x-10, y+10);
  text(theText, x-10, y-10);
  text(theText, x+10, y+10);
  text(theText, x+10, y-10);  
  fill(#ffffff);
  text(theText, x, y);
}

void startRec() {
  seqtime = millis() - starttime;
  if ( seqtime < 1000 ) {
    textFont(f1000);
    drawOutlineString("5", 340, 840);
  } else if ( seqtime < 2000 ) {
    drawOutlineString("4", 340, 840);
  } else if ( seqtime < 3000 ) {
    drawOutlineString("3", 340, 840);
  } else if ( seqtime < 4000 ) {
    drawOutlineString("2", 340, 840);
  } else if ( seqtime < 5000 ) {
    drawOutlineString("1", 340, 840);
  } else if ( seqtime < 6000 ) {
    textFont(f1000,600);
    drawOutlineString("GO!", 80, 740);
    // account for startup time of the capture pipeline
    if ( ! recording ) {
      // start capture process here!
      recording = true;
    }
  } else {
    starting = false;    
  }
}


void stopRec() {
  //stop recording pipeline here!
  recording = false;

  seqtime = millis() - stoptime;
  if ( seqtime < 3000 ) {
    textFont(f1000,300);
    drawOutlineString("Thanks!", 80, 500);
  } else {
    stopping = false;
  }
}

void keyPressed() {
  if ( recording ) {
    stoptime = millis();
    stopping = true;
  } else {
    starttime = millis();
    starting = true;
  }
}

void draw() {
   
  offscreen.beginDraw();
  if (tex.putPixelsIntoTexture()) {
    offscreen.image(tex, 0, 0, width, height);
  }
  offscreen.endDraw();
  image(offscreen.getTexture(), 0, 0);
  
  
  if ( starting ) {
    startRec();
  } else if ( stopping ) {
    stopRec();
  } else if ( recording ) {
    if (millis() > nextSwitch ) {
      nextSwitch = millis() + blinkSpeed;
      textOn=!textOn;
    }  
    if ( textOn ) {
      fill(#bb0000);
      textFont(f1000,100);
      image(rec, 1050, 0);
      text("REC", 850, 175);
    }
  } else {
    // print starting instructions
  }
 
  
}
