part of tankgame;


/** 共通で使用するテキストレンダー:通常の文字表示 */
var tren = new TextRender()
..fontFamily = fontFamily
..fontSize = "12pt"
..textAlign = "center"
..textBaseline = "middle"
..fillColor = Color.Black
..strokeColor = null;

/**
 * GameStartの表示
 */
class GameStartLogo extends GObj {
  
  void onInit() {
    // 2秒後に死す
    new Timer( const Duration(seconds:2), ()=>dispose() );
  }
  
  void onProcess(RenderList renderList) {
    renderList.add( 100, (canvas) {
      tren.canvas = canvas;
      tren.drawTexts(["GAME START"], 320, 200);
      tren.canvas = null;
    });
  }
  
  void onDispose() {}
}

class ResultPrint extends GObj {
  
  void onInit() {}
  
  void onProcess(RenderList renderList) {
    renderList.add( 100, (canvas) {
      tren.canvas = canvas;
      tren.drawTexts(["GAME OVER"], 320, 200);
      tren.drawTexts(["SCORE: ${score}"], 320, 230);
      tren.canvas = null;
    });
  }
  
  void onDispose() {}
}

/**
 * 照準カーソル
 */
class Cursor extends GObj {
  
  Sprite sp;
  
  void onInit() {
    sp = new Sprite( "tank", width:100, height:100 );
  }
  
  void onProcess(RenderList renderList) {
    renderList.add( 1000, sp.render );
  }
  
  void onDispose() {}
}

/**
 * 戦車
 */
class Tank extends GObj {
  
  int  delta_x = 1;
  Sprite sp;
  Vector  speed = new Vector();
  Vector  pos = new Vector();
  
  void onInit() {
    sp = new Sprite( "tank", width:100, height:100 );
    sp.offsety = 0;
  }
  
  void onProcess(RenderList renderList) {
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    renderList.add( 0, sp.render );
  }
  
  /** 弾を打つ */
  void fire( Point target ) {
    
    var b = new Cannonball();
    
    // 初期位置
    b.pos.set( this.pos );
    
    // 方向&スピード
    b.speed
    ..set( target )
    ..sub( b.pos )
    ..normalize()
    ..mul( 20.0 );
    b.speed.add( this.speed );
    
    // 加速度
    b.delta
    ..set( b.speed )
    ..mul( 0.0 );
    
    print( "speed=${b.speed},  delta=${b.delta}" );
    
    geng.add(b);
  }
  
  void onDispose() {
  }
}

/**
 * 砲弾
 */
class Cannonball extends GObj {
  
  /** 位置 */
  Vector  pos = new Vector();
  /** 速度 */
  Vector  speed = new Vector();
  /** 加速度 */
  Vector  delta= new Vector();
  
  Sprite sp;
  
  Timer timer;
  
  void onInit() {
    sp = new Sprite( "cannon", width:50, height:50 );
    
    // 移動ルーチン
    _move();
    timer = new Timer.periodic( const Duration(milliseconds:50), (t)=>_move() );
  }
  
  void onProcess( RenderList renderList ) {
    renderList.add( 10, sp.render );
  }
  
  void _move() {
    // 移動&加速
    pos.add( speed );
    speed.sub(delta);
    // 
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    // 画面外判定
    var r = sp.rect;
    if( geng.rect.intersects(r)==false )
      dispose();
    
    //------------
    // Targetへの当たり判定
    try {
      // 探す
      var t = geng.objlist
          .where( (e) => e.isDisposed==false && e is Target && e.isBombed==false )
          .firstWhere( (Target e) {
            var r = this.pos.distance( e.pos );
            return ( r<10.0 );
          });
      // あたった処理
      score += 100;
      t.bomb();
      dispose();
      
    } on StateError {
      // あたってねえし
    }
  }
  
  void onDispose() {
    if( timer!=null )
      timer.cancel();
  }
}

/**
 * 看板
 */
class Target extends GObj {

  Sprite sp;
  Vector pos = new Vector();
  
  bool  isBombed = false;
  
  void onInit() {
    sp = new Sprite( "target", width:80, height:80 );
  }
  
  void onProcess( RenderList renderList ) {
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    renderList.add( 5, sp.render );
  }
  
  void bomb() {
    sp.hide();
    isBombed = true;
  }
  
  void onDispose() {
  }

}
