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
      ..put("tank01", "./img/tank1.png")
      ..put("tank02", "./img/tank2.png")
      ..put("targetL", "./img/target_l.png")
      ..put("targetS", "./img/target_s.png")
      ..put("kusa", "./img/kusa.png")
      ..put("gareki01", "./img/gareki01.png")
      ..put("gareki02", "./img/gareki02.png")
      ..put("gareki03", "./img/gareki03.png")
      ..put("smoke", "./img/kemuri.png")
      ..put("smokeB", "./img/kemuriB.png");
    
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
    geng.initField( width:640, height:600, scale:scale );
    
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
    var playbtn = new GButton(text:"ゲームスタート",width:300,height:60)
    ..onPress = (){
      geng.soundManager.play("fire");
      new Timer( const Duration(milliseconds:500), () {
        geng.screen = new StageSelect();
      });
    }
    ..x = 320
    ..y = 300;
    geng.objlist.add( playbtn );
    btnList.add( playbtn );
    
    //---------------------
    // How to Playボタンの配置
    var howtobtn = new GButton(text:"あそびかた",width:300,height:60)
    ..onPress = (){ geng.screen = new HowToPlay(); }
    ..x = 320
    ..y = 390;
    geng.objlist.add( howtobtn );
    btnList.add( howtobtn );
    
    //---------------------
    // Configボタンの配置
    var configbtn = new GButton(text:"設定",width:300,height:60)
    ..onPress = (){ geng.screen = new ConfigSetting(); }
    ..x = 320
    ..y = 480;
    geng.objlist.add( configbtn );
    btnList.add( configbtn );
    
    //---------------------
    // 最前面描画処理
    onFrontRender = ( GCanvas2D canvas ) {
      canvas.drawTexts( tren, ["Tank Game"], 320, 150 );
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

TextRender  trenStageName = new TextRender()
..fontFamily = scoreFont
..fontSize = "20pt"
..textAlign = "center"
..textBaseline = "middle"
..fillColor = Color.Black;

TextRender  trenStageCaption = new TextRender()
..fontFamily = fontFamily
..fontSize = "14pt"
..textAlign = "center"
..textBaseline = "middle"
..fillColor = Color.Gray;

TextRender  trenHiscore = new TextRender()
..fontFamily = scoreFont
..fontSize = "12pt"
..textAlign = "right"
..textBaseline = "middle"
..fillColor = Color.Black;

TextRender  trenHiscoreS = new TextRender.from(trenHiscore)
..fillColor = Color.Red;

/***********
 * 
 * ステージ選択画面の表示
 * 
 */
class StageSelect extends GScreen {
  
  var leftBtn,rightBtn,startBtn;
  var nowStageIndex = 0;
  
  Map get selectedStage => stageList[nowStageIndex];
  var scoreList;

  void onStart() {
    
    const StageY = 200;
    const HiscoreTop = 300;
    
    geng.objlist.disposeAll();
    
    // StageSelectボタン配置
    leftBtn = new GButton(text:"<", x:100, y:StageY, width:50, height:50)
    ..onRelease = ( (){ _shiftStage(-1); });
    geng.objlist.add( leftBtn );
    btnList.add( leftBtn );
    
    rightBtn = new GButton(text:">", x:540, y:StageY, width:50,height:50)
    ..onRelease = ( (){ _shiftStage(1); });
    geng.objlist.add( rightBtn );
    btnList.add( rightBtn );
    
    // StartGameボタン配置
    startBtn = new GButton(text:"つぎへ", x:320, y:500, width:300,height:60)
    ..onRelease = ( (){
      stageData = selectedStage;
      geng.screen = new ItemSelect();
    });
    geng.objlist.add( startBtn );
    btnList.add( startBtn );
    
    
    // 戻るボタン配置
    var btn = new GButton(text:"戻る",width:100,height:40)
      ..onRelease = ( (){ geng.screen = new Title(); } )
      ..x = 10 + (100/2)
      ..y = 10 + (40/2);
    geng.objlist.add( btn );
    btnList.add( btn );
    
    // 最前面描画処理
    onFrontRender = ( GCanvas2D canvas ) {
      canvas.drawTexts( trenTitle, ["ステージの選択"], 320, 10, maxWidth:620 );
      // ステージ名の表示
      canvas.drawTexts( trenStageName, [selectedStage['name']], 320, StageY-20 );
      canvas.drawTexts( trenStageCaption, [selectedStage['caption']], 320, StageY+20 );
      
      // ハイスコアの表示
      drawHiScore(canvas, scoreList, HiscoreTop);
    };
    
    // for Disable初期化
    _shiftStage(0);
  }
  
  void _shiftStage( num shift ) {
    
    nowStageIndex += shift;
    
    if( nowStageIndex <=0 ) {
      nowStageIndex = 0;
      leftBtn.isEnable = false;
      rightBtn.isEnable = true;
      
    } else if( nowStageIndex >= (stageList.length-1) ) {
      nowStageIndex = stageList.length-1;
      leftBtn.isEnable = true;
      rightBtn.isEnable = false;
      
    } else {
      leftBtn.isEnable = true;
      rightBtn.isEnable = true;
    }
    
    // Hi-Scoreリストを更新
    scoreList = geng.hiscoreManager.getScoreTexts(selectedStage['id']);

    // ステージがアンロックされているかで選択可を決める
    startBtn.isEnable = gamePointManager.isUnlock(selectedStage['id']);
  }
  
}

final titles = <String>["1st","2nd","3rd","4th","5th"];

// ハイスコアの表示
void drawHiScore( GCanvas2D canvas, var scoreList, int y, { int mark:-1 } ) {
  
  const line = 20;
  
  trenHiscore.textAlign = "center";
  canvas.drawTexts( trenHiscore, ["Hi-SCORE"], 320, y, maxWidth:300 );
  
  y += line*2;
  var tren = new TextRender.from(trenHiscore);
  tren.textAlign = "right";
  for( int i=0; i<scoreList.length; i++ ) {
    tren.fillColor = ( mark==i ) ? Color.Red : Color.Black;
    canvas.drawTexts( tren, [titles[i]], 250, y, maxWidth:100 );
    canvas.drawTexts( tren, [scoreList[i]], 450, y, maxWidth:300 );
    y += line;
  }
}

/***********
 * 
 * アイテム選択画面の表示
 * 
 */
class ItemSelect extends GScreen {
  
  void onStart() {
    geng.objlist.disposeAll();
    
    // StartGameボタン配置
    var y = 150;
    for( var item in itemList ) {
      
      var btn = new GButton()
      ..onPress = ( ()=>goToNext( item ) )
      ..text = item['text']
      ..width = 300
      ..height= 70
      ..x = 320
      ..y = y
      ..isEnable = gamePointManager.isUnlock(item['id']);
      geng.objlist.add( btn );
      btnList.add( btn );
      
      y += 100;
    }
    
    // 戻るボタン配置
    var btn = new GButton()
      ..onPress = ( (){ geng.screen = new StageSelect(); } )
      ..text = "戻る"
      ..width = 100
      ..height= 40
      ..x = 10 + (100/2)
      ..y = 10 + (40/2);
    geng.objlist.add( btn );
    btnList.add( btn );
    
    // 最前面描画処理
    onFrontRender = ( GCanvas2D canvas ) {
      canvas.drawTexts( trenTitle, ["アイテムの選択"], 320, 10, maxWidth:620 );
    };
  }
  
  void goToNext( var item ) {
    delay( 500, () {
      itemData = item;
      geng.screen = new TankGame();
    });
  }
}

/**
 * 遊び方画面
 */
class ConfigSetting extends GScreen {
  
  static const TextSoundOff = "サウンドをOFFにする";
  static const TextSoundOn  = "サウンドをONにする";
  
  void onStart() {
    geng.objlist.disposeAll();
    
    // サウンドボタン
    var sound = new GButton(width:300,height:70)
    ..text = geng.soundManager.soundOn ? TextSoundOff : TextSoundOn
    ..x = 320
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
    ..x = 320
    ..y = 300
    ..onRelease = () { clearGameData(); };
    geng.objlist.add( clearData );
    btnList.add( clearData );
    
    // 戻るボタン配置
    var retbtn = new GButton(text:"戻る",width:200,height:70)
    ..onRelease = () { geng.screen = new Title(); }
    ..x = 320
    ..y = 500;
    geng.objlist.add( retbtn );
    btnList.add( retbtn );
    
    // 最前面描画処理
    onFrontRender = ( GCanvas2D canvas ) {
      canvas.drawTexts( trenTitle, ["設定"], 320, 10, maxWidth:620 );
    };
  }
}

/**
 * 遊び方画面
 */
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
        
        // Hi-Score登録
        int rank = -1;
        try {
          rank = geng.hiscoreManager.addNewRecord(stageData['id'], score );
        } catch(e){}
        
        // ゲームポイントを加算
        var point = gamePointManager.point;
        bool hasGotNewCommer = gamePointManager.addPoint( score );
        var newPoint = gamePointManager.point;
        
        // 加算処理
        bool  hasCameEndOfCount = false;
        delay( 1000, () {
          new Timer.periodic( const Duration(milliseconds:20), (t){
            point+=10;
            if( point >= newPoint ) {
              point = newPoint;
              t.cancel();
              hasCameEndOfCount = true;
              // 戻るボタン配置
              var retBtn = new GButton()
              ..onPress = () { geng.screen = new Title(); }
              ..text = "戻る"
                  ..x = 320 ..y = 500
                  ..width = 100 ..height= 40;
              geng.objlist.add( retBtn );
              btnList.add( retBtn );
            }
          });
        });
        
        // ハイスコア
        var scoreList = geng.hiscoreManager.getScoreTexts(stageData['id']);
        
        // 結果表示
        onFrontRender = ( GCanvas2D c ) {
          c.drawTexts( trenScore, ["- GAME OVER -"], 320, 100);
          c.drawTexts( trenScore, ["SCORE: ${score}"], 320, 150);
          // Hi-Score表示
          drawHiScore( c, scoreList, 200, mark:rank );
          // ゲームポイント
          c.drawTexts( trenScore, ["TOTAL POINT: ${point}"], 320, 380);
          if( hasGotNewCommer && hasCameEndOfCount ) {
            c.drawTexts( trenHiscoreS, ["You have got a secret one!!"], 320, 410);
          }
        };
        
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
      power += 0.2;
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

