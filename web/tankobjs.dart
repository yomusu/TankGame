part of tankgame;



/** 共通で使用するテキストレンダー:通常の文字表示 */
var trenScore = new TextRender()
..fontFamily = scoreFont
..fontSize = "12pt"
..textAlign = "center"
..textBaseline = "middle"
..fillColor = Color.Black
..strokeColor = null
..shadowColor = Color.White
..shadowOffset = 2
..shadowBlur = 0;


/**
 * GameStartの表示
 */
class GameStartLogo extends GObj {
  
  void onInit() {}
  
  void onProcess(RenderList renderList) {
    renderList.add( 100, (canvas) {
      trenScore.canvas = canvas;
      trenScore.drawTexts(["GAME START"], 320, 200);
      trenScore.canvas = null;
    });
  }
  
  void onDispose() {}
}

class ResultPrint extends GObj {
  
  void onInit() {}
  
  void onProcess(RenderList renderList) {
    renderList.add( 100, (canvas) {
      trenScore.canvas = canvas;
      trenScore.drawTexts(["GAME OVER"], 320, 200);
      trenScore.drawTexts(["SCORE: ${score}"], 320, 230);
      trenScore.canvas = null;
    });
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
  Vector  oldpos = new Vector();
  Vector  pos = new Vector();
  /** 速度 */
  Vector  speed = new Vector();
  /** 加速度 */
  Vector  delta= new Vector();
  
  Sprite sp;
  
  Timer timer;
  
  void onInit() {
    sp = new Sprite( "cannon", width:50, height:50 );
    sp.offsety = 0;
    
    // 移動ルーチン
    _move();
    timer = new Timer.periodic( const Duration(milliseconds:50), (t)=>_move() );
  }
  
  void onProcess( RenderList renderList ) {
    renderList.add( 10, sp.render );
  }
  
  void _move() {
    // 移動&加速
    oldpos.set( pos );
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
            return e.bomb(this);
          });
      // あたった処理
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

num getDeltaXonH( Vector pos, Vector from, Vector to ) {
  if( from.y < pos.y )
    return null;
  if( to.y > pos.y )
    return null;
  
  var dy1 = from.y - pos.y;
  var dy2 = from.y - to.y;
  
  var dx2 = to.x - from.x;
  
  var dx1 = (dy1 / dy2) * dx2;
  
  return (from.x + dx1) - pos.x;
}

/**
 * 看板
 */
class Target extends GObj {

  Sprite sp;
  Vector pos = new Vector();
  
  num   _width = 80;
  num   _hitdx = null;
  
  bool  get isBombed => _hitdx!=null;
  
  var _getScore;
  
  Target.fromType( String type ) {
    switch( type ) {
      case 'small':
        _width = 80;
        _getScore = (dx) => 100;
        break;
      case 'large':
        _width = 150;
        _getScore = (dx) {
          var d = dx.abs();
          if( d < 5 )
            return 100;
          if( d < 20 )
            return 50;
          return 10;
        };
        break;
    }
  }
  
  void onInit() {
    sp = new Sprite( "target", width:_width, height:80 );
  }
  
  void onProcess( RenderList renderList ) {
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    // スプライト登録
    renderList.add( 5, (canvas) {
      sp.render(canvas);
      // Hit mark
      if( _hitdx!=null ) {
        var hx = sp.x + _hitdx;
        var c = canvas.context2D;
        c.setFillColorRgb(255, 0, 0,1);
        c.fillRect(hx-5, sp.y-5, 10, 10);
      }
    } );
  }
  
  bool bomb( Cannonball ball ) {
    num dx = getDeltaXonH( pos, ball.oldpos, ball.pos );
    // 交差すらしていない
    if( dx==null )
      return false;
    // 交差した
    if( dx.abs() < (_width/2) ) {
      _hitdx = dx;
      
      // 得点を加算
      num s = _getScore(dx);
      score += s;
      // ポップアップ
      var pop = new ScorePopup()
      ..pos.x = pos.x + _hitdx
      ..pos.y = pos.y
      ..texts[0] = s.toString();
      geng.add( pop );
      
      // 自分飛んでく
      var ft = new FlyingTarget();
      ft.width = _width;
      ft.pos.set(pos);
      
      ft.speed
        ..x = _hitdx * -1.0
        ..y = _width.toDouble() * -1.0
        ..normalize()
        ..mul( 10.0 );
      geng.add(ft);
      
      dispose();
      
      return true;
    } else {
      return false;
    }
  }
  
  void onDispose() {}
}

/**
 * 看板
 */
class FlyingTarget extends GObj {

  Sprite sp;
  Vector pos = new Vector();
  Vector speed = new Vector();
  
  num   dRotate = math.PI/180.0 * 24;
  num   width = 80;
  
  void onInit() {
    sp = new Sprite( "target", width:width, height:80 );
    sp.rotate = 0.0;
    
    new Timer( const Duration(seconds:2), ()=>dispose() );
  }
  
  void onProcess( RenderList renderList ) {
    pos.add( speed );
    sp.rotate += dRotate;
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    // スプライト登録
    renderList.add( 5, sp.render );
  }
  
  void onDispose() {}
}

/**
 * 地面
 */
class Ground extends GObj {
  
  List<Point>  points = new List();

  void onInit() {
    var rand = new math.Random(0);
    for( int y=0; y<400; y+=200 ) {
      for( int x=0; x<1600; x+=200 ) {
        var _x = x + rand.nextInt(200) - 100;
        var _y = y + rand.nextInt(200) - 100;
        points.add( new Point(_x,_y) );
      }
    }
  }
  
  void onProcess( RenderList renderList ) {
    var z = 0;
    renderList.add( z, draw );
  }
  
  void draw( CanvasElement canvas ) {
    var img = geng.imageMap["kusa"];
    var c = canvas.context2D;
    points.forEach( (p) {
      var x = p.x - offset_x;
      var y = p.y;
      c.drawImageScaled(img, x, y, 50, 50);
    });
  }
  
  void onDispose() {
    points.clear();
  }
  
}

class ScorePopup extends GObj {
  
  Vector pos = new Vector();
  Vector speed = new Vector();
  Vector delta = new Vector();
  
  /** Zはこちら */
  num z = 60;
  
  /** テキストは複数セットできる */
  List<String>  texts = [""];
  
  /** テキストを1行だけセットするとき用 */
  set text( String str ) => texts[0] = str;
  
  void onInit() {
    
    speed..y = -5.0;
    delta..y = 0.2;
    
    // 1秒で消えます
    new Timer( const Duration(seconds:1), ()=>dispose() );
  }
  
  void onProcess( RenderList renderList ) {
    
    // 動き
    pos.add( speed );
    speed.add( delta );
    
    // 座標変換
    var x = pos.x - offset_x;
    var y = pos.y;
    
    renderList.add( z, (canvas) {
      var c = canvas.context2D;
      trenScore.canvas = canvas;
      trenScore.drawTexts( texts, x, y);
      trenScore.canvas = null;
    });
  }
  
  void onDispose() {}
}
