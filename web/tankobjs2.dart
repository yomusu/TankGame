part of tankgame;



class Smoke extends GObj {
  
  num z = 0;
  num dOpcity;
  num dScale;
  int life;
  
  Sprite sp;
  Vector  speed = new Vector();
  Vector  pos = new Vector();
  
  Smoke();
    
  Smoke.slower() {
    sp = new Sprite.withImage("smoke", width:50, height:50);
    sp.opacity = 1.0;
    sp.scale = 0.0;
    dOpcity = -0.02;
    dScale = 0.03;
  }
  
  Smoke.faster() {
    sp = new Sprite.withImage("smoke", width:50, height:50);
    sp.opacity = 0.8;
    sp.scale = 0.4;
    dOpcity = -0.05;
    dScale = 0.05;
  }
  
  void opacityRange( num opacity, num delta ) {
    sp.opacity = 3.0;
    dOpcity = -0.1;
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
  
  void onProcess( GPInfo handle ) {
    pos.add( speed );
    
    sp.opacity += dOpcity;
    sp.scale += dScale;
    
    if( sp.opacity <= 0.0 )
      dispose();
    else {
      sp.x = pos.x - offset_x;
      sp.y = pos.y;
      
      geng.repaint();
    }
  }
  void onPrepareRender(RenderList renderList) {
    renderList.add( 50, sp.render );
  }
  
  void onDispose() {}
  
}