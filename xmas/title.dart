part of tankgame;

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
    ..y = 110;
    
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
    // 記録ボタンの配置
    var recordbtn = new GButton(text:"きろく",width:300,height:60)
    ..onPress = (){ geng.screen = new RecordScreen(); }
    ..x = 285
    ..y = practicebtn.y + (110 * 2);
    geng.objlist.add( recordbtn );
    btnList.add( recordbtn );
    
    //---------------------
    // Configボタンの配置
    var configbtn = new GButton(text:"せってい",width:300,height:60)
    ..onPress = (){ geng.screen = new ConfigSetting(); }
    ..x = 285
    ..y = practicebtn.y + (110 * 3);
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
      canvas.roundRect( 100, 40, 370, 470, 18 );
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

/**
 * 記録画面
 */
class RecordScreen extends GScreen {
  
  void onStart() {
    geng.objlist.disposeAll();
    
    // 戻るボタン配置
    var retbtn = new GButton(text:"戻る",width:300,height:60)
    ..onRelease = () { geng.screen = new Title(); }
    ..x = 285
    ..y = 500;
    geng.objlist.add( retbtn );
    btnList.add( retbtn );
    
    //------------
    // ランクボタン
    var create = (rank,x,y) {
      var r = xmasSavedata.getRank(rank);
      var btn = new GButton(width:170,height:60)
      ..text = (r!=null) ? r.rankText : "???"
      ..isEnable = (r!=null)
      ..onRelease = () { geng.screen = new PresentScreen(r); }
      ..x = x
      ..y = y;
      geng.objlist.add( btn );
      btnList.add( btn );
    };
    
    create( XMasScore.RANK01, 180, 300 );
    create( XMasScore.RANK02, 380, 300 );
    create( XMasScore.RANK03, 180, 390 );
    create( XMasScore.RANK04, 380, 390 );
    
    // 最前面描画処理
    onFrontRender = (GCanvas2D canvas) {
      drawHiScore(canvas, 80 );
    };
    
    //---------------------
    // 最背面描画処理
    Color bgColor = new Color.fromString("#ffffff");
    Color borderColor = new Color.fromString("#A2896F");
    onBackRender = ( GCanvas2D canvas ) {
      var img = geng.imageMap["title"];
      canvas.c.drawImageScaled(img, 0, 0, 570, 570);
      
      canvas.c.beginPath();
      // 背景
      canvas.roundRect( 50, 50, 470, 500, 18 );
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

