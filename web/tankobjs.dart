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
      canvas.drawTexts(trenScore, ["GAME START"], 320, 200);
    });
  }
  
  void onDispose() {}
}

class ResultPrint extends GObj {
  
  void onInit() {}
  
  void onProcess(RenderList renderList) {
    renderList.add( 100, (canvas) {
      canvas.drawTexts( trenScore, ["GAME OVER"], 320, 200);
      canvas.drawTexts( trenScore, ["SCORE: ${score}"], 320, 230);
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
  int count = 0;
  
  void onInit() {
    sp = new Sprite( "tank", width:100, height:100 );
    sp.offsety = 0;
  }
  
  void onProcess(RenderList renderList) {
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    renderList.add( 0, sp.render );
    
    if( ++count==7 ) {
      count = 0;
      Smoke smk = new Smoke.slower()
      ..pos.x = pos.x
      ..pos.y = pos.y + 90
      ..z = 10
      ..wobble( R180, R180+(R90/2.0) );
      geng.objlist.add( smk );
    }
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
    
    geng.objlist.add(b);
    
    geng.soundManager.play("fire");
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
  
  void onInit() {
    
    var f = (GCanvas2D c,Sprite sp) {
      c.circle(0, 0, 10);
      c.fill( Color.Black );
      c.beginPath();
      c.circle(-4, -4, 2);
      c.fill( Color.White );
    };
    sp = new Sprite.withRender(f, width:20, height:20 );
    sp.offsety = 0;
  }
  
  void onProcess( RenderList renderList ) {
    
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
          .where( (e) => e is Target && e.isBombed==false )
          .firstWhere( (Target e) {
            return e.bomb(this);
          });
      // あたった処理
      dispose();
      
    } on StateError {
      // あたってねえし
    }
    
    renderList.add( 10, sp.render );
    
    // 煙を出す
    if( ++count==2 ) {
      count = 0;
      
      var smk = new Smoke.faster()
      ..pos.x = pos.x
      ..pos.y = pos.y;
      
      geng.objlist.add(smk);
    }
  }
  
  int count = 0;
  
  void onDispose() {}
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
        _width = 50;
        _getScore = (dx) => 100;
        break;
      case 'large':
        _width = 100;
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
        canvas.c.setFillColorRgb(255, 0, 0,1);
        canvas.c.fillRect(hx-5, sp.y-5, 10, 10);
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
      geng.objlist.add( pop );
      
      // 自分飛んでく
      var ft = new FlyingTarget();
      ft.width = _width;
      ft.pos.set(pos);
      
      ft.speed
        ..x = _hitdx * -1.0
        ..y = _width.toDouble() * -1.0
        ..normalize()
        ..mul( 10.0 );
      geng.objlist.add(ft);
      
      // 爆発を配置
      var range = R45 * 0.5;
      for( num r in [-R45,-R90,-R90-R45] ) {
        var bomb = new Bomb(r,range);
        bomb.pos.set(pos);
        geng.objlist.add( bomb );
      }
      
      dispose();
      
      geng.soundManager.play("bomb");
      
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
 * 爆発
 */
class Bomb extends GObj {

  Sprite sp;
  Vector pos = new Vector();
  Vector speed = new Vector();
  Vector delta = new Vector();
  
  num dRotate;
  num size = 25;
  
  Bomb( num angle, num range ) {
    dRotate = geng.randRange( R1*6, R1*24 );
    var a = geng.randRange( angle - range, angle + range );
    speed
    ..unit()
    ..mul( 5.0 )
    ..rotate( a );
    
    delta
    ..y = 0.1;
    
  }
  
  void onInit() {
    sp = new Sprite( "target", width:25, height:25 );
    sp.rotate = 0.0;
    
    new Timer( const Duration(seconds:1), ()=>dispose() );
  }
  
  int count =100;
  
  void onProcess( RenderList renderList ) {
    
    // 煙吐き出す
    if( ++count>=10 ) {
      count = 0;
      var smoke = new Smoke()
      ..sp = new Sprite( "smoke", width:10, height:10)
      ..opacityRange( 3.0, -0.1 )
      ..scaleRange( 1.0, 0.02 )
      ..pos.x = pos.x
      ..pos.y = pos.y
      ..z = 10
      ..scaleRange( 1.0, 0.4 );
      geng.objlist.add( smoke );
    }
    
    pos.add( speed );
    speed.add( delta );
    
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
  
  List  points = new List();
  
  num z = 0;
  num translateX = 0;
  
  num marginH = 50;
  num marginV = 0;
  
  num width;
  num height;
  
  num get left => -marginH;
  num get top => -marginV;
  
  void onInit() {
    
    width = geng.rect.width + (marginH*2);
    height= geng.rect.height+ (marginV*2);
    
    points = [
      [79,10],   [193,50],   [477,30],   [607,60],
      [150,200], [292,162],  [427,239],  [559,110],
      [18,306],  [252,252],  [384,290],  [635,325],
    ];
  }
  
  void onProcess( RenderList renderList ) {
    renderList.add( z, (GCanvas2D c) {
      
      var img = geng.imageMap["kusa"];
      
      c.c.save();
      c.c.translate( left, 0 );
      
      points.forEach( (p) {
        
        var x = p[0] - translateX;
        var y = p[1] * 1.5;
        
        x = x % width;
        y = y % height;
        
        c.c.drawImageScaled(img, x, y, 50, 50);
      });
      
      c.c.restore();
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
    
    speed..y = -4.0;
    delta..y = 0.1;
    
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
      canvas.drawTexts( trenScore, texts, x, y);
    });
  }
  
  void onDispose() {}
}
