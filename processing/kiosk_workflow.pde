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

void drawOutlineString(String theText, int x, int y, int sz, int fillcolor) {
  fill(#000000);


  text(theText, x-sz, y+sz);
  text(theText, x-sz, y-sz);
  text(theText, x+sz, y+sz);
  text(theText, x+sz, y-sz);  
  fill(fillcolor);
  text(theText, x, y);
}

void startRec() {
  seqtime = millis() - starttime;
  if ( seqtime < 1000 ) {
    textFont(f1000);
    drawOutlineString("5", 340, 840, 10, #ffffff);
  } else if ( seqtime < 2000 ) {
    drawOutlineString("4", 340, 840, 10, #ffffff);
  } else if ( seqtime < 3000 ) {
    drawOutlineString("3", 340, 840, 10, #ffffff);
  } else if ( seqtime < 4000 ) {
    drawOutlineString("2", 340, 840, 10, #ffffff);
  } else if ( seqtime < 5000 ) {
    drawOutlineString("1", 340, 840, 10, #ffffff);
  } else if ( seqtime < 6000 ) {
    textFont(f1000,600);
    drawOutlineString("GO!", 80, 740, 7, #ffffff);
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
    drawOutlineString("Thanks!", 80, 500, 5, #ffffff);
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
      textFont(f1000,120);
      image(rec, 1050, 0);
      drawOutlineString("REC", 850, 175, 3, #bb0000);
    }
    textFont(f1000, 60);
    drawOutlineString("PUSH BUTTON TO STOP RECORDING", 60, 900, 2, #ffffff);
  } else {
    textFont(f1000, 200);
    drawOutlineString("VIDEO", 300, 200, 4, #ffffff);
    textFont(f1000, 185);
    drawOutlineString("GUESTBOOK", 30, 370, 4, #ffffff);
    textFont(f1000, 85);
    drawOutlineString("PUSH THE BIG RED BUTTON", 50, 600, 3, #ffffff);
    drawOutlineString("   TO RECORD A MESSAGE", 50, 700, 3, #ffffff);
    drawOutlineString("    FOR JOHN AND JACQUI!", 50, 800, 3, #ffffff);
   // drawOutlineString("PUSH BUTTON TO RECORD", 50, 900, 2, #ffffff);
  }
 
  
}
