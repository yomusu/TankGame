part of tankgame;



class Smoke extends GObj {
  
  num z = 0;
  num dOpcity;
  num dScale;
  int life;
  
  Sprite sp;
  Vector  speed = new Vector();
  Vector  pos = new Vector();
  
  Smoke.slower() {
    sp = new Sprite( "smoke", width:50, height:50);
    sp.opacity = 1.0;
    sp.scale = 0.0;
    dOpcity = -0.02;
    dScale = 0.03;
  }
  
  Smoke.faster() {
    sp = new Sprite( "smoke", width:50, height:50);
    sp.opacity = 0.8;
    sp.scale = 0.4;
    dOpcity = -0.05;
    dScale = 0.05;
  }
  
  Smoke.bigger( { num width, num height } ) {
    sp = new Sprite( "smoke", width:width, height:height);
    sp.opacity = 3.0;
    sp.scale = 1.0;
    dOpcity = -0.1;
    dScale = 0.05;
  }
  
  void scaleRange( num from, num delta ) {
    sp.scale = from;
    dScale = delta;
  }
  
  void wobble( num angle1, num angle2 ) {
    speed.unit();
    
    var r = geng.rand.nextDouble();
    var rot = (angle1 * r) + (angle2 * (1.0-r) );
    speed.rotate( rot );
    
    speed.mul(0.5);
  }
  
  void onInit() {}
  
  void onProcess(RenderList renderList) {
    
    pos.add( speed );
    
    sp.opacity += dOpcity;
    sp.scale += dScale;
    
    if( sp.opacity <= 0.0 )
      dispose();
    else {
      sp.x = pos.x - offset_x;
      sp.y = pos.y;
    
      renderList.add( 50, sp.render );
    }
  }
  
  void onDispose() {}
  
}