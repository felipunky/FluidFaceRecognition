// FACE RECOGNITION 
import processing.video.*; 
import gab.opencv.*;
import java.awt.Rectangle;
// FLUID SIMULATION EXAMPLE
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
// MICROPHONE
import ddf.minim.*;

// fluid simulation
DwFluid2D fluid;

// render target
PGraphics2D pg_fluid;

// Import OpenCV and create a camera object
Capture cam; 
OpenCV opencv;

// Import Minim and create the object
Minim minim;
AudioInput in;

// Initialize the face recognition center
float xPos = 0.0;
float yPos = 0.0;

// Initialize the microphone's fft's
float wav = 0.0;
float fre = 0.0;

void setup() 
{ 

  size(640, 480, P2D);

  cam = new Capture(this, width, height, 30); 
  opencv = new OpenCV(this, width, height); 
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  cam.start();
  
  // library context
  DwPixelFlow context = new DwPixelFlow(this);

  // fluid simulation
  fluid = new DwFluid2D(context, width, height, 1);

  // some fluid parameters
  fluid.param.dissipation_velocity = 0.70f;
  fluid.param.dissipation_density  = 0.99f;
  
  // Initialize minim
  minim = new Minim(this);
  
  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();
  
  frameRate(1000);

}

void draw() { 

  if (cam.available() == true)
  {

    cam.read();
  }

  pushMatrix(); 
  scale(-1, 1); 
  translate(-cam.width, 0);
  image(cam, 0, 0); 
  popMatrix();

  opencv.loadImage(cam); 
  Rectangle[] faces = opencv.detect();

  float x = 0.0;
  float y = 0.0;
  
  // Traverse the camera input for the face recognition
  for (int i = 0; i < faces.length; i++) 
  {

    x = ( cam.width - faces[i].x - faces[i].width );
    y = faces[i].y;
    xPos = x + ( faces[i].width / 2.0 );
    yPos = y + ( faces[i].height / 2.0 );

  }
  
  // Traverse the mic data to get the fft's
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
  
    fre = ( in.left.get(i) ) * 500.0;
    wav = ( in.right.get(i) ) * 500.0;
  
  }
  
  // adding data to the fluid simulation
  fluid.addCallback_FluiData(new  DwFluid2D.FluidData() {
    public void update(DwFluid2D fluid) {
      float px     = xPos;
      float py     = height-yPos;
      float vx     = (xPos) + random( xPos );
      float vy     = (yPos) - random( yPos );
      fluid.addVelocity(px, py, 14 + wav, vx, vy);
      fluid.addDensity (px, py, 20, 0.0f, 0.4f, fre * 10.0, 1.0f);
      fluid.addDensity (px, py, 8, wav * 10.0, 1.0f, 1.0f, 1.0f);
    }
  });

  pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
  
  // update simulation
  fluid.update();

  // clear render target
  pg_fluid.beginDraw();
  pg_fluid.background(0);
  pg_fluid.endDraw();

  // render fluid stuff
  fluid.renderFluidTextures(pg_fluid, 0);

  // display
  image(pg_fluid, 0, 0);
  
  println(frameRate);
  
}
