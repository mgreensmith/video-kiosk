/*
 * Shell control test
 * v0.1
 * Author: Matt Greensmith
 * Date: 29 July 2012
 *
 * Can we control a shell script that manages camera recording nicely through processing?
 */
import controlP5.*;
import java.io.*;

boolean debug = false;
boolean recordingEnabled = false;

ControlP5 controlP5;

void setup() {
  size(300,200);
  frameRate(25);
  controlP5 = new ControlP5(this);  
  controlP5.setColorLabel(0xff000000);
  controlP5.setAutoInitialization(false);
  
  //recording switch
  controlP5.addToggle("recording", false, 20, 60, 50, 20).setMode(ControlP5.SWITCH);

}

void draw() {
  background(200);
  
  if (recordingEnabled) {
    fill(200);
    text("RECORDING OFF", 100, 75); //hide
    fill(#00bb00);
    text("RECORDING ON", 100, 75); //show this
    
  } else {
    fill(200);
    text("RECORDING ON", 100, 75); //hide
    fill(#ff0000);
    text("RECORDING OFF", 100, 75); //show this
  }
}

//enable or disable recording
void recording(boolean btnEnabled) {
  if ( debug ) { println("Entering: recording(), btnEnabled: " + btnEnabled); }
  if ( btnEnabled==true ) {
      executeCommand("/home/matt/git/video-kiosk/scripts/capture.sh -b", false);
      recordingEnabled = true;
  } else {  
    //we're stopping recording
    executeCommand("/home/matt/git/video-kiosk/scripts/capture.sh -e", false);
    recordingEnabled = false;
         
  }
  if ( debug ) { println("Exiting: recording()"); }
}


/////////////////////////////////////////////////////////////////////////////

//Execute a linux command
String executeCommand(String command, boolean waitForResponse) {
  String response = "";
  ProcessBuilder pb = new ProcessBuilder("bash", "-c", command);
  pb.redirectErrorStream(true);
  System.out.println("Executing command: " + command);
  try {
    Process shell = pb.start();
    if (waitForResponse) {
      // To capture output from the shell
      InputStream shellIn = shell.getInputStream();
      // Wait for the shell to finish and get the return code
      int shellExitStatus = shell.waitFor();
      System.out.println("Exit status: " + shellExitStatus);
      response = convertStreamToStr(shellIn);
      shellIn.close();
    }
  } catch (IOException e) {
    System.out.println("Error occured while executing Linux command. Error Description: " + e.getMessage());
    System.exit(1);
  }

  catch (InterruptedException e) {
    System.out.println("Error occured while executing Linux command. Error Description: " + e.getMessage());
    System.exit(1);
  }

  return response;
}

/*
* To convert the InputStream to String we use the Reader.read(char[]
* buffer) method. We iterate until the Reader return -1 which means
* there's no more data to read. We use the StringWriter class to
* produce the string.
*/
String convertStreamToStr(InputStream is) throws IOException {

  if (is != null) {
    Writer writer = new StringWriter();
    char[] buffer = new char[1024];
    try {
      Reader reader = new BufferedReader(new InputStreamReader(is,"UTF-8"));
      int n;
      while ((n = reader.read(buffer)) != -1) {
        writer.write(buffer, 0, n);
      }
    } finally {
      is.close();
    }
    return writer.toString();
  } else {
    return "";
  }
}
