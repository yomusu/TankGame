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
    
    geng.imageMap.put("tank", "../octocat.png");
    geng.imageMap.put("cannon", "../octocat.png");
    geng.imageMap.put("target", "../octocat.png");
    geng.imageMap.put("kusa", "../kusa.png");
    
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
  
  TextRender  tren = new TextRender()
  ..fontFamily = fontFamily
  ..fontSize = "24pt"
  ..textAlign = "center"
  ..textBaseline = "middle";
  
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
    
  }
}


class HowToPlay extends GScreen {
  
  List  text = """遊び方

マウスをクリックするとたまをうつよ！
つぎつぎと あらわれる まとに あてよう！
れんぞくして あてると こうとくてんだ！
""".split("\n");
  
  TextRender  tren = new TextRender()
  ..fontFamily = fontFamily
  ..fontSize = "14pt"
  ..textAlign = "left"
  ..textBaseline = "ideographic"
  ..lineHeight = 32
  ..fillColor = Color.Black
  ..strokeColor = null;
  
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
  
  var tren = new TextRender()
  ..fontFamily = fontFamily
  ..fontSize = "14pt"
  ..textAlign = "center"
  ..textBaseline = "middle"
  ..fillColor = Color.Black
  ..strokeColor = null;
  
  void onInit() { }
  
  void render( CanvasElement canvas, int status ) {
    var c = canvas.context2D;
    
    var textCl = Color.Black;
    var bgcl = bgCl_normal;
    switch( status ) {
      case BtnObj.DISABLE:
        textCl = Color.Gray;
        break;
      case BtnObj.ACTIVE:
        break;
      case BtnObj.PRESSED:
        bgcl = bgCl_press;
        break;
      case BtnObj.ROLLON:
        bgcl = bgCl_on;
        break;
    }
    
    c.beginPath();
    c.setFillColorRgb( bgcl.r, bgcl.g, bgcl.b );
    c.rect(left, top, width, height);
    c.fill();
    
    if( text!=null ) {
      tren.canvas = canvas;
      tren.fillColor = textCl;
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
    ..pos.x = 320.0
    ..pos.y = 300.0
    ..speed.x = 2.0;
    geng.add( tank );
    
    // スコアをクリア
    score = 0;
    
    // 看板を配置
    var rand = new math.Random(0);
    for( int x=600; x<2000; x+=200 ) {
      var y = rand.nextInt(250) + 20;
      Target  t = new Target.large()
      ..pos.x = x.toDouble()
      ..pos.y = y.toDouble();
      geng.add( t );
    }
    
    // 地面
    geng.add( new Ground() );
    
    offset_x = 0.0;
    
    // スコア表示
    var tren = new TextRender()
    ..fontFamily = "'Press Start 2P', cursive"
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
    
    //-------
    // Fireボタン配置
    var firebtn = new PlayButton()
    ..onPress = () { geng.screen = new Title(); }
    ..text = "うつ!"
    ..x = 100
    ..y = 350
    ..width = 90
    ..height= 40
    ..isEnable = false;
    firebtn.onPress = () {
      tank.fire( new Point(tank.pos.x,0) );
      new Timer( const Duration(seconds:1), () { firebtn.isPress = false; });
    };
    geng.add( firebtn );
    entryButton(firebtn);
    
    // スタート表示
    var startLogo = new GameStartLogo();
    geng.add( startLogo );
    
    //-----------
    // 最初の処理
    onProcess = () {
      
      // 戦車移動
      tank.pos.add( tank.speed );
      
      // 画面表示位置
      offset_x = math.max( 0.0, tank.pos.x - 320.0 );
      
      // ステージ終了判定
      if( offset_x >= 1000 ) {
        
        // 発射ボタン等消す
        firebtn.dispose();
        
        // 結果表示
        geng.add( new ResultPrint() );
        
        onPress = (PressEvent e) => geng.screen = new Title();
        onProcess = () {
          tank.pos.add( tank.speed );
        };
      }
    };
    
    // 2秒後にオープニング終了
    new Timer( const Duration(seconds:2), () {
      // スタートロゴを消す
      startLogo.dispose();
      // Fireボタンを押せるように
      firebtn.isEnable = true;
    });
  }

}
