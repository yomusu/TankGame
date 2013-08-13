library tankgame;

import 'dart:html';
import 'dart:async';
import 'dart:math' as math;

import 'vector.dart';

import 'geng.dart';

part 'tankobjs.dart';



final String  fontFamily = '"ヒラギノ角ゴ Pro W3", "Hiragino Kaku Gothic Pro", Meiryo, "メイリオ", "ＭＳ Ｐゴシック", Verdana, Geneva, Arial, Helvetica';

void main() {
  
  Timer.run( () {
    var canvas = query("canvas") as CanvasElement;
    canvas.context2D.scale(2.0, 2.0); // for Retina対応
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
  
  TextRender  tren = new TextRender();
  
  void onStart() {
    geng.disposeAll();
    
    //---------------------
    // StartGameボタン配置
    var playbtn = new PlayButton()
    ..onPress = (){
      new Timer( const Duration(seconds:2), () {
        geng.screen = new TankGame();
      });
    }
    ..text = "ゲームスタート"
    ..width = 150
    ..height= 50
    ..x = 320
    ..y = 220;
    geng.add( playbtn );
    entryButton( playbtn );
    
    //---------------------
    // How to Playボタンの配置
    var howtobtn = new PlayButton()
    ..onPress = (){ geng.screen = new HowToPlay(); }
    ..text = "あそびかた"
    ..width = 150
    ..height= 50
    ..x = 320
    ..y = 280;
    geng.add( howtobtn );
    entryButton( howtobtn );
    
    //---------------------
    // 最前面描画処理
    onFrontRender = ( CanvasElement canvas ) {
      tren.canvas = canvas;
      tren.drawTexts(["Tank Game"], 320, 100 );
      tren.canvas = null;
    };
    
    tren.fontFamily = fontFamily;
    tren.fontSize = "24pt";
    tren.textAlign = "center";
    tren.textBaseline = "middle";
  }
}


class HowToPlay extends GScreen {
  
  List  text = """遊び方

マウスをクリックするとたまをうつよ！
つぎつぎと あらわれる まとに あてよう！
れんぞくして あてると こうとくてんだ！
""".split("\n");
  
  TextRender  tren = new TextRender();
  
  void onStart() {
    geng.disposeAll();
    
    // 戻るボタン配置
    var retbtn = new PlayButton()
    ..onPress = () { geng.screen = new Title(); }
    ..text = "戻る"
    ..x = 320
    ..y = 300;
    geng.add( retbtn );
    entryButton( retbtn );
    
    tren.fontFamily = fontFamily;
    tren.fontSize = "14pt";
    tren.textAlign = "left";
    tren.textBaseline = "ideographic";
    tren.lineHeight = 32;
    tren.fillColor = Color.Black;
    tren.strokeColor = null;
    
    // 描画処理
    onFrontRender = (CanvasElement canvas) {
      tren.canvas = canvas;
      tren.drawTexts(text, 50, 50 );
      tren.canvas = null;
    };
  }
}

class PlayButton extends BtnObj {
  
  String  text;
  
  Color bgCl_normal = new Color.fromString("#eeeeee");
  Color bgCl_on     = new Color.fromString("#00ee00");
  Color bgCl_press  = new Color.fromString("#ee0000");
  
  var tren = new TextRender();
  
  void onInit() {
    tren = new TextRender()
    ..fontFamily = fontFamily
    ..fontSize = "14pt"
    ..textAlign = "center"
    ..textBaseline = "middle"
    ..fillColor = Color.Black
    ..strokeColor = null;
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
      tren.canvas = geng.canvas;
      tren.drawTexts([text], x, y);
      tren.canvas = null;
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
    
    // スコア表示
    var tren = new TextRender()
    ..fontFamily = fontFamily
    ..fontSize = "12pt"
    ..textAlign = "left"
    ..textBaseline = "top"
    ..fillColor = Color.Black
    ..strokeColor = null;
    
    onFrontRender = ( CanvasElement c ) {
      tren.canvas = c;
      tren.drawTexts(["SCORE: ${score}"], 5, 5 );
      tren.canvas = null;
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
