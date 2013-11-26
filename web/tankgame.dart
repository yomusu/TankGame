library tankgame;

import 'dart:html';
import 'dart:async';
import 'dart:math' as math;
import 'dart:collection';

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
      ..put("ball01", "./img/ball01.png");
    
    // サウンド読み込み
    geng.soundManager.put("fire","./sound/bomb.ogg");
    geng.soundManager.put("bomb","./sound/launch02.ogg");
    
    // ハイスコアデータ読み込み
    geng.hiscoreManager.init();
    
    // ゲームポイントマネージャー
    gamePointManager.init();
    
    // SoundのOn/Off
    bool sound = window.localStorage.containsKey("sound") ? window.localStorage["sound"]=="true" : false;
    geng.soundManager.soundOn = sound;
    
    // Canvas
    num scale = isMobileDevice() ? 0.5 : 1;
    geng.initField( width:570, height:570, scale:scale );
    
    querySelector("#place").append( geng.canvas );
    
    // 開始
    geng.screen = new Title();
    geng.startTimer();
  });
}

Map   itemData;
Map   stageData;
Tank  tank;
int score;
double  offset_x = 0.0;

clearGameData() {

  // ハイスコア
  geng.hiscoreManager.allClear();
  // サウンドのON/OFF
//  window.localStorage;
  // 取得ポイント
  gamePointManager.clearPoint();
}

TextRender  trenLogo = new TextRender()
..fontFamily = fontFamily
..fontSize = "28pt"
..textAlign = "center"
..textBaseline = "middle"
..lineWidth = 1.0
..lineHeight = 35
..strokeColor = Color.Black
..fillColor = Color.Yellow
..shadowColor = new Color.fromAlpha(0.5)
..shadowOffset = 5
..shadowBlur = 10;


/***********
 * 
 * タイトル画面の表示
 * 
 */
class Title extends GScreen {
  
  void onStart() {
    geng.objlist.disposeAll();
    
    //---------------------
    // 練習ボタン配置
    var practicebtn = new GButton(text:"れんしゅう",width:300,height:60)
    ..onPress = (){
      geng.soundManager.play("fire");
      new Timer( const Duration(milliseconds:500), () {
        stageData = stageList[0];
        itemData = itemList[0];
        geng.screen = new TankGamePracticely();
      });
    }
    ..x = 285
    ..y = 300;
    geng.objlist.add( practicebtn );
    btnList.add( practicebtn );
    
    //---------------------
    // StartGameボタン配置
    var playbtn = new GButton(text:"ゲームスタート",width:300,height:60)
    ..onPress = (){
      geng.soundManager.play("fire");
      new Timer( const Duration(milliseconds:500), () {
        stageData = stageList[1];
        itemData = itemList[0];
        geng.screen = new TankGame();
//        geng.screen = new StageSelect();
      });
    }
    ..x = 285
    ..y = 380;
    geng.objlist.add( playbtn );
    btnList.add( playbtn );
    
    //---------------------
    // Configボタンの配置
    var configbtn = new GButton(text:"せってい",width:300,height:60)
    ..onPress = (){ geng.screen = new ConfigSetting(); }
    ..x = 285
    ..y = 480;
    geng.objlist.add( configbtn );
    btnList.add( configbtn );
    
    //---------------------
    // 最前面描画処理
    onFrontRender = ( GCanvas2D canvas ) {
      canvas.drawTexts( trenLogo, ["肉の万世","クリスマス ゆきがっせん"], 285, 150 );
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

var scoretren = new TextRender()
..fontFamily = scoreFont
..fontSize = "12pt"
..textAlign = "left"
..textBaseline = "top"
..fillColor = Color.Black
..strokeColor = null;

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
    canvas.drawTexts( tren, [scoreList[i]], 415, y, maxWidth:300 );
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
    var sound = new GButton(width:300,height:70)
    ..text = geng.soundManager.soundOn ? TextSoundOff : TextSoundOn
    ..x = 285
    ..y = 200;
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
    var clearData = new GButton(text:"データをすべてクリアする",width:300,height:70)
    ..x = 285
    ..y = 300
    ..onRelease = () { clearGameData(); };
    geng.objlist.add( clearData );
    btnList.add( clearData );
    
    // 戻るボタン配置
    var retbtn = new GButton(text:"戻る",width:200,height:70)
    ..onRelease = () { geng.screen = new Title(); }
    ..x = 285
    ..y = 500;
    geng.objlist.add( retbtn );
    btnList.add( retbtn );
    
    // 最前面描画処理
    onFrontRender = ( GCanvas2D canvas ) {
      canvas.drawTexts( trenTitle, ["せってい"], 285, 10, maxWidth:620 );
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
    onFrontRender = ( GCanvas2D c ) {
      c.drawTexts( scoretren, ["SCORE: ${score}"], 5, 5 );
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
      offset_x = math.max( 0.0, tank.pos.x - 285.0 );
      
      // 地面スクロール
      ground.translateX = offset_x;
      
      // 再描画指示
      geng.repaint();
      
      // ステージ終了判定
      if( offset_x >= stageData['length'] ) {
        
        // 発射ボタン等消す
        firebtn.dispose();
        
        // Hi-Score登録
        int rank = -1;
        try {
          rank = geng.hiscoreManager.addNewRecord(stageData['id'], score );
        } catch(e){}
        
        // 加算処理
        delay( 1000, () {
          // 戻るボタン配置
          var retBtn = new GButton()
          ..onPress = () { geng.screen = new Title(); }
          ..text = "戻る"
              ..x = 285 ..y = 500
              ..width = 100 ..height= 40;
          geng.objlist.add( retBtn );
          btnList.add( retBtn );
          geng.repaint();
        });
        
        // ハイスコア
        var scoreList = geng.hiscoreManager.getScoreTexts(stageData['id']);
        
        // 結果表示
        onFrontRender = ( GCanvas2D c ) {
          c.drawTexts( trenScore, ["- ゲーム しゅうりょう! -"], 285, 100);
          c.drawTexts( trenScore, ["とくてん: ${score}"], 285, 180);
          // Hi-Score表示
          drawHiScore( c, scoreList, 270, mark:rank );
          // ゲームポイント
//          c.drawTexts( trenScore, ["TOTAL POINT: ${point}"], 285, 380);
//          if( hasGotNewCommer && hasCameEndOfCount ) {
//            c.drawTexts( trenHiscoreS, ["You have got a secret one!!"], 285, 410);
//          }
        };
        
        onProcess = () {
          tank.pos.add( tank.speed );
          if( 570 < (tank.pos.x - offset_x) )
            tank.dispose();
        };
      }
    };
    
    // 2秒後にオープニング終了
    new Timer( const Duration(seconds:2), () {
      // スタートロゴを消す
      startLogo.dispose();
      geng.repaint();
    });
  }

}

/***********
 * 
 * ゲーム本体
 * 
 */
class TankGamePracticely extends GScreen {
  
  void onStart() {
    geng.objlist.disposeAll();
    
    // 戦車の初期位置
    tank = new Tank()
    ..pos.x = 200.0
    ..pos.y = 430.0
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
      offset_x = math.max( 0.0, tank.pos.x - 285.0 );
      
      // 地面スクロール
      ground.translateX = offset_x;
      
      // 再描画指示
      geng.repaint();
      
      // ステージ終了判定
      if( offset_x >= stageData['length'] ) {
        
        // 発射ボタン等消す
        firebtn.dispose();
        
        // メッセージ表示
        var message;
        if( score<=50 ) {
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
    };
    
    // 2秒後にオープニング終了
    new Timer( const Duration(seconds:2), () {
      // スタートロゴを消す
      startLogo.dispose();
      geng.repaint();
    });
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
    
    new Timer( const Duration(milliseconds:200), () => startCharge() );
  }
  
  void startCharge() {
    new Timer.periodic( const Duration(milliseconds:50), (t) {
      power += 0.15;
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

