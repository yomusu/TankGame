import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'dart:math' as math;

import 'geng.dart';
import 'vector.dart';


Tank  tank;
int score;
double  offset_x = 0.0;

void main() {
  
  geng.initField( 640, 400 );
  query("#field").append( geng.canvas );
  
  tank = new Tank();
  // 戦車の初期位置
  tank.pos
    ..x = 320.0
    ..y = 300.0;
  tank.speed
    ..x = 2.0;
  tank.init();
  
  var cursor = new Cursor();
  cursor.init();
  
  Timer.run( () {
    
    // スコアをクリア
    score = 0;
    
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
    var clickStream = geng.onPress.listen( (e) {
      var x = offset_x + e.x;
      var y = e.y;
      tank.fire( new Point(x,e.y) );
      print("x=$x, y=$y, offset_x=$offset_x, sx=${e.x}");
    });
    
    //---------------
    // ゲーム進行処理
    offset_x = 0.0;
    new Timer.periodic( const Duration(milliseconds:50), (Timer t) {
      
      // 戦車移動
      tank.pos.add( tank.speed );
      
      // 画面表示位置
      offset_x = math.max( 320.0, tank.pos.x - 320.0 );
      
      // 戦車  砲弾  的を移動
      geng.renderAll();
      drawScore();
      geng.gcObj();
      
      if( offset_x >= 1000 ) {
        // ステージ終了処理
        t.cancel();
        clickStream.cancel();
        
        var c = geng.canvas.context2D;
        c.lineWidth = 1.0;
        c.textAlign = "center";
        c.textBaseline = "middle";
        c.setStrokeColorRgb(0, 0, 0, 1);
        c.strokeText("GAME OVER", 320, 200);
        c.strokeText("SCORE: ${score}", 320, 230);
      }
    });
  });
}

void drawScore() {
  var c = geng.canvas.context2D;
  c.lineWidth = 1.0;
  c.textAlign = "left";
  c.textBaseline = "top";
  c.setStrokeColorRgb(0, 0, 0, 1);
  c.strokeText("SCORE: ${score}", 0, 0, 100);
}

/**
 * 照準カーソル
 */
class Cursor extends GObj {
  
  Sprite sp;
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png", width:100, height:100 );
    
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
  Vector  speed = new Vector();
  Vector  pos = new Vector();
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png", width:100, height:100 );
    sp.offsety = 0;
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
    b.speed.add( this.speed );
    
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
    sp = new Sprite( src:"../octocat.png" , width:80, height:80 );
  }
  
  void onRender() {
    sp.x = pos.x - offset_x;
    sp.y = pos.y;
    geng.render( sp );
  }
  
  void bomb() {
    sp.hide();
    isBombed = true;
  }
  
  void onDispose() {
  }

}
