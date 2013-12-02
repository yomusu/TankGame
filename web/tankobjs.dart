part of tankgame;



/**
 * GameStartの表示
 */
class GameStartLogo extends GObj {
  
  void onInit() {}
  
  void onProcess( GPInfo handle ) {
    
  }
  void onPrepareRender(RenderList renderList) {
    renderList.add( 100, (canvas) {
      canvas.drawTexts(trenScore, ["GAME START"], 285, 200);
    });
  }
  
  void onDispose() {}
}

/**
 * 戦車
 */
class Tank extends GObj {
  
  int  delta_x = 1;
  ImageSprite sp2;
  Vector  speed = new Vector();
  Vector  pos = new Vector();
  int count = 0;
  
  var anime;
  var animeTimer;
  
  void onInit() {
    
    var imgs = [ geng.imageMap["tank01"], geng.imageMap["tank02"] ];
    
    sp2 = new ImageSprite( img:imgs[0], width:130, height:130 );
    sp2.offsety = 0;
    
    // アニメのセット
    var imgIndex = 0;
    animeTimer = new Timer.periodic(const Duration(milliseconds:400), (t) {
      imgIndex++;
      if( imgIndex >= imgs.length )
        imgIndex = 0;
      sp2.image = imgs[imgIndex];
    });
  }
  
  void onProcess(GPInfo handle) {
    
    sp2.x = pos.x - offset_x;
    sp2.y = pos.y;
    
    // 砂煙
    if( ++count==20 ) {
      count = 0;
      Smoke smk = new Smoke.slower()
      ..pos.x = pos.x
      ..pos.y = pos.y + 130
      ..z = 10
      ..wobble( R180, R180+(R90/2.0) );
      geng.objlist.add( smk );
    }
  }
  void onPrepareRender(RenderList renderList) {
    renderList.add( 10, sp2.render );
  }
  
  /** 弾を打つ */
  void fire( Point target ) {
    
    var cannonSpeed = 20.0;
    if( itemData.containsKey('cannonSpeed') ) {
      cannonSpeed = (itemData['cannonSpeed'] as num).toDouble();
    }
    var cannonSize = (itemData['cannonSize'] as num).toInt();
    
    var b = new Cannonball();
    
    b.size = cannonSize;
    
    // 初期位置
    b.pos.set( this.pos );
    
    // 方向&スピード
    b.speed
    ..set( target )
    ..sub( b.pos )
    ..normalize()
    ..mul( cannonSpeed );
    b.speed.add( this.speed );
    
    // 加速度
    b.delta
    ..set( b.speed )
    ..mul( 0.0 );
    
    geng.objlist.add(b);
    
    // 発射炎
    var sm = new Smoke()
    ..sp = new Sprite.withImage("smoke", width:50, height:50)
    ..sp.opacity = 1.0
    ..sp.scale = 0.5
    ..dOpcity = -0.02
    ..dScale = 0.03
    ..pos.set( this.pos );
    geng.objlist.add(sm);
    
    geng.soundManager.play("fire");
  }
  
  void onDispose() {
    animeTimer.cancel();
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
  int size = 10;
  
  void onInit() {
    sp = new Sprite.withImage("tama", width: size, height: size);
    sp.offsety = 0;
  }
  
  void onProcess( GPInfo handle ) {
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
  }
  void onPrepareRender( RenderList renderList ) {
    renderList.add( 10, sp.render );
  }
  
  num distance = 0.0;
  
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
  
  List<int> bombTypes;
  
  Target.fromType( String type ) {
    switch( type ) {
      case 'small':
        _width = 25;
        sp = new ImageSprite( imgKey:"targetS", width:60, height:120 );
        bombTypes = [0,1,3,4,3,4];
        break;
      case 'large':
        _width = 65;
        sp = new ImageSprite( imgKey:"targetL", width:120, height:120 );
        bombTypes = [0,1,2,0,1,3,4,3,4,3,4,3];
        break;
    }
  }
  
  void onInit() {
  }
  
  void onProcess( GPInfo handle ) {
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
  }
  void onPrepareRender( RenderList renderList ) {
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
    if( dx.abs() < (_width/2)+(ball.size~/2) ) {
      _hitdx = dx;
      
      // 爆発を配置
      var range = R90 * 0.5;
      for( var type in bombTypes ) {
        var bomb = new Bomb(type, -R90,range);
        bomb.pos.set(pos);
        geng.objlist.add( bomb );
      }
      
      dispose();
      
      geng.soundManager.play("bomb");
      
      // ヒット数Increment
      numberOfHit++;
      
      return true;
    } else {
      return false;
    }
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
  
  Bomb( int type, num angle, num range ) {
    var a = geng.randRange( -(R1*30), -(R180-(R1*30)) );
    speed
    ..unit()
    ..mul( geng.randRange( 3.0, 10.0 ) )
    ..rotate( a );
    
    delta
    ..y = 0.1;
    
    var scale = 0.3;
    switch( type ) {
      case 0:
        dRotate = geng.randRange( R1*6, R1*20 );
        sp = new ImageSprite( imgKey:"gareki01", width:174*scale, height:206*scale );
        break;
      case 1:
        dRotate = geng.randRange( R1*6, R1*20 );
        sp = new ImageSprite( imgKey:"gareki02", width:139*scale, height:176*scale );
        break;
      case 2:
        dRotate = geng.randRange( R1*6, R1*20 );
        sp = new ImageSprite( imgKey:"gareki03", width:150*scale, height:188*scale );
        break;
      case 3:
        dRotate = geng.randRange( R1*6, R1*24 );
        sp = new ImageSprite( imgKey:"star01", width:35*0.5, height:35*0.5 );
        break;
      case 4:
        dRotate = 0;
        sp = new ImageSprite( imgKey:"ball01", width:34*0.5, height:34*0.5 );
        break;
    }
  }
  
  void onInit() {
    sp.rotate = 0.0;
    
    new Timer( const Duration(milliseconds:1500), ()=>dispose() );
  }
  
  int count =100;
  
  void onProcess( GPInfo handle ) {
    pos.add( speed );
    speed.add( delta );
    
    sp.rotate += dRotate;
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    
    geng.repaint();
  }
  
  void onPrepareRender( RenderList renderList ) {
    renderList.add( 5, sp.render );
  }
  
  void onDispose() {}
}


/**
 * 地面
 */
class Ground extends GObj {
  
  List  points01 = new List();
  List  points02 = new List();
  
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
    
    points01 = [
      [79,10],   [477,30], 
      [150,200], [427,239],
      [18,306],  [384,290],
    ];
    points02 = [
      [193,50],  [607,60],
      [292,162], [559,110],
      [252,252], [635,325],
    ];
  }
  
  void onProcess( GPInfo handle ) {
    
  }
  void onPrepareRender( RenderList renderList ) {
    renderList.add( z, (GCanvas2D c) {
      
      var img01 = geng.imageMap["snow01"];
      var img02 = geng.imageMap["snow02"];
      
      c.c.save();
      c.c.translate( left, 0 );
      
      points01.forEach( (p) {
        
        var x = p[0] - translateX;
        var y = p[1] * 1.5;
        
        x = x % width;
        y = y % height;
        
        c.c.drawImageScaled(img01, x, y, 42, 10);
      });
      
      points02.forEach( (p) {
        
        var x = p[0] - translateX;
        var y = p[1] * 1.5;
        
        x = x % width;
        y = y % height;
        
        c.c.drawImageScaled(img02, x, y, 24, 6);
      });
      
      c.c.restore();
    });
  }
  
  void onDispose() {
    points01.clear();
    points02.clear();
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
  
  void onProcess( GPInfo handle ) {
    
    // 動き
    pos.add( speed );
    speed.add( delta );
    
    geng.repaint();  
  }
  void onPrepareRender( RenderList renderList ) {
    // 座標変換
    var x = pos.x - offset_x;
    var y = pos.y;
    
    renderList.add( z, (canvas) {
      canvas.drawTexts( trenScore, texts, x, y);
    });
  }
  
  void onDispose() {}
}
