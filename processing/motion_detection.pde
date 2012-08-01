import processing.opengl.*;
import codeanticode.glgraphics.*;
import codeanticode.gsvideo.*;

GSCapture cam;
GLTexture tex;
GLTexture texIdle;
GLGraphicsOffScreen offscreen;

PImage img;
 
PFont f1000, f100;
PImage recSymbol;

// How different must a pixel be to be a "motion" pixel
float motionThreshold = 50;

int canvasWidth = 1280;
int canvasHeight = 960;
//framerate
int fr = 30;

int blinkSpeed = 500;
int nextSwitch = 500;

// maximum time of no motion before we automatically end the recording
int maxIdleSec = 3;

boolean textOn, recording, starting, stopping = false;
int starttime, stoptime, seqtime, loopCount, idleTimer = 0;


void setup() {
  size(canvasWidth, canvasHeight, GLConstants.GLGRAPHICS);
  frameRate(fr);
  
  offscreen = new GLGraphicsOffScreen(this, width, height);
  //offscreenIdle = new GLGraphicsOffScreen(this, width, height);
  
  cam = new GSCapture(this, 640, 480, "/dev/video1");
  
  // Use texture tex as the destination for the camera pixels.
  tex = new GLTexture(this);
  cam.setPixelDest(tex);     
  cam.start(); 
  
  //texture object to hold idle reference image, initialize to white.
  texIdle = new GLTexture(this, tex.width, tex.height);
  img = new PImage(tex.width, tex.height);
  //texIdle.loadPixels();
  //for (int i = 0; i < texIdle.pixels.length; i++) {
  //  texIdle.pixels[i] = color(0); 
  //}
  //texIdle.loadTexture();


  f1000 = createFont("Arial",1000,true);
  recSymbol = loadImage("recording-icon.png");
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

void rec() {
  if (millis() > nextSwitch ) {
      nextSwitch = millis() + blinkSpeed;
      textOn=!textOn;
  }  
  if ( textOn ) {
    fill(#bb0000);
    textFont(f1000,120);
    image(recSymbol, 1050, 0);
    drawOutlineString("REC", 850, 175, 3, #bb0000);
  }
  textFont(f1000, 60);
  drawOutlineString("PUSH BUTTON TO STOP RECORDING", 60, 900, 2, #ffffff);
}


void waitMsg() {
  textFont(f1000, 200);
  drawOutlineString("VIDEO", 300, 200, 4, #ffffff);
  textFont(f1000, 185);
  drawOutlineString("GUESTBOOK", 30, 370, 4, #ffffff);
  textFont(f1000, 85);
  drawOutlineString("PUSH THE BIG RED BUTTON", 50, 600, 3, #ffffff);
  drawOutlineString("   TO RECORD A MESSAGE", 50, 700, 3, #ffffff);
  drawOutlineString("    FOR JOHN AND JACQUI!", 50, 800, 3, #ffffff);
}


//TODO: abort on button press during start sequence
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

  //draw the video feed
  offscreen.beginDraw();
  if (tex.putPixelsIntoTexture()) {
    offscreen.image(tex, 0, 0, width, height);
  }
  offscreen.endDraw();
  image(offscreen.getTexture(), 0, 0);
 

  /* 
  DONE (texIdle) have a reference texture loaded initially (all black or something)
  every second (loopCount is % frameRate, loadPixels of that texture and compare with stored image
  if different, reset idle timer to 0
  if the same, and idletimer is 0, load the texturepixels into the reference image, increment idle timer
  if the same, and idle timer > 0, increment idle timer
  if idle timer > allowed idle time, force end the recording.
  */
  
  // instantiate the reference
   if ( loopCount == 0 ) {
     tex.getImage(img);
     texIdle.putImage(img);
   }
   
   loopCount++;
   if ( ( loopCount % fr ) == 0 ) {
     
     //image differencing from http://www.openprocessing.org/sketch/40828  
     tex.loadPixels();
     texIdle.loadPixels();
   
     // Begin loop to walk through every pixel
     // Start with a total of 0
     float totalMotion = 0;
   
     // Sum the brightness of each pixel
     for (int i = 0; i < tex.pixels.length; i ++ ) {
       // Determine current color
       color current = tex.pixels[i];
     
       // Determine color of reference image pixel
       color previous = texIdle.pixels[i];
     
       // Compare reference vs. current color
       float r1 = red(current);
       float g1 = green(current);
       float b1 = blue(current);
       float r2 = red(previous);
       float g2 = green(previous);
       float b2 = blue(previous);
     
       // Motion for an individual pixel is the difference between the previous color and current color.
       float diff = dist(r1,g1,b1,r2,g2,b2);
       
       //println("color_current:" + current + "  color_previous:" +  previous + "  diff:" + diff );
       // totalMotion is the sum of all color differences.
       totalMotion += diff;
    }
   
    // averageMotion is total motion divided by the number of pixels analyzed.
    float avgMotion = totalMotion / tex.pixels.length;
    
    println(avgMotion);
    
    if (avgMotion > motionThreshold) {
      // reset idle timer if we have motion
      idleTimer = 0;
    } else {
      if ( idleTimer == 0 ) {
        texIdle.getImage(tex);
        idleTimer++;
      } else {
        if ( idleTimer > maxIdleSec ) {
          //TODO: end the recording 
        }
      }
    }

  } // end if loopcount % fr
  
  
  
  
  
  
  if ( starting ) {
    startRec();
  } else if ( stopping ) {
    stopRec();
  } else if ( recording ) {
    rec();
  } else {
    waitMsg();
  }
 
  
}
