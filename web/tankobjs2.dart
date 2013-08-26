part of tankgame;



class Smoke extends GObj {
  
  static math.Random  rand = new math.Random(3000);
  
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
  
  void wobble( num range ) {
    speed.x = (rand.nextDouble() - 0.5) * range;
    speed.y = (rand.nextDouble() - 0.5) * range;
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