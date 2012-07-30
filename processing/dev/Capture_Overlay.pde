import processing.opengl.*;
import codeanticode.glgraphics.*;
import codeanticode.gsvideo.*;

GSCapture cam;
GLTexture tex;
GLGraphicsOffScreen offscreen;

PFont f;
PImage rec;



void setup() {
  size(1280, 960, GLConstants.GLGRAPHICS);
  offscreen = new GLGraphicsOffScreen(this, width, height);
  
  cam = new GSCapture(this, 640, 480, "/dev/video1");
  
  // Use texture tex as the destination for the camera pixels.
  tex = new GLTexture(this);
  cam.setPixelDest(tex);     
  cam.start(); 
  
  f = createFont("Arial",120,true); // Arial, 16 point, anti-aliasing on
  
  rec = loadImage("recording-icon.png");
}

void captureEvent(GSCapture cam) {
  cam.read();
}

void draw() {
   
  offscreen.beginDraw();
  if (tex.putPixelsIntoTexture()) {
    offscreen.image(tex, 0, 0, width, height);
  }
  offscreen.endDraw();
  image(offscreen.getTexture(), 0, 0);
  
  textFont(f,120);
  fill(#00bb00);
  text("RECORDING ON", 100, 100);
  
  
  image(rec, 300, 300);

}
