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
      System.out.println("Natural");
      splineCubicaNatural(points, x, y, z);
      break;
    case 1:
      System.out.println("Hermite");
      hermite(points, x, y, z);
      break;
    case 2:
      //Cada cuatro puntos de control
      System.out.println("Bezier Cubico Implementado");
      bezierImpl(0, x, y, z);
      bezierImpl(4, x, y, z);
      break;
    case 3:
      System.out.println("Bezier de processing");
      bezier(x[0], y[0], z[0], x[1], y[1], z[1], x[2], y[2], z[2], x[3], y[3], z[3]);
      bezier(x[4], y[4], z[4], x[5], y[5], z[5], x[6], y[6], z[6], x[7], y[7], z[7]);
      break;
    case 4:
      System.out.println("Bezier de grado 7");
      bezierGrado7(0, x, y, z);
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
  float pointx;
  float pointy;
  float pointz;

  for (int i = 0; i < intervals+1; ++i) {
    
    pointx = ax[i] + bx[i] + cx[i] + dx[i];
    pointy = ay[i] + by[i] + cy[i] + dy[i];
    pointz = az[i] + bz[i] + cz[i] + dz[i];
    
    t = 0;
    for (float j = 0; j <= 100; ++j) {
      
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

void hermite(int controlPoints, float x[], float y[], float z[]) {
 
  //4 Valores 
  float[] xk_x = new float[controlPoints], xk1_x = new float[controlPoints], dk_x = new float[controlPoints], dk1_x = new float[controlPoints];
  float[] xk_y = new float[controlPoints], xk1_y = new float[controlPoints], dk_y = new float[controlPoints], dk1_y = new float[controlPoints];
  float[] xk_z = new float[controlPoints], xk1_z = new float[controlPoints], dk_z = new float[controlPoints], dk1_z = new float[controlPoints];
  
  for (int i = 0; i < controlPoints-1; ++i) {
  
      //Pk y Pk+1
      xk_x[i] = x[i];
      xk1_x[i] = x[i+1];
      xk_y[i] = y[i];
      xk1_y[i] = y[i+1];
      xk_z[i] = z[i];
      xk1_z[i] = z[i+1];
      
      //Derivs Dk y Dk+1
      if (i == 0) {
        dk_x[i] = x[i+1] - x[i];
        dk1_x[i] = (x[i+2] - x[i])/2;
        dk_y[i] = y[i+1] - y[i];
        dk1_y[i] = (y[i+2] - y[i])/2;
        dk_z[i] = z[i+1] - z[i];
        dk1_z[i] = (z[i+2] - z[i])/2;
      }else if (i == controlPoints - 2) {
        dk_x[i] = (x[i+1] - x[i-1])/2;
        dk1_x[i] = (x[i+1] - x[i]);
        dk_y[i] = (y[i+1] - y[i-1])/2;
        dk1_y[i] = (y[i+1] - y[i]);
        dk_z[i] = (z[i+1] - z[i-1])/2;
        dk1_z[i] = (z[i+1] - z[i]);
      }else {
        dk_x[i] = (x[i+1] - x[i-1])/2;
        dk1_x[i] = (x[i+2] - x[i])/2;
        dk_y[i] = (y[i+1] - y[i-1])/2;
        dk1_y[i] = (y[i+2] - y[i])/2;
        dk_z[i] = (z[i+1] - z[i-1])/2;
        dk1_z[i] = (z[i+2] - z[i])/2;
      }
      
      
      float xa = x[i], ya = y[i], za = z[i];
      float xb,yb,zb;
      float t = 0;
      
      for (float j = 0; j<=100; ++j) {
        t += 1.0/100;
        
        xb = xk_x[i] * (2*t*t*t-3*t*t+1) + dk_x[i] * (t*t*t - 2*t*t + t) + xk1_x[i] * (-2*t*t*t+3*t*t) + dk1_x[i] * (t*t*t-t*t);
        yb = xk_y[i] * (2*t*t*t-3*t*t+1) + dk_y[i] * (t*t*t - 2*t*t + t) + xk1_y[i] * (-2*t*t*t+3*t*t) + dk1_y[i] * (t*t*t-t*t);
        zb = xk_z[i] * (2*t*t*t-3*t*t+1) + dk_z[i] * (t*t*t - 2*t*t + t) + xk1_z[i] * (-2*t*t*t+3*t*t) + dk1_z[i] * (t*t*t-t*t);
        
        line(xa, ya, za, xb, yb ,zb); 
        
        xa = xb;
        ya = yb;
        za = zb;
        
      }
  }
}

void bezierImpl(int i, float x[], float y[], float z[]) {
  
    //https://visualcomputing.github.io/Curves/#/6/6
    float xa = x[i], ya = y[i], za = z[i];
    float xb,yb,zb;
    float t = 0;
    for (float j = 0; j<=100; ++j) {
      t += 1.0/100;

      xb = x[i]*(1-t)*(1-t)*(1-t) + x[i+1]*3*t*(1-t)*(1-t) + x[i+2]*3*t*t*(1-t) + x[i+3]*(t*t*t);
      yb = y[i]*(1-t)*(1-t)*(1-t) + y[i+1]*3*t*(1-t)*(1-t) + y[i+2]*3*t*t*(1-t) + y[i+3]*(t*t*t);
      zb = z[i]*(1-t)*(1-t)*(1-t) + z[i+1]*3*t*(1-t)*(1-t) + z[i+2]*3*t*t*(1-t) + z[i+3]*(t*t*t);

      line(xa, ya, za, xb, yb ,zb); 
      
      xa = xb;
      ya = yb;
      za = zb;
    }
}

void bezierGrado7(int i, float x[], float y[], float z[]) {
  
    //https://es.wikipedia.org/wiki/Curva_de_B%C3%A9zier#Generalizaci%C3%B3n
    float xa = x[i], ya = y[i], za = z[i];
    float xb,yb,zb;
    float t = 0;
    for (float j = 0; j<=100; ++j) {
      t += 1.0/100;

      xb = x[i]*pow((1-t),7) + 7*x[i+1]*t*pow((1-t),6) + 21*x[i+2]*pow(t,2)*pow((1-t),5) + 35*x[i+3]*pow(t,3)*pow((1-t),4) 
          + 35*x[i+4]*pow(t,4)*pow((1-t),3) + 21*x[i+5]*pow(t,5)*pow((1-t),2) + 7*x[i+6]*pow(t,6)*(1-t) + x[i+7]*pow(t,7);
      yb = y[i]*pow((1-t),7) + 7*y[i+1]*t*pow((1-t),6) + 21*y[i+2]*pow(t,2)*pow((1-t),5) + 35*y[i+3]*pow(t,3)*pow((1-t),4) 
          + 35*y[i+4]*pow(t,4)*pow((1-t),3) + 21*y[i+5]*pow(t,5)*pow((1-t),2) + 7*y[i+6]*pow(t,6)*(1-t) + y[i+7]*pow(t,7);
      zb = z[i]*pow((1-t),7) + 7*z[i+1]*t*pow((1-t),6) + 21*z[i+2]*pow(t,2)*pow((1-t),5) + 35*z[i+3]*pow(t,3)*pow((1-t),4) 
          + 35*z[i+4]*pow(t,4)*pow((1-t),3) + 21*z[i+5]*pow(t,5)*pow((1-t),2) + 7*z[i+6]*pow(t,6)*(1-t) + z[i+7]*pow(t,7);
      
      line(xa, ya, za, xb, yb ,zb); 
      
      xa = xb;
      ya = yb;
      za = zb;
    }
}


void changePoints() {
  interpolator = new Interpolator(scene, new Frame());
  for (int i = 0; i < points; i++) {
    Node ctrlPoint = new OrbitNode(scene);
    ctrlPoint.randomize();
    interpolator.addKeyFrame(ctrlPoint);
  }
}  
  
  
void keyPressed() {
  if (key == ' ')
    mode = mode < 4 ? mode+1 : 0;
  if (key == 'g')
    drawGrid = !drawGrid;
  if (key == 'c')
    drawCtrl = !drawCtrl;
  if (key == 'r')
    changePoints();
}
