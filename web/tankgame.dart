library tankgame;

import 'dart:html';
import 'dart:async';
import 'dart:math' as math;

import 'vector.dart';

import 'geng.dart';

part 'tankobjs.dart';
part 'tankobjs2.dart';
part 'stage.dart';


final String  scoreFont = "'Press Start 2P', cursive";

void main() {
  
  Timer.run( () {
    
    // 画像読み込み
    geng.imageMap
      ..put("tank", "./octocat.png")
      ..put("cannon", "./octocat.png")
      ..put("target", "./img/doramu.png")
      ..put("kusa", "./kusa.png")
      ..put("smoke", "./img/kemuri.png");
    
    // サウンド読み込み
    geng.soundManager.put("fire","./sound/bomb.ogg");
    geng.soundManager.put("bomb","./sound/launch02.ogg");
    
    // Retina
    query("#devicePixelRatio").text = window.devicePixelRatio.toString();
    
    // Canvas
    var width = 640;
    var height= 600;
    
    geng.initField( width:width, height:height );
    
    query("#place").append( geng.canvas );
    
    // 開始
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
  ..fontFamily = scoreFont
  ..fontSize = "28pt"
  ..textAlign = "center"
  ..textBaseline = "middle"
  ..lineWidth = 2.0
  ..strokeColor = Color.Black
  ..fillColor = Color.Yellow
  ..shadowColor = new Color.fromAlpha(0.5)
  ..shadowOffset = 5
  ..shadowBlur = 10;
  
  void onStart() {
    geng.objlist.disposeAll();
    
    //---------------------
    // StartGameボタン配置
    var playbtn = new GButton()
    ..onPress = (){
      geng.soundManager.play("fire");
      new Timer( const Duration(seconds:1), () {
        geng.screen = new StageSelect();
      });
    }
    ..text = "ゲームスタート"
    ..width = 150
    ..height= 50
    ..x = 320
    ..y = 320;
    geng.objlist.add( playbtn );
    btnList.add( playbtn );
    
    //---------------------
    // How to Playボタンの配置
    var howtobtn = new GButton()
    ..onPress = (){ geng.screen = new HowToPlay(); }
    ..text = "あそびかた"
    ..width = 150
    ..height= 50
    ..x = 320
    ..y = 380;
    geng.objlist.add( howtobtn );
    btnList.add( howtobtn );
    
    //---------------------
    // 最前面描画処理
    onFrontRender = ( GCanvas2D canvas ) {
      canvas.drawTexts( tren, ["Tank Game"], 320, 150 );
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
    geng.objlist.disposeAll();
    
    // StartGameボタン配置
    var y = 200;
    for( var stage in stageList ) {
      
      var btn = new GButton()
      ..onPress = ( ()=>goToStage( stage ) )
      ..text = stage['name']
      ..width = 150
      ..height= 50
      ..x = 320
      ..y = y
      ..isEnable = stage['enable'];
      geng.objlist.add( btn );
      btnList.add( btn );
      
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
    geng.objlist.disposeAll();
    
    // 戻るボタン配置
    var retbtn = new GButton()
    ..onPress = () { geng.screen = new Title(); }
    ..text = "戻る"
    ..x = 320
    ..y = 300;
    geng.objlist.add( retbtn );
    btnList.add( retbtn );
    
    // 描画処理
    onFrontRender = (GCanvas2D canvas) {
      canvas.drawTexts( tren, text, 50, 50 );
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
    geng.objlist.add( t );
  }
}

/***********
 * 
 * ゲーム本体
 * 
 */
class TankGame extends GScreen {
  
  void onStart() {
    geng.objlist.disposeAll();
    
    // 戦車の初期位置
    tank = new Tank()
    ..pos.x = 320.0
    ..pos.y = 500.0
    ..speed.x = stageData['speed'];
    geng.objlist.add( tank );
    
    // スコアをクリア
    score = 0;
    
    //---------------
    // Targetを配置
    stageData['map'].forEach( (d) {
      Target  t = new Target.fromType(d[2])
      ..pos.x = d[0].toDouble()
      ..pos.y = d[1].toDouble();
      
      geng.objlist.add( t );
    });

    // 地面
    var ground = new Ground();
    geng.objlist.add( ground );
    
    offset_x = 0.0;
    
    // スコア表示
    var tren = new TextRender()
    ..fontFamily = scoreFont
    ..fontSize = "12pt"
    ..textAlign = "left"
    ..textBaseline = "top"
    ..fillColor = Color.Black
    ..strokeColor = null;
    
    onFrontRender = ( GCanvas2D c ) {
      c.drawTexts( tren, ["SCORE: ${score}"], 5, 5 );
    };
    
    //-------
    // Fireボタン配置
    var firebtn = new FireButton();
    geng.objlist.add( firebtn );
    btnList.add(firebtn);
    
    // スタート表示
    var startLogo = new GameStartLogo();
    geng.objlist.add( startLogo );
    
    //-----------
    // 最初の処理
    onProcess = () {
      
      // 戦車移動
      tank.pos.add( tank.speed );
      
      // 画面表示位置
      offset_x = math.max( 0.0, tank.pos.x - 320.0 );
      
      // 地面スクロール
      ground.translateX = offset_x;
      
      // ステージ終了判定
      if( offset_x >= stageData['length'] ) {
        
        // 発射ボタン等消す
        firebtn.dispose();
        
        // 結果表示
        geng.objlist.add( new ResultPrint() );
        
        // 戻るボタン配置
        var retBtn = new GButton()
        ..onPress = () { geng.screen = new Title(); }
        ..text = "戻る"
        ..x = 320 ..y = 400
        ..width = 100 ..height= 40;
        geng.objlist.add( retBtn );
        btnList.add( retBtn );
        
        onProcess = () {
          tank.pos.add( tank.speed );
        };
      }
    };
    
    // 2秒後にオープニング終了
    new Timer( const Duration(seconds:2), () {
      // スタートロゴを消す
      startLogo.dispose();
    });
  }

}


class FireButton extends GButton {
  
  FireButton() {
    renderer = render;
    text = "うつ!";
    x = 540;
    y = 530;
    width = 120;
    height= 60;
    
    onPress = fire;
  }
  
  num power=1.0;
  
  void fire() {
    
    tank.fire( new Point(tank.pos.x,0) );
    power = 0.0;
    
    new Timer( const Duration(milliseconds:200), () => startCharge() );
  }
  
  void startCharge() {
    new Timer.periodic( const Duration(milliseconds:50), (t) {
      power += 0.05;
      if( power >= 1.0 ) {
        power = 1.0;
        t.cancel();
        new Timer( const Duration(milliseconds:100), () => isPress = false );
      }
    });
  }
  
  static Color shadow    = new Color.fromString("#c20000");
  static Color bg_normal = new Color.fromString("#ff3030");
  static Color border_normal = new Color.fromString("#d9000b");
  
  static var tren = new TextRender()
  ..fontFamily = fontFamily
  ..fontSize = "14pt"
  ..textAlign = "center"
  ..textBaseline = "middle"
  ..fillColor = new Color.fromString("#FFFFFF")
  ..strokeColor = new Color.fromString("#FFFFFF")
  ..lineWidth = 1;
  
  static var trenOff = new TextRender()
  ..fontFamily = fontFamily
  ..fontSize = "14pt"
  ..textAlign = "center"
  ..textBaseline = "middle"
  ..fillColor = new Color.fromString("#a64040")
  ..strokeColor = null;
  

  void render( GCanvas2D canvas, GButton btn ) {
    
    var status = btn.status;
    var left = btn.left;
    var top = btn.top;
    var width = btn.width;
    var height= btn.height;
    
    var c = canvas.c;
    
    var bg     = bg_normal;
    var border = border_normal;
    
    c.save();
    
    // 影
    c.beginPath();
    canvas.roundRect( left, top+10, width, height, 30 );
    c.closePath();
    canvas.fill( shadow );
    
    
    // 表面
    if( status==GButton.PRESSED )
      c.translate(0,4);
    
    c.beginPath();
    // 背景
    canvas.roundRect( left+2, top+2, width-4, height-4, 28 );
    c.closePath();
    canvas.fill( bg );
    // ボーダー
    c.lineWidth = 4;
    canvas.stroke(border);
    
    //---------
    // テキスト
    var tr = trenOff;
    if( status==GButton.ROLLON || status==GButton.ACTIVE )
      tr = tren;
      
    canvas.drawTexts( tr, [btn.text], btn.x+5, btn.y);
    
    // チャージサイン
    var cx = left + 30;
    var cy = btn.y;
      
    c.beginPath();
    canvas.pizza( cx, cy, 8, -R90, (2*math.PI * power)-R90 );
    canvas.fill( tr.fillColor );
    
    canvas.restore();
  }
  
}

