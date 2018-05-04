/**
 * Splines.
 *
 * Here we use the interpolator.keyFrames() nodes
 * as control points to render different splines.
 *
 * Press ' ' to change the spline mode.
 * Press 'g' to toggle grid drawing.
 * Press 'c' to toggle the interpolator path drawing.
 */

import frames.input.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

// global variables
// modes: 0 natural cubic spline; 1 Hermite;
// 2 (degree 7) Bezier; 3 Cubic Bezier
int mode;

int points = 8;

Scene scene;
Interpolator interpolator;
OrbitNode eye;
boolean drawGrid = true, drawCtrl = true;

//Choose P3D for a 3D scene, or P2D or JAVA2D for a 2D scene
String renderer = P3D;

void setup() {
  size(800, 800, renderer);
  scene = new Scene(this);
  eye = new OrbitNode(scene);
  eye.setDamping(0);
  scene.setEye(eye);
  scene.setFieldOfView(PI / 3);
  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.setRadius(150);
  scene.fitBallInterpolation();
  interpolator = new Interpolator(scene, new Frame());
  // framesjs next version, simply go:
  //interpolator = new Interpolator(scene);

  // Using OrbitNodes makes path editable
  for (int i = 0; i < points; i++) {
    Node ctrlPoint = new OrbitNode(scene);
    ctrlPoint.randomize();
    interpolator.addKeyFrame(ctrlPoint);
  }
}

void draw() {
  background(175);
  if (drawGrid) {
    stroke(255, 255, 0);
    scene.drawGrid(200, 50);
  }
  if (drawCtrl) {
    fill(255, 0, 0);
    stroke(255, 0, 255);
    for (Frame frame : interpolator.keyFrames())
      scene.drawPickingTarget((Node)frame);
  } else {
    fill(255, 0, 0);
    stroke(255, 0, 255);
    scene.drawPath(interpolator);
  }
  // implement me
  // draw curve according to control polygon an mode
  // To retrieve the positions of the control points do:
  // for(Frame frame : interpolator.keyFrames())
  //   frame.position();
  
  float x[] = new float[points];
  float y[] = new float[points];
  float z[] = new float[points];
  
  for (int i = 0; i<interpolator.keyFrames().size(); i++) {
    Frame frame = interpolator.keyFrames().get(i);
    x[i] = frame.position().x();
    y[i] = frame.position().y();
    z[i] = frame.position().z();
  }
  
  switch (mode) {
    case 0:
      splineCubicaNatural(points, x, y, z);
      break;
    case 1:
      hermite(points, x, y, z);
      break;
    default:
      break;
  }
  
  
}

void splineCubicaNatural(int controlPoints, float x[], float y[], float z[]) {
  
  int intervals = points - 1;
  
  float ax[] = new float[controlPoints], bx[] = new float[controlPoints], cx[] = new float[controlPoints], dx[] = new float[controlPoints];
  float ay[] = new float[controlPoints], by[] = new float[controlPoints], cy[] = new float[controlPoints], dy[] = new float[controlPoints];
  float az[] = new float[controlPoints], bz[] = new float[controlPoints], cz[] = new float[controlPoints], dz[] = new float[controlPoints];
  
  float deriv[] = new float[controlPoints], gamma[] = new float[controlPoints], omega[] = new float[controlPoints]; 
  float t;
  
  //X
  
  gamma[0] = .5;
  for(int i = 1; i < intervals; ++i) gamma[i] = 1. / (4. - gamma[i-1]);
  gamma[intervals] = 1. / (2. - gamma[intervals-1]);
  
  omega[0] = 3. * (x[1]-x[0]) * gamma[0];
  for(int i = 1; i < intervals; ++i) omega[i] = (3. * (x[i+1] - x[i-1]) - omega[i-1]) * gamma[i];
  omega[intervals] = (3. * (x[intervals]-x[intervals-1]) - omega[intervals-1]) * gamma[intervals];
  
  deriv[intervals] = omega[intervals];
  for(int i = intervals-1; i>= 0; --i) deriv[i] = omega[i] - gamma[i] * deriv[i+1];
  
  for(int i = 0; i < intervals; ++i) {
    
    ax[i] = x[i];
    bx[i] = deriv[i];
    cx[i] = 3. * (x[i+1]-x[i]) - 2. * deriv[i] - deriv[i+1];
    dx[i] = 2. * (x[i] - x[i+1]) + deriv[i] + deriv[i+1];
    
  }
  
  //Y
  
  omega[0] = 3. * (y[1] - y[0]) * gamma[0];
  for (int i = 1; i < intervals; ++i) omega[i] = (3. * (y[i+1] - y[i-1]) - omega[i-1]) * gamma[i];
  omega[intervals] = (3. * (y[intervals] - y[intervals-1]) - omega[intervals-1]) * gamma[intervals];
  
  deriv[intervals] = omega[intervals];
  for (int i = intervals-1; i >= 0; --i) deriv[i] = omega[i] - gamma[i] * deriv[i+1];
  
  for (int i = 0; i<intervals; ++i) {
    ay[i] = y[i];
    by[i] = deriv[i];
    cy[i] = 3. * (y[i+1] - y[i]) -2. * deriv[i] - deriv[i+1];
    dy[i] = 2. * (y[i] - y[i+1]) + deriv[i] + deriv[i+1];
  }
  
  //Z
  
  omega[0] = 3. * (z[1] - z[0]) * gamma[0];
  for (int i = 1; i < intervals; ++i) omega[i] = (3. * (z[i+1] - z[i-1]) - omega[i-1]) * gamma[i];
  omega[intervals] = (3. * (z[intervals] - z[intervals-1]) - omega[intervals-1]) * gamma[intervals];
  
  deriv[intervals] = omega[intervals];
  for (int i = intervals-1; i >= 0; --i) deriv[i] = omega[i] - gamma[i] * deriv[i+1];
  
  for (int i = 0; i<intervals; ++i) {
    az[i] = z[i];
    bz[i] = deriv[i];
    cz[i] = 3. * (z[i+1] - z[i]) -2. * deriv[i] - deriv[i+1];
    dz[i] = 2. * (z[i] - z[i+1]) + deriv[i] + deriv[i+1];
  }
  
  float xpx, ypx, zpx;

  for (int i = 0; i < intervals+1; ++i) {
    
    float pointx = ax[i] + bx[i] + cx[i] + dx[i];
    float pointy = ay[i] + by[i] + cy[i] + dy[i];
    float pointz = az[i] + bz[i] + cz[i] + dz[i];
    
    t = 0;
    for (float j = 0; j <= 100; j+=1) {
      
      t += 1.0/100;
      
      xpx = (float)(ax[i]+bx[i]*t+cx[i]*t*t+dx[i]*t*t*t);
      ypx = (float)(ay[i]+by[i]*t+cy[i]*t*t+dy[i]*t*t*t);
      zpx = (float)(az[i]+bz[i]*t+cz[i]*t*t+dz[i]*t*t*t);
      
      line(pointx, pointy, pointz, xpx, ypx, zpx);
      
      pointx = xpx;
      pointy = ypx;
      pointz = zpx;
    }
  }
  
} 
  
void keyPressed() {
  if (key == ' ')
    mode = mode < 3 ? mode+1 : 0;
  if (key == 'g')
    drawGrid = !drawGrid;
  if (key == 'c')
    drawCtrl = !drawCtrl;
}
