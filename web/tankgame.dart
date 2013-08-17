library tankgame;

import 'dart:html';
import 'dart:async';
import 'dart:math' as math;

import 'vector.dart';

import 'geng.dart';

part 'tankobjs.dart';
part 'stage.dart';


final String  scoreFont = "'Press Start 2P', cursive";

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

Map   stageData;
Tank  tank;
int score;
double  offset_x = 0.0;


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
  ..textBaseline = "middle"
  ..lineWidth = 1.0
  ..strokeColor = Color.Black
  ..fillColor = Color.Yellow
  ..shadowColor = new Color.fromAlpha(0.5)
  ..shadowOffset = 5
  ..shadowBlur = 10;
  
  void onStart() {
    geng.disposeAll();
    
    //---------------------
    // StartGameボタン配置
    var playbtn = new PlayButton()
    ..onPress = (){
      new Timer( const Duration(seconds:1), () {
        geng.screen = new StageSelect();
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

/***********
 * 
 * タイトル画面の表示
 * 
 */
class StageSelect extends GScreen {
  
  void onStart() {
    geng.disposeAll();
    
    // StartGameボタン配置
    var y = 100;
    for( var stage in stageList ) {
      
      var btn = new PlayButton()
      ..onPress = ( ()=>goToStage( stage ) )
      ..text = stage['name']
      ..width = 150
      ..height= 50
      ..x = 320
      ..y = y
      ..isEnable = stage['enable'];
      geng.add( btn );
      entryButton( btn );
      
      y += 70;
    }
  }
  
  void goToStage( var stage ) {
    new Timer( const Duration(milliseconds:500), () {
      stageData = stage;
      geng.screen = new TankGame();
    });
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

/* 未使用 */
void _createMap() {
  var rand = new math.Random(0);
  for( int x=600; x<2000; x+=200 ) {
    var y = rand.nextInt(250) + 20;
    Target  t = new Target.fromType('large')
    ..pos.x = x.toDouble()
    ..pos.y = y.toDouble();
    geng.add( t );
  }
}

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
    ..speed.x = stageData['speed'];
    geng.add( tank );
    
    // スコアをクリア
    score = 0;
    
    //---------------
    // Targetを配置
    stageData['map'].forEach( (d) {
      Target  t = new Target.fromType(d[2])
      ..pos.x = d[0].toDouble()
      ..pos.y = d[1].toDouble();
      
      geng.add( t );
    });

    // 地面
    geng.add( new Ground() );
    
    offset_x = 0.0;
    
    // スコア表示
    var tren = new TextRender()
    ..fontFamily = scoreFont
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
      if( offset_x >= stageData['length'] ) {
        
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
