import processing.opengl.*;
import codeanticode.glgraphics.*;
import codeanticode.gsvideo.*;

///////////////////////////////
//  TUNEABLE PARAMETERS
///////////////////////////////
int canvasWidth = 1280;      //
int canvasHeight = 960;      //
int fr = 30;                 // Framerate
float motionThreshold = 5;   // How different must a pixel be to be a "motion" pixel
int blinkSpeed = 500;        // How fast should recording icon and button LED blink (in ms)?
int maxIdleSec = 3;          // max time of no motion before we force end the recording
///////////////////////////////

GSCapture cam;
GLTexture tex;
GLTexture texIdle;
GLGraphicsOffScreen offscreen;
PImage img, imgPrev;
PFont f1000;
PImage recSymbol;
int nextSwitch = 500;
boolean textOn, recording, starting, stopping = false;
int starttime, stoptime, seqtime, loopCount, idleTimer = 0;


void setup() {
  size(canvasWidth, canvasHeight, GLConstants.GLGRAPHICS);
  frameRate(fr);
  
  offscreen = new GLGraphicsOffScreen(this, width, height);
  cam = new GSCapture(this, 640, 480, "/dev/video1");
  
  // Use texture tex as the destination for the camera pixels.
  tex = new GLTexture(this);
  cam.setPixelDest(tex);     
  cam.start(); 
  
  //for image differencing (motion detection)
  img = new PImage(tex.width, tex.height);
  imgPrev = new PImage(tex.width, tex.height);

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
  if different, load the current image into the reference image and reset idle timer to 0
  if the same, and idletimer is 0, load the texturepixels into the reference image, increment idle timer
  if the same, and idle timer > 0, increment idle timer
  if idle timer > allowed idle time, force end the recording.
  */
  
  // instantiate the reference
   if ( loopCount == 1 ) {
     //stupid syntax, this actually puts tex into imgPrev 
     tex.getImage(imgPrev);
   }
   
   loopCount++;
   if ( loopCount % fr  == 0 ) {
     //put current frame into img
     tex.getImage(img);
     //image differencing from http://www.openprocessing.org/sketch/40828  
     img.loadPixels();
     imgPrev.loadPixels();
     
     float totalMotion = 0;
     for (int i = 0; i < img.pixels.length; i ++ ) {
       color current = img.pixels[i];
       color previous = imgPrev.pixels[i];
       float r1 = red(current);
       float g1 = green(current);
       float b1 = blue(current);
       float r2 = red(previous);
       float g2 = green(previous);
       float b2 = blue(previous);
       float diff = dist(r1,g1,b1,r2,g2,b2);
       totalMotion += diff;    
       if ( i % 1000 == 0 ) {
         println("r1:" + r1 + " r2:" + r2);
       }
    }
    float avgMotion = totalMotion / img.pixels.length;

    if (avgMotion > motionThreshold) {
      tex.getImage(imgPrev);
      // reset idle timer if we have motion
      idleTimer = 0;
    } else {  // no motion
      if ( idleTimer == 0 ) {
        tex.getImage(imgPrev);
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
