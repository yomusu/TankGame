library tankgame;

import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'dart:math' as math;

import 'vector.dart';

import 'geng.dart';

part 'tankobjs.dart';


void main() {
  
  Timer.run( () {
    var canvas = query("canvas") as CanvasElement;
    geng.initField( canvas:canvas, width:640, height:400 );
    
    doTankGame();
  });
}


Tank  tank;
int score;
double  offset_x = 0.0;


void doTankGame() {
  
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
  geng.onPress( (PressEvent e) {
    var x = offset_x + e.x;
    var y = e.y;
    tank.fire( new Point(x,e.y) );
    print("x=$x, y=$y, offset_x=$offset_x, sx=${e.x}");
  } );
  
  //---------------
  // ゲーム進行処理
  var startLogo = new GameStartLogo();
  startLogo.init();
  
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
      
      var result = new ResultPrint();
      result.init();
      
      var t2 = new Timer.periodic( const Duration(milliseconds:50), (Timer t) {
        // 戦車移動
        tank.pos.add( tank.speed );
        // 戦車  砲弾  的を移動
        geng.renderAll();
        drawScore();
        geng.gcObj();
      });
      
      // Clickされたらタイトルに戻る
      geng.onPress( (s)=>t2.cancel() );
    }
  });
}

