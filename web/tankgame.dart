library tankgame;

import 'dart:html';
import 'dart:async';
import 'dart:math' as math;

import 'vector.dart';

import 'geng.dart';

part 'tankobjs.dart';


void main() {
  
  Timer.run( () {
    var canvas = query("canvas") as CanvasElement;
    geng.initField( canvas:canvas, width:640, height:400 );
    
    geng.screen = new Title();
    geng.startTimer();
  });
}

/***********
 * 
 * タイトル画面の表示
 * 
 */
class Title extends GScreen {
  
  void onStart() {
    geng.disposeAll();
    
    //---------------------
    // StartGameボタン配置
    var playbtn = new PlayButton( (){
      new Timer( const Duration(seconds:2), () {
        geng.screen = new TankGame();
      });
    })
    ..text = "game start"
    ..x = 320
    ..y = 220;
    geng.add( playbtn );
    entryButton( playbtn );
    
    //---------------------
    // How to Playボタンの配置
    var howtobtn = new PlayButton( (){
      geng.screen = new HowToPlay();
    })
    ..text = "How to play"
    ..x = 450
    ..y = 220;
    geng.add( howtobtn );
    entryButton( howtobtn );
    
    //---------------------
    // 最前面描画処理
    onFrontRender = ( CanvasElement canvas ) {
      
      var c = canvas.context2D;
      c.lineWidth = 1.0;
      c.textAlign = "center";
      c.textBaseline = "middle";
      c.setStrokeColorRgb(0, 0, 0, 1);
      c.strokeText("Tank Game", 320, 180, 100);
    };
  }
}


class HowToPlay extends GScreen {
  String  text = """
Hello Everybody!
You are in hell.
""";
  void onStart() {
    geng.disposeAll();
    onFrontRender = draw;
    
    // 戻るボタン配置
    var retbtn = new PlayButton( ()=>geng.screen = new Title() )
    ..text = "戻る"
    ..x = 320
    ..y = 220;
    geng.add( retbtn );
    entryButton( retbtn );
  }
  
  void draw(CanvasElement canvas) {
    var c = canvas.context2D;
    c.lineWidth = 1.0;
    c.textAlign = "center";
    c.textBaseline = "middle";
    c.setStrokeColorRgb(0, 0, 0, 1);
    c.strokeText(text, 320, 180, 300);
  }
}

class PlayButton extends BtnObj {
  
  String  text;
  
  Color bgCl_normal = new Color.fromString("#eeeeee");
  Color bgCl_on     = new Color.fromString("#00ee00");
  Color bgCl_press  = new Color.fromString("#ee0000");
  
  PlayButton( void onPress() ) {
    this.onPress = onPress;
  }
  
  void onInit() {
    
  }
  
  void onRender() {
    var c = geng.canvas.context2D;
    
    var bgcl = bgCl_normal;
    if( isPress ) {
      bgcl = bgCl_press;
    } else if( isOn ) {
      bgcl = bgCl_on;
    }
    
    c.beginPath();
    c.setFillColorRgb( bgcl.r, bgcl.g, bgcl.b );
    c.rect(left, top, width, height);
    c.fill();
    
    if( text!=null ) {
      c.lineWidth = 1.0;
      c.textAlign = "center";
      c.textBaseline = "middle";
      c.setStrokeColorRgb(0, 0, 0, 1);
      c.strokeText(text, x, y, width);
    }
  }
  
  void onDispose() { }
  
}

Tank  tank;
int score;
double  offset_x = 0.0;

/***********
 * 
 * ゲーム本体
 * 
 */
class TankGame extends GScreen {
  
  void onStart() {
    geng.disposeAll();
    
    // 戦車の初期位置
    tank = new Tank()
    ..pos.x = 0.0
    ..pos.y = 300.0
    ..speed.x = 2.0;
    geng.add( tank );
    
    // スコアをクリア
    score = 0;
    
    // 看板を配置
    var rand = new math.Random(0);
    for( int x=600; x<2000; x+=200 ) {
      var y = rand.nextDouble() * 300;
      Target  t = new Target()
      ..pos.x = x.toDouble()
      ..pos.y = y;
      geng.add( t );
    }
    
    // スタート表示
    geng.add( new GameStartLogo() );
    
    offset_x = 0.0;
    
    onProcess = onProcess1;
    
    onFrontRender = ( CanvasElement c ) {
      var c = geng.canvas.context2D;
      c.lineWidth = 1.0;
      c.textAlign = "left";
      c.textBaseline = "top";
      c.setStrokeColorRgb(0, 0, 0, 1);
      c.strokeText("SCORE: ${score}", 0, 0, 100);
    };
    
    // カーソル
    var cursor = new Cursor();
    geng.add( cursor );
    onMove = ( int x, int y ) {
      cursor.sp.show();
      cursor.sp.x = x;
      cursor.sp.y = y;
    };
    onMoveOut = () => cursor.sp.hide();
    
    // マウスボタン処理
    onPress = ( PressEvent e ) {
      var x = offset_x + e.x;
      var y = e.y;
      tank.fire( new Point(x,e.y) );
      print("x=$x, y=$y, offset_x=$offset_x, sx=${e.x}");
    };
  }
  
  void onProcess1() {
    // 戦車移動
    tank.pos.add( tank.speed );
    
    // 画面表示位置
    offset_x = math.max( 0.0, tank.pos.x - 320.0 );
    
    if( offset_x >= 1000 ) {
      // ステージ終了処理
      geng.add( new ResultPrint() );
      
      onPress = (PressEvent e) => geng.screen = new Title();
      
      onProcess = onProcess2; 
    }
  }
  
  void onProcess2() {
    tank.pos.add( tank.speed );
  }

}
