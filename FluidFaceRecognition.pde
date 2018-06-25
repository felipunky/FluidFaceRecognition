import processing.video.*; 
import gab.opencv.*;
import java.awt.Rectangle;

Capture cam; 
OpenCV opencv;

ArrayList<Particle> particles;

void setup() 
{ 

  size(640, 480);

  cam = new Capture(this, width, height, 30); 
  opencv = new OpenCV(this, width, height); 
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  cam.start();

  particles = new ArrayList<Particle>();
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

  noFill(); 
  stroke(0, 255, 0); 
  strokeWeight(3); 

  float x = 0.0;
  float y = 0.0;
  float xPos = 0.0;
  float yPos = 0.0;

  for (int i = 0; i < faces.length; i++) 
  {

    x = ( cam.width - faces[i].x - faces[i].width );
    y = faces[i].y;
    xPos = x + ( faces[i].width / 2.0 );
    yPos = y + ( faces[i].height / 2.0 );
    rect(x, y, faces[i].width, faces[i].height);

  }
  
  particles.add(new Particle(new PVector( xPos, yPos )));

  for (int j = 0; j < particles.size(); j++) 
  {
  
    Particle p = particles.get(j);
    p.run();

  }
  
}
