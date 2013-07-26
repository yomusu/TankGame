import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';

import 'geng.dart';
import 'vector.dart';


Tank  tank;

void main() {
  
  geng.topElement = query("#field");
  
  tank = new Tank();
  
  geng.objlist.add( tank );
  geng.objlist.add( new Cursor() );
  
  Timer.run( () {
    
    // フィールドにマウスリスナー
    new PressHandler( (int x, int y) {
      tank.fire( new Point(x,y) );
      print("x=$x, y=$y");
    })
    ..connect( geng.topElement );
    
    new Timer.periodic( const Duration(milliseconds:50), (t) {
      geng.frame_all();
    });
  });
}


class Cursor extends GObj {
  
  Sprite sp;
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png" );
    sp.width = 100;
    sp.height = 100;
    sp.offset = new Point(50,50);
    geng.topElement.append( sp.element );
    
    new MoveHandler( (int x, int y) {
      sp.x = x;
      sp.y = y;
      sp.show();
    },
    onOut : () => sp.hide()
    )
    ..connect( geng.topElement );
  }
}

class Tank extends GObj {
  
  int  delta_x = 1;
  Sprite sp;
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png" );
    sp.width = 100;
    sp.height = 100;
    geng.topElement.append( sp.element );
    
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
    ..mul( 5.0 );
    
    geng.objlist.add( b );
    
  }
  
  void onFrame( FrameInfo info ) {
    
  }
}


class Cannonball extends GObj {
  
  /** 位置 */
  Vector  pos = new Vector();
  /** 速度 */
  Vector  speed = new Vector();
  /** 加速度 */
  Vector  delta= new Vector();
  
  Sprite sp;
  
  void onInit() {
    sp = new Sprite( src:"../octocat.png" );
    sp.width = 50;
    sp.height = 50;
    geng.topElement.append( sp.element );
    
    sp.offset = new Point(25,25);
  }
  
  void onFrame( FrameInfo info ) {
    pos.add( speed );
    sp.x = pos.x.toInt();
    sp.y = pos.y.toInt();
  }
}
