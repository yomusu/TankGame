import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'dart:math' as math;

import 'geng.dart';
import 'vector.dart';


Tank  tank;

void main() {
  
  geng.initField( 640, 400 );
  query("#field").append( geng.element );
  
  tank = new Tank();
  tank.init();
  
  var cursor = new Cursor();
  cursor.init();
  
  Timer.run( () {
    
    // 看板を配置
    var rand = new math.Random(0);
    List<Target>  targetList = [];
    for( int x=600; x<2000; x+=200 ) {
      var y = (rand.nextDouble() * 300 ).toInt();
      Target  t = new Target();
      t.pos = new Point(x,y);
      t.init();
      targetList.add(t);
    }
    
    // フィールドにマウスリスナー
    new PressHandler( (int x, int y) {
      tank.fire( new Point(x,y) );
      print("x=$x, y=$y");
    })
    ..connect( geng.element );
    
    //---------------
    // ゲーム進行処理
    int x = 0;
    new Timer.periodic( const Duration(milliseconds:100), (Timer t) {
      
      // スクロール
      x+=2;
      
      // 的を移動
      targetList.forEach( (target) {
        target.sp.x = target.pos.x - x;
      });
      
      if( x >= 600 ) {
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
    sp = new Sprite( src:"../octocat.png" );
    sp.width = 100;
    sp.height = 100;
    sp.offset = new Point(50,50);
    geng.element.append( sp.element );
    
    new MoveHandler( (int x, int y) {
      sp.x = x;
      sp.y = y;
      sp.show();
    },
    onOut : () => sp.hide()
    )
    ..connect( geng.element );
  }
  
  void onDispose() {
    geng.element.children.remove( sp.element );
  }
}

/**
 * 戦車
 */
class Tank extends GObj {
  
  int  delta_x = 1;
  Sprite sp;
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png" );
    sp.width = 100;
    sp.height = 100;
    geng.element.append( sp.element );
    
    sp.offset = new Point(50,0);
    sp.x = 320;
    sp.y = 350;
  }
  
  /** 弾を打つ */
  void fire( Point target ) {
    
    var b = new Cannonball();
    
    // 初期位置
    b.pos.x = this.sp.x.toDouble();
    b.pos.y = this.sp.y.toDouble();
    
    // 方向
    Vector  dir = new Vector()
    ..set( target )
    ..sub( b.pos )
    ..normalize();
    
    // スピード
    b.speed
    ..set( dir )
    ..mul( 20.0 );
    
    // 加速度
    b.delta
    ..set( dir )
    ..mul( 0.0 );
    
    b.init();
  }
  
  void onDispose() {
    geng.element.children.remove( sp.element );
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
    sp = new Sprite( src:"../octocat.png" );
    sp.width = 50;
    sp.height = 50;
    geng.element.append( sp.element );
    
    sp.offset = new Point(25,25);
    
    // 移動ルーチン
    move();
    timer = new Timer.periodic( const Duration(milliseconds:50), (t)=>move() );
  }
  
  void move() {
    // 移動しました
    pos.add( speed );
    sp.x = pos.x.toInt();
    sp.y = pos.y.toInt();
    // 加速
    speed.sub(delta);
    // 画面外判定
    var r = sp.rect;
    if( geng.rect.intersects(r)==false )
      dispose();
  }
  
  void onDispose() {
    if( timer!=null )
      timer.cancel();
    geng.element.children.remove( sp.element );
  }
}

/**
 * 看板
 */
class Target extends GObj {

  Sprite sp;
  Point pos;
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png" )
    ..width = 80
    ..height = 80
    ..offset = new Point(40,40)
    ..x = pos.x
    ..y = pos.y;
    geng.element.append( sp.element );
  }
  
  void bomb() {
    
  }
  
  void onDispose() {
    geng.element.children.remove( sp.element );
    
  }

}
