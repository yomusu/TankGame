library vector;

import 'dart:html';
import 'dart:math' as math;

class Vector {
  
  double  x;
  double  y;
  
  Vector() {
    this.x = 0.0;
    this.y = 0.0;
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
}