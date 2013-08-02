import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'dart:math' as math;

import 'geng.dart';
import 'vector.dart';


Tank  tank;

double  offset_x = 0.0;

void main() {
  
  geng.initField( 640, 400 );
  query("#field").append( geng.canvas );
  
  tank = new Tank();
  // 戦車の初期位置
  tank.pos
    ..x = 320.0
    ..y = 300.0;
  tank.init();
  
  var cursor = new Cursor();
  cursor.init();
  
  Timer.run( () {
    
    // 看板を配置
    var rand = new math.Random(0);
    for( int x=600; x<2000; x+=200 ) {
      var y = rand.nextDouble() * 300;
      Target  t = new Target()
      ..pos.x = x.toDouble()
      ..pos.y = y
      ..init();
    }
    
    //---------------------
    // フィールドのクリック処理
    new PressHandler( (int sx, int sy) {
      var x = offset_x + sx;
      tank.fire( new Point(x,sy) );
      print("x=$x, y=$sy, offset_x=$offset_x, sx=$sx");
    })
    ..connectTo( geng.canvas );
    
    //---------------
    // ゲーム進行処理
    offset_x = 0.0;
    new Timer.periodic( const Duration(milliseconds:50), (Timer t) {
      
      // スクロール
      offset_x += 2.0;
      
      // 戦車移動
      tank.pos.x += 2.0;
      
      // 戦車  砲弾  的を移動
      geng.renderAll();
      
      geng.gcObj();
      
      if( offset_x >= 600 ) {
        // ステージ終了処理
        t.cancel();
      }
    });
  });
}

/**
 * 照準カーソル
 */
class Cursor extends GObj {
  
  Sprite sp;
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png", width:100, height:100 );
    sp.offset = new Point(50,50);
    
    new MoveHandler( (int x, int y) {
      sp.x = x;
      sp.y = y;
      sp.show();
    },
    onOut : () => sp.hide()
    )
    ..connect( geng.canvas );
  }
  
  void onRender() {
    sp.render(geng.canvas);
  }
  
  void onDispose() {
  }
}

/**
 * 戦車
 */
class Tank extends GObj {
  
  int  delta_x = 1;
  Sprite sp;
  Vector  pos = new Vector();
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png", width:100, height:100 );
    sp.offset = new Point(50,0);
  }
  
  void onRender() {
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    geng.render( sp );
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
    
    // 加速度
    b.delta
    ..set( b.speed )
    ..mul( 0.0 );
    
    print( "speed=${b.speed},  delta=${b.delta}" );
    
    b.init();
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
    sp = new Sprite( src:"../octocat.png", width:50, height:50 );
    
    sp.offset = new Point(25,25);
    
    // 移動ルーチン
    _move();
    timer = new Timer.periodic( const Duration(milliseconds:50), (t)=>_move() );
  }
  
  void onRender() {
    geng.render( sp );
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
          .where( (e) => e.isDisposed==false && e is Target )
          .firstWhere( (Target e) {
            var r = this.pos.distance( e.pos );
            return ( r<10.0 );
          });
      // あたった処理
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
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png" , width:80, height:80 )
    ..offset = new Point(40,40);
  }
  
  void onRender() {
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    geng.render( sp );
  }
  
  void bomb() {
    sp.hide();
  }
  
  void onDispose() {
  }

}
