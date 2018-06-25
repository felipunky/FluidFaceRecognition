import processing.video.*; 
import gab.opencv.*;
import java.awt.Rectangle;
// FLUID SIMULATION EXAMPLE
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;

// fluid simulation
DwFluid2D fluid;

// render target
PGraphics2D pg_fluid;

Capture cam; 
OpenCV opencv;

float xPos = 0.0;
float yPos = 0.0;

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

  for (int i = 0; i < faces.length; i++) 
  {

    x = ( cam.width - faces[i].x - faces[i].width );
    y = faces[i].y;
    xPos = x + ( faces[i].width / 2.0 );
    yPos = y + ( faces[i].height / 2.0 );

  }
  
  // adding data to the fluid simulation
  fluid.addCallback_FluiData(new  DwFluid2D.FluidData() {
    public void update(DwFluid2D fluid) {
      float px     = xPos;
      float py     = height-yPos;
      float vx     = (xPos) * +15;
      float vy     = (yPos) * -15;
      fluid.addVelocity(px, py, 14, vx, vy);
      fluid.addDensity (px, py, 20, 0.0f, 0.4f, 1.0f, 1.0f);
      fluid.addDensity (px, py, 8, 1.0f, 1.0f, 1.0f, 1.0f);
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
