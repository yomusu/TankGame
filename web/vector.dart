library vector;

import 'dart:html';
import 'dart:math' as math;

class Vector {
  
  double  x;
  double  y;
  
  Vector() : x = 0.0, y = 0.0;
  
  Vector.asUnit() : x=1.0, y=0.0;
  
  Vector.fromPos( num x, num y ) {
    this.x = x.toDouble();
    this.y = y.toDouble();
  }
  
  
  void unit() {
    x = 1.0;
    y = 0.0;
  }
  
  void add( Vector v) {
    x += v.x;
    y += v.y;
  }
  
  void sub( Vector v ) {
    x -= v.x;
    y -= v.y;
  }
  
  void set( var v ) {
    
    if( v is Vector ) {
      x = v.x;
      y = v.y;
    } else if( v is Point ) {
      x = v.x.toDouble();
      y = v.y.toDouble();
    }
  }
  
  void mul( double f ) {
    x *= f;
    y *= f;
  }
  
  double scalar() {
    return math.sqrt( (x*x) + (y*y) );
  }
  
  void normalize() {
    var f = scalar();
    x /= f;
    y /= f;
  }
  
  /** th角度だけ回転する 未検査 */
  void rotate( num th ) {
    var xx = (x * math.cos(th)) - (y * math.sin(th));
    var yy = (x * math.sin(th)) + (y * math.cos(th));
    x = xx;
    y = yy;
  }
  
  double distance( Vector v ) {
    var xx = this.x - v.x;
    var yy = this.y - v.y;
    return math.sqrt((xx*xx) + (yy*yy));
  }
  
  String toString() {
    return "Vector[$x,$y]";
  }
}