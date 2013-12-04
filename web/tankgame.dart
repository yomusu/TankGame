library tankgame;

import 'dart:html';
import 'dart:async';
import 'dart:math' as math;
import 'dart:collection';
import 'dart:convert';

import 'vector.dart';

import 'geng.dart';

part 'tankobjs.dart';
part 'tankobjs2.dart';
part 'stage.dart';


final String  scoreFont = "'Press Start 2P', cursive";

GamePointManager  gamePointManager = new GamePointManager();

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
      ..put("p100", "./present/p100.png")
      ..put("p90", "./present/p90.png")
      ..put("p80", "./present/p80.png")
      ..put("p70", "./present/p70.png")
      ;
    
    // サウンド読み込み
    geng.soundManager.put("bell","./sound/xmasbell");
    geng.soundManager.put("bell2","./sound/xmasbell");
    geng.soundManager.put("fire","./sound/bag");
    geng.soundManager.put("bomb","./sound/pyo");
    
    // ハイスコアデータ読み込み
    geng.hiscoreManager.init();
    
    // ゲームポイントマネージャー
    gamePointManager.init();
    
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

clearGameData() {

  // ハイスコア
  geng.hiscoreManager.allClear();
  // サウンドのON/OFF
//  window.localStorage;
  // 取得ポイント
  gamePointManager.clearPoint();
}


/***********
 * 
 * タイトル画面の表示
 * 
 */
class Title extends GScreen {
  
  Timer timer;
  bool isBtnVisible = true;
  
  void onStart() {
    geng.objlist.disposeAll();
    
    //---------------------
    // 練習ボタン配置
    var practicebtn = new GButton(width:570,height:570)
    ..renderer = null
    ..onPress = (){
      timer.cancel();
      geng.screen = new StageSelect();
    }
    ..x = 285
    ..y = 300;
    
    geng.objlist.add( practicebtn );
    btnList.add( practicebtn );
    
    //---------------------
    // 最前面描画処理
    onBackRender = ( GCanvas2D canvas ) {
      var img = geng.imageMap["title"];
      canvas.c.drawImageScaled(img, 0, 0, 570, 570);
    };
    // クリックでスタート表示
    onFrontRender = ( GCanvas2D canvas ) {
      if( isBtnVisible ) {
        const width = 134*1.2;
        const height= 46*1.2;
        var img = geng.imageMap["starttext"];
        canvas.c.drawImageScaled(img, 250, 420, width, height );
      }
    };
    
    // 点滅
    timer = new Timer.periodic( const Duration(milliseconds:500), (t){
      geng.repaint();
      isBtnVisible = (isBtnVisible==false);
    });
  }
}

class StageSelect extends GScreen {
  
  void onStart() {
    geng.objlist.disposeAll();
    
    //---------------------
    // 練習ボタン配置
    var practicebtn = new GButton(text:"れんしゅう",width:300,height:60)
    ..onPress = (){
      geng.soundManager.play("bell");
      new Timer( const Duration(milliseconds:500), () {
        stageData = stageList[0];
        itemData = itemList[0];
        geng.screen = new TankGamePracticely();
      });
    }
    ..x = 285
    ..y = 220;
    
    geng.objlist.add( practicebtn );
    btnList.add( practicebtn );
    
    //---------------------
    // StartGameボタン配置
    var playbtn = new GButton(text:"ゲームスタート", width:300,height:60)
    ..onPress = (){
      geng.soundManager.play("bell");
      new Timer( const Duration(milliseconds:500), () {
        stageData = stageList[1];
        itemData = itemList[0];
        geng.screen = new TankGame();
      });
    }
    ..x = 285
    ..y = practicebtn.y + 110;
    geng.objlist.add( playbtn );
    btnList.add( playbtn );
    
    //---------------------
    // Configボタンの配置
    var configbtn = new GButton(text:"せってい",width:300,height:60)
    ..onPress = (){ geng.screen = new ConfigSetting(); }
    ..x = 285
    ..y = practicebtn.y + (110 * 2);
    geng.objlist.add( configbtn );
    btnList.add( configbtn );
    
    //---------------------
    // 最前面描画処理
    Color bgColor = new Color.fromString("#ffffff");
    Color borderColor = new Color.fromString("#A2896F");
    onBackRender = ( GCanvas2D canvas ) {
      var img = geng.imageMap["title"];
      canvas.c.drawImageScaled(img, 0, 0, 570, 570);
      
      canvas.c.beginPath();
      // 背景
      canvas.roundRect( 100, 150, 370, 360, 18 );
      canvas.c.closePath();
      canvas.fillColor = bgColor;
      canvas.c.fill();
      // ボーダー
      canvas.strokeColor = borderColor;
      canvas.c.lineWidth = 4;
      canvas.c.stroke();
    };
  }
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

final titles = <String>["1ばん","2ばん","3ばん","4ばん","5ばん"];

// ハイスコアの表示
void drawHiScore( GCanvas2D canvas, var scoreList, int y, { int mark:-1 } ) {
  
  const line = 20;
  
  trenHiscore.textAlign = "center";
  canvas.drawTexts( trenHiscore, ["ハイスコア"], 285, y, maxWidth:300 );
  
  y += line*2;
  var tren = new TextRender.from(trenHiscore);
  tren.textAlign = "right";
  for( int i=0; i<scoreList.length; i++ ) {
    tren.fillColor = ( mark==i ) ? Color.Red : Color.Black;
    canvas.drawTexts( tren, [titles[i]], 215, y, maxWidth:100 );
    canvas.drawTexts( tren, [resultToLevelText(scoreList[i])], 415, y, maxWidth:300 );
    y += line;
  }
}

/**
 * 設定画面
 */
class ConfigSetting extends GScreen {
  
  static const TextSoundOff = "サウンドをOFFにする";
  static const TextSoundOn  = "サウンドをONにする";
  
  void onStart() {
    geng.objlist.disposeAll();
    
    // サウンドボタン
    var sound = new GButton(width:300,height:60)
    ..text = geng.soundManager.soundOn ? TextSoundOff : TextSoundOn
    ..x = 285
    ..y = 220;
    sound.onRelease = () {
      if( geng.soundManager.soundOn ) {
        geng.soundManager.soundOn = false;
        sound.text = TextSoundOn;
        window.localStorage["sound"] = "false";
      } else {
        geng.soundManager.soundOn = true;
        sound.text = TextSoundOff;
        window.localStorage["sound"] = "true";
      }
    };
    geng.objlist.add( sound );
    btnList.add( sound );
    if( geng.soundManager.isSupport ==false ) {
      sound.text = "サウンド非対応ブラウザ";
      sound.isEnable = false;
    }
    
    // データクリアボタン
    var clearData = new GButton(text:"データをすべてクリアする",width:300,height:60)
    ..x = 285
    ..y = sound.y + 110
    ..onRelease = () { clearGameData(); };
    geng.objlist.add( clearData );
    btnList.add( clearData );
    
    // 戻るボタン配置
    var retbtn = new GButton(text:"戻る",width:300,height:60)
    ..onRelease = () { geng.screen = new Title(); }
    ..x = 285
    ..y = sound.y + (110*2);
    geng.objlist.add( retbtn );
    btnList.add( retbtn );
    
    //---------------------
    // 最前面描画処理
    Color bgColor = new Color.fromString("#ffffff");
    Color borderColor = new Color.fromString("#A2896F");
    onBackRender = ( GCanvas2D canvas ) {
      var img = geng.imageMap["title"];
      canvas.c.drawImageScaled(img, 0, 0, 570, 570);
      
      canvas.c.beginPath();
      // 背景
      canvas.roundRect( 100, 150, 370, 360, 18 );
      canvas.c.closePath();
      canvas.fillColor = bgColor;
      canvas.c.fill();
      // ボーダー
      canvas.strokeColor = borderColor;
      canvas.c.lineWidth = 4;
      canvas.c.stroke();
    };
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
    final score = resultToScore( numberOfHit, numberOfFire, stageData);
    final isPerfect = score==100;
    final levelText = resultToLevelText(score);
    
    // Hi-Score登録
    int rank = -1;
    var drawMeichu = null;
    var text02 = null;
    var drawLevel = null;
    var scoreList = null;
    
    // 結果表示の描画部分
    onFrontRender = ( GCanvas2D c ) {
      c.drawTexts( trenScore, ["- ゲーム しゅうりょう! -"], 285, 60);
      if( drawMeichu!=null )
        drawMeichu(c,125);
      if( text02!=null )
        c.drawTexts( trenScore, text02, 285, 185);
      if( drawLevel!=null )
        drawLevel( c, 240 );
      if( scoreList!=null )
        drawHiScore( c, scoreList, 330, mark:rank );
    };
    
    // 結果表示の進行
    delay( 1000, (){
      drawMeichu = (GCanvas2D c, int y) {
        c.drawTexts( trenScore, ["めいちゅうしたかず: ${_numberOfHit}こ"], 285, y);
        if( isPerfect ) {
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
        c.drawTexts( trenScore, ["〜 ${levelText} レベル 〜"], 285, y+30);
      };
      // hit数とFire数を保存
      try {
        rank = geng.hiscoreManager.addNewRecord(stageData['id'], score );
      } catch(e){}
      
      geng.repaint();
      geng.soundManager.play("bell");
    } );
    delay( 4000, (){
      // ハイスコア
      scoreList = geng.hiscoreManager.getScores(stageData['id']);
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
  
  final int _score;
  final ImageElement  img;
  
  PresentScreen( int score ) :
    _score = score,
    img = geng.imageMap["p$score"]
  ;
  
  void onStart() {
    geng.objlist.disposeAll();
    
    // 表示すべき日付を求める
    var now = new DateTime.now();
    String  nowText = "${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute}";
    
    List  info = ["$nowText ${resultToLevelText(_score)}"];

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
    
    var score = resultToScore( numberOfHit, numberOfFire, stageData );
    
    // メッセージ表示
    var message;
    if( score <= 70 ) {
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

