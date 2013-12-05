library tankgame;

import 'dart:html';
import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';

import 'vector.dart';

import 'geng.dart';

part 'title.dart';
part 'tankobjs.dart';
part 'tankobjs2.dart';
part 'stage.dart';


final String  scoreFont = "'Press Start 2P', cursive";

void main() {
  
  Timer.run( () {
    
    // 画像読み込み
    geng.imageMap
      ..put("title", "./img/title.png")
      ..put("starttext", "./img/starttext.png")
      ..put("tank01", "./img/boo01.png")
      ..put("tank02", "./img/boo02.png")
      ..put("targetL", "./img/usidaruma01.png")
      ..put("targetS", "./img/usidaruma02.png")
      ..put("snow01", "./img/snow01.png")
      ..put("snow02", "./img/snow02.png")
      ..put("gareki01", "./img/minidaruma01.png")
      ..put("gareki02", "./img/minidaruma02.png")
      ..put("gareki03", "./img/minidaruma03.png")
      ..put("smoke", "./img/kemuri.png")
      ..put("tama", "./img/yuki01.png")
      ..put("star01", "./img/star01.png")
      ..put("ball01", "./img/ball01.png")
      ..put("gamestart", "./img/gamestart.png")
      ;
    // ご褒美画面用の画像
    geng.imageMap
      ..put("rank01", "./present/rank01.png")
      ..put("rank02", "./present/rank02.png")
      ..put("rank03", "./present/rank03.png")
      ..put("rank04", "./present/rank04.png")
      ;
    
    // サウンド読み込み
    geng.soundManager.put("bell","./sound/xmasbell");
    geng.soundManager.put("bell2","./sound/xmasbell");
    geng.soundManager.put("fire","./sound/bag");
    geng.soundManager.put("bomb","./sound/pyo");
    
    // ハイスコアデータ読み込み
    xmasSavedata.build();
    
    // SoundのOn/Off
    bool sound = window.localStorage.containsKey("sound") ? window.localStorage["sound"]=="true" : true;
    geng.soundManager.soundOn = sound;
    
    // Canvas
//    num scale = isMobileDevice() ? 0.5 : 1;
    geng.initField( width:570, height:570, scale:1 );
    
    querySelector("#place").append( geng.canvas );
    
    // 開始
    geng.screen = new Title();
    geng.startTimer();
  });
}

Map   itemData;
Map   stageData;
Tank  tank;
int numberOfHit;
int numberOfFire;
double  offset_x = 0.0;

XMasSaveData  xmasSavedata = new XMasSaveData();

clearGameData() {

  // ハイスコア
  xmasSavedata.allClear();
  // サウンドのON/OFF
//  window.localStorage;
}


TextRender  trenTitle = new TextRender()
..fontFamily = fontFamily
..fontSize = "20pt"
..textAlign = "center"
..textBaseline = "top"
..lineWidth = 1.0
..fillColor = Color.Black
..shadowColor = new Color.fromAlpha(0.5)
..shadowOffset = 2
..shadowBlur = 2;

var trenMessage = new TextRender()
..fontFamily = fontFamily
..fontSize = "14pt"
..textAlign = "center"
..textBaseline = "middle"
..fillColor = Color.Black
..strokeColor = null
..lineHeight = 40;

var trenButton = new TextRender()
..fontFamily = fontFamily
..fontSize = "14pt"
..textAlign = "center"
..textBaseline = "middle"
..fillColor = new Color.fromString("#FFFFFF")
..strokeColor = new Color.fromString("#FFFFFF")
..lineWidth = 1;

/** 共通で使用するテキストレンダー:通常の文字表示 */
var trenScore = new TextRender()
..fontFamily = fontFamily
..fontSize = "12pt"
..textAlign = "center"
..textBaseline = "middle"
..fillColor = Color.Black
..strokeColor = null
..shadowColor = Color.White
..shadowOffset = 2
..shadowBlur = 0;


var scoretren = new TextRender.from(trenScore)
..textAlign = "left"
..textBaseline = "top";

TextRender  trenHiscore = new TextRender.from(scoretren)
..textAlign = "right"
..textBaseline = "middle";

TextRender  trenHiscoreS = new TextRender.from(trenHiscore)
..fillColor = Color.Red;

/**
 * ハイスコアの表示
 */
void drawHiScore( GCanvas2D canvas, int y, { XMasScore mark:null } ) {
  
  final List titles = <String>["1ばん","2ばん","3ばん","4ばん","5ばん"];
  
  var scoreList = xmasSavedata.getHiScores();
  const line = 20;
  
  trenHiscore.textAlign = "center";
  canvas.drawTexts( trenHiscore, ["ハイスコア"], 285, y, maxWidth:300 );
  
  y += line*2;
  var tren = new TextRender.from(trenHiscore);
  tren.textAlign = "right";
  
  for( int i=0; i<titles.length; i++ ) {
    
    if( i >= scoreList.length )
      break;
    
    var s = scoreList[i] as XMasScore;
    
    tren.fillColor = ( mark==s ) ? Color.Red : Color.Black;
    
    canvas.drawTexts( tren, [titles[i]], 200, y, maxWidth:100 );
    canvas.drawTexts( tren, ["${s.hit}こ"], 280, y, maxWidth:200 );
    canvas.drawTexts( tren, ["${s.rankText}レベル"], 430, y, maxWidth:300 );
    
    y += line;
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
    ..pos.x = 200.0
    ..pos.y = 430.0
    ..speed.x = stageData['speed'];
    geng.objlist.add( tank );
    
    // スコアをクリア
    numberOfHit = 0;
    numberOfFire = 0;
    
    //---------------
    // Targetを配置
    var prex = 0;
    stageData['map'].forEach( (d) {
      Target  t = new Target.fromType(d[2])
      ..pos.x = prex + d[0].toDouble()
      ..pos.y = d[1].toDouble();
      prex = t.pos.x;
      geng.objlist.add( t );
    });
    // ステージの終端は、最後のターゲットからxxの距離
    var endOfStage = prex + 400;

    // 地面
    var ground = new Ground();
    geng.objlist.add( ground );
    
    offset_x = 0.0;
    
    // スコア表示
    onFrontRender = ( GCanvas2D c ) {
      c.drawTexts( scoretren, ["めいちゅうしたかず: ${numberOfHit}こ"], 5, 5 );
    };
    
    //-------
    // Fireボタン配置
    FireButton  firebtn = new FireButton();
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
      offset_x = math.max( 0.0, tank.pos.x - 285.0 );
      
      // 地面スクロール
      ground.translateX = offset_x;
      
      // 再描画指示
      geng.repaint();
      
      // ステージ終了判定
      if( offset_x >= endOfStage ) {
        
        // 発射ボタン等消す
        firebtn.dispose();
        
        onEndOfStage();
      }
    };
    
    // 2秒後にオープニング終了
    new Timer( const Duration(seconds:2), () {
      // スタートロゴを消す
      startLogo.dispose();
      geng.repaint();
    });
  }
  
  /** ステージの終端に到達した時 */
  void onEndOfStage() {
    
    // この時点での得点をバックアップ
    final _numberOfHit = numberOfHit;
    final _numberOfFire = numberOfFire;
    final score = new XMasScore.create( numberOfHit, numberOfFire, stageData);
    
    // Hi-Score登録
    var drawMeichu = null;
    var text02 = null;
    var drawLevel = null;
    bool showHiScore = false;
    
    // 結果表示の描画部分
    onFrontRender = ( GCanvas2D c ) {
      c.drawTexts( trenScore, ["- ゲーム しゅうりょう! -"], 285, 60);
      if( drawMeichu!=null )
        drawMeichu(c,125);
      if( text02!=null )
        c.drawTexts( trenScore, text02, 285, 185);
      if( drawLevel!=null )
        drawLevel( c, 240 );
      if( showHiScore )
        drawHiScore( c, 330, mark:score );
    };
    
    // 結果表示の進行
    delay( 1000, (){
      drawMeichu = (GCanvas2D c, int y) {
        c.drawTexts( trenScore, ["めいちゅうしたかず: ${_numberOfHit}こ"], 285, y);
        if( score.isPerfect ) {
          c.drawTexts( trenScore, ["パーフェクト！"], 285, y+25);
        }
      };
      geng.repaint();
      geng.soundManager.play("bell");
    } );
    delay( 2000, (){
      text02 = ["なげたゆきだま: ${_numberOfFire}こ"];
      geng.repaint();
      geng.soundManager.play("bell2");
    } );
    delay( 3000, (){
      drawLevel = ( GCanvas2D c, int  y ) {
        c.drawTexts( trenScore, ["キミのうでまえは"], 285, y);
        c.drawTexts( trenScore, ["〜 ${score.rankText} レベル 〜"], 285, y+30);
      };
      // ハイスコアに登録
      xmasSavedata.putAndWrite( score );
      
      geng.repaint();
      geng.soundManager.play("bell");
    } );
    delay( 4000, (){
      // ハイスコア
      showHiScore = true;
      geng.repaint();
    } );
    
    // 戻るボタン配置
    delay( 4000, () {
      final pscreen = new PresentScreen(score);
      if( pscreen.img != null ) {
        // ご褒美画面あり
        var retBtn = new GButton()
        ..onPress = () { geng.screen = pscreen; }
        ..text = "つぎへ"
            ..x = 285 ..y = 500
            ..width = 150 ..height= 40;
        geng.objlist.add( retBtn );
        btnList.add( retBtn );
        
      } else {
        
        // ご褒美画面なし
        var retBtn = new GButton()
        ..onPress = () { geng.screen = new Title(); }
        ..text = "おしまい"
            ..x = 285 ..y = 500
            ..width = 150 ..height= 40;
        geng.objlist.add( retBtn );
        btnList.add( retBtn );
      }
      geng.repaint();
    });
    
    onProcess = () {
      tank.pos.add( tank.speed );
      if( 570 < (tank.pos.x - offset_x) )
        tank.dispose();
    };
  }
}

const ScreenWidth = 570;
const ScreenHeight= 570;

/***
 * ご褒美画面を表示する画面
 */
class PresentScreen extends GScreen {
  
  final XMasScore _score;
  final ImageElement  img;
  
  PresentScreen( XMasScore score ) :
    _score = score,
    img = geng.imageMap[score.rank]
  ;
  
  void onStart() {
    geng.objlist.disposeAll();
    
    // 表示すべき日付を求める
    var now = _score.datetime;
    String  nowText = "${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute}";
    
    List  info = ["$nowText ${_score.rankText}"];

    // ご褒美画像の描画部分
    onFrontRender = ( GCanvas2D c ) {
      if( img!=null ) {
        var x = (ScreenWidth - img.width) ~/ 2;
        var y = (ScreenHeight - img.height) ~/ 2;
        c.c.drawImage( img, x, y-15 );
      }
      // 日時の描画
      c.drawTexts(scoretren, info, 5, 5 );
    };
    
    // 戻るボタン作成
    var retBtn = new GButton()
    ..onPress = () { geng.screen = new Title(); }
    ..text = "タイトル画面に戻る"
        ..x = 285 ..y = 540
        ..width = 250 ..height= 40;
    geng.objlist.add( retBtn );
    btnList.add( retBtn );
  }  
}


/***********
 * 
 * ゲーム本体
 * 
 */
class TankGamePracticely extends TankGame {
  
  void onEndOfStage() {
    
    // メッセージ表示
    var message;
    if( numberOfHit <= 3 ) {
      message = ["まだまだ かな？",
                 "もうちょっと れんしゅうしてみよう！"];
    } else {
      message = ["なかなかやるね！",
                 "つぎは ほんばん に ちょうせんしてみよう！"];
    }
    onFrontRender = ( GCanvas2D c ) {
      c.drawTexts( trenMessage, message, 285, 200);
    };
    
    // 戻るボタン配置
    var retBtn = new GButton()
    ..onPress = () { geng.screen = new Title(); }
    ..text = "戻る"
        ..x = 285 ..y = 400
        ..width = 100 ..height= 40;
    geng.objlist.add( retBtn );
    btnList.add( retBtn );
    
    onProcess = () {
      tank.pos.add( tank.speed );
    };
  }

}

class FireButton extends GButton {
  
  FireButton() {
    renderer = render;
    text = "なげる!";
    x = 480;
    y = 500;
    width = 140;
    height= 100;
    
    onPress = fire;
  }
  
  num power=1.0;
  
  void fire() {
    
    tank.fire( new Point(tank.pos.x,0) );
    power = 0.0;
    
    // 発射カウントIncrement
    numberOfFire++;
    
    new Timer( const Duration(milliseconds:100), () => startCharge() );
  }
  
  void startCharge() {
    new Timer.periodic( const Duration(milliseconds:50), (t) {
      power += 0.18;
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
      tr = trenButton;
      
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

